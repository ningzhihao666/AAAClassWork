// 数据库//////没实现
/*const mysql = require('mysql');

const connection = mysql.createConnection({
    host: '106.85.76.160',
    user: 'remote',
    password: '123456',
    database: 'sys',
    port:3306,
    connectTimeout: 15000,     // 增加超时时间
    timeout: 15000,
    charset: 'utf8mb4'


});

connection.connect((error) => {
    if (error) {
        console.error('连接失败:', error);
        return;
    }
    console.log('数据库连接成功!');

    // 先查看所有表
    connection.query('SHOW TABLES', (error, results) => {

        // 然后查询具体的表（替换为实际的表名）
        const actualTableName = 'Video'; // 根据上面显示的表名修改

        connection.query(`SELECT * FROM ${actualTableName}`, (error, results) => {
            if (error) {
                console.error('查询失败:', error);
                return;
            }

            console.log(`\n${actualTableName} 表数据:`);
            if (results.length > 0) {
                // 显示表头
                const columns = Object.keys(results[0]);
                console.log(columns.join('\t|\t'));
                console.log('-'.repeat(50));

                // 显示数据
                results.forEach(row => {
                    const values = Object.values(row);
                    console.log(values.join('\t|\t'));
                });
            } else {
                console.log('表中没有数据');
            }

            connection.end();
        });
    });
});*/



// server.js - 支持文件路径上传的版本
const express = require('express');//Web 框架，用于创建服务器和路由
const multer = require('multer');//处理文件上传的中间件
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const COS = require('cos-nodejs-sdk-v5');//腾讯云对象存储 SDK

//创建 Express应用实例，设置服务端口为 3000
const app = express();
const port = 3000;




// 中间件
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// 创建上传目录
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// 腾讯云COS配置
const cosConfig = {
    SecretId: 'AKIDvugHj03wc4LUTGqMflhS0Ol7KOGygIhv',
    SecretKey: '74sUu7JPRIxRktwoV07773seKsFPbgZF',
    Bucket: 'video-1380504831',
    Region: 'ap-guangzhou'
};


// 创建COS客户端实例
const cos = new COS({
    SecretId: cosConfig.SecretId,
    SecretKey: cosConfig.SecretKey
});

// 文件上传配置
// 创建 multer 实例
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueName = Date.now() + '-' + Math.round(Math.random() * 1E9) + path.extname(file.originalname);
        cb(null, uniqueName);
    }
});

const upload = multer({
    storage,
    limits: {
        fileSize: 100 * 1024 * 1024 // 文件100MB限制
    }
});

// ==================== API 路由 ====================

// 1. 健康检查
app.get('/', (req, res) => {
    res.json({
        message: '视频上传服务运行正常',
        timestamp: new Date().toISOString()
    });
});

// 2. 通过文件路径上传（QML专用）
app.post('/api/upload/by-path', (req, res) => {
    //接收文件路径、文件名、标题和描述参数
    const { filePath, fileName, title, description } = req.body;

    console.log('📤 通过文件路径上传:', filePath);
    // 检查文件是否存在
    if (!filePath || !fs.existsSync(filePath)) {
        return res.status(400).json({
            code: 1,
            message: '文件不存在: ' + filePath
        });
    }

    // 生成 COS 存储的文件键名，获取文件统计信息
    const fileKey = `videos/${Date.now()}_${fileName || path.basename(filePath)}`;
    const fileStats = fs.statSync(filePath);

    console.log('   文件大小:', (fileStats.size / 1024 / 1024).toFixed(2) + 'MB');
    console.log('   COS Key:', fileKey);

    // 上传到腾讯云COS
    cos.putObject({
        Bucket: cosConfig.Bucket,
        Region: cosConfig.Region,
        Key: fileKey,
        Body: fs.createReadStream(filePath),
        ContentLength: fileStats.size,
        onProgress: function(progressData) {
            var percent = Math.round(progressData.percent * 100);
            console.log(`   📊 上传进度: ${percent}%`);
        }
    }, (err, data) => {
        if (err) {
            console.error('❌ COS上传失败:', err);
            return res.status(500).json({
                code: 1,
                message: '上传失败: ' + err.message
            });
        }

        // 生成视频 URL 和封面图 URL
        const videoUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/${fileKey}`;
        const coverUrl = videoUrl.replace(/\.(mp4|avi|mov|mkv)$/i, '.jpg');

        console.log('✅ 上传成功!');
        console.log('   视频URL:', videoUrl);

        res.json({
            code: 0,
            message: '上传成功',
            data: {
                videoId: 'video_' + Date.now(),
                title: title || '未命名视频',
                description: description || '暂无描述',
                videoUrl: videoUrl,
                coverUrl: coverUrl,
                fileSize: fileStats.size,
                uploadTime: new Date().toISOString()
            }
        });
    });
});

// 3. 传统文件上传（支持multipart/form-data）
app.post('/api/upload/complete', upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({
            code: 1,
            message: '没有选择文件'
        });
    }

    const localPath = req.file.path;
    const fileName = req.file.originalname;
    const fileSize = req.file.size;
    const title = req.body.title || '未命名视频';
    const description = req.body.description || '暂无描述';

    const fileKey = `videos/${Date.now()}_${fileName}`;

    console.log('🚀 上传文件到COS:', fileName);

    cos.putObject({
        Bucket: cosConfig.Bucket,
        Region: cosConfig.Region,
        Key: fileKey,
        Body: fs.createReadStream(localPath),
        ContentLength: fileSize,
        onProgress: function(progressData) {
            var percent = Math.round(progressData.percent * 100);
            console.log(`   上传进度: ${percent}%`);
        }
    }, (err, data) => {
        // 清理临时文件
        if (fs.existsSync(localPath)) {
            fs.unlinkSync(localPath);
        }

        if (err) {
            console.error('❌ 上传失败:', err);
            return res.status(500).json({
                code: 1,
                message: '上传失败: ' + err.message
            });
        }

        const videoUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/${fileKey}`;
        const coverUrl = videoUrl.replace(/\.(mp4|avi|mov|mkv)$/i, '.jpg');

        console.log('✅ 上传成功:', videoUrl);

        res.json({
            code: 0,
            message: '上传成功',
            data: {
                videoId: 'video_' + Date.now(),
                title: title,
                description: description,
                videoUrl: videoUrl,
                coverUrl: coverUrl,
                fileSize: fileSize,
                uploadTime: new Date().toISOString()
            }
        });
    });
});

// 启动 Express 服务器
app.listen(port, () => {
    console.log('🚀 服务启动: http://localhost:' + port);
});



