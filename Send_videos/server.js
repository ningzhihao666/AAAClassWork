// server.js - 支持WebSocket进度推送的完整版本
const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const COS = require('cos-nodejs-sdk-v5');
const WebSocket = require('ws');

const app = express();
const port = 3000;

// 创建WebSocket服务器
const wss = new WebSocket.Server({ port: 8080 });
console.log('🔌 WebSocket服务器启动在端口 8080');

// 存储上传进度映射
const uploadProgressMap = new Map();

// WebSocket连接处理
wss.on('connection', (ws, req) => {
    console.log('📡 WebSocket客户端连接');

    // 解析URL获取uploadId
    const url = new URL(req.url, `http://${req.headers.host}`);
    const uploadId = url.searchParams.get('uploadId');

    if (uploadId) {
        console.log(`🔗 客户端订阅上传进度: ${uploadId}`);
        uploadProgressMap.set(uploadId, ws);

        // 发送连接确认
        ws.send(JSON.stringify({
            type: 'connected',
            uploadId: uploadId,
            message: '已连接到进度服务'
        }));
    } else {
        console.log('⚠️ 客户端连接缺少uploadId');
        ws.close(1008, '缺少uploadId参数');
        return;
    }

    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            console.log('📨 收到WebSocket消息:', data);

            if (data.type === 'ping') {
                ws.send(JSON.stringify({ type: 'pong' }));
            }
        } catch (e) {
            console.error('解析WebSocket消息失败:', e);
        }
    });

    ws.on('close', () => {
        console.log(`🔌 WebSocket连接关闭: ${uploadId}`);
        if (uploadId) {
            uploadProgressMap.delete(uploadId);
        }
    });

    ws.on('error', (error) => {
        console.error(`❌ WebSocket错误 (${uploadId}):`, error);
        if (uploadId) {
            uploadProgressMap.delete(uploadId);
        }
    });
});

// 中间件
app.use(cors({
    origin: true,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
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

const cos = new COS({
    SecretId: cosConfig.SecretId,
    SecretKey: cosConfig.SecretKey
});

// 文件上传配置
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
        fileSize: 100 * 1024 * 1024
    }
});

// 进度推送函数
function notifyProgress(uploadId, progress, message, status = 'uploading') {
    const ws = uploadProgressMap.get(uploadId);
    if (ws && ws.readyState === WebSocket.OPEN) {
        const progressData = {
            type: 'progress',
            uploadId: uploadId,
            progress: progress,
            message: message,
            status: status,
            timestamp: new Date().toISOString()
        };

        try {
            ws.send(JSON.stringify(progressData));
            console.log(`📤 推送进度 (${uploadId}): ${progress}% - ${message}`);
        } catch (error) {
            console.error(`推送进度失败 (${uploadId}):`, error);
            uploadProgressMap.delete(uploadId);
        }
    } else {
        console.log(`⚠️ 无法推送进度 (${uploadId}): WebSocket不可用`);
    }
}

// ==================== API 路由 ====================

// 健康检查
app.get('/', (req, res) => {
    res.json({
        message: '视频上传服务运行正常',
        timestamp: new Date().toISOString(),
        websocket: 'ws://localhost:8080'
    });
});

// 通过文件路径上传（支持WebSocket进度）
app.post('/api/upload/by-path', (req, res) => {
    // 接收文件路径、文件名、标题和描述参数
    const { filePath, coverPath, title, description } = req.body;

    console.log('📤 通过文件路径上传:', filePath);
    // 检查文件是否存在
    if (!filePath || !fs.existsSync(filePath)) {
        return res.status(400).json({
            code: 1,
            message: '文件不存在: ' + filePath
        });
    }

    // 生成 COS 存储的文件键名，获取文件统计信息
    const fileKey = `videos/${Date.now()}_${path.basename(filePath)}`;
    const fileStats = fs.statSync(filePath);

    console.log('   文件大小:', (fileStats.size / 1024 / 1024).toFixed(2) + 'MB');
    console.log('   COS Key:', fileKey);

    // 上传视频到腾讯云COS
    cos.putObject({
        Bucket: cosConfig.Bucket,
        Region: cosConfig.Region,
        Key: fileKey,
        Body: fs.createReadStream(filePath),
        ContentLength: fileStats.size,
        onProgress: function(progressData) {
            var percent = Math.round(progressData.percent * 100);
            console.log(`   📊 视频上传进度: ${percent}%`);
        }
    }, (err, data) => {
        if (err) {
            console.error('❌ 视频COS上传失败:', err);
            return res.status(500).json({
                code: 1,
                message: '视频上传失败: ' + err.message
            });
        }

        // 生成视频 URL
        const videoUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/${fileKey}`;
        let coverUrl = null;

        // 如果有封面路径，上传封面图
        if (coverPath) {
            if (!fs.existsSync(coverPath)) {
                console.warn('⚠️ 封面文件不存在:', coverPath);
            } else {
                const coverKey = `covers/${Date.now()}_${path.basename(coverPath)}`;
                const coverStats = fs.statSync(coverPath);

                console.log('   🖼️ 上传封面图:', coverPath);
                console.log('   封面大小:', (coverStats.size / 1024).toFixed(2) + 'KB');
                console.log('   COS Key:', coverKey);

                // 上传封面图
                cos.putObject({
                    Bucket: cosConfig.Bucket,
                    Region: cosConfig.Region,
                    Key: coverKey,
                    Body: fs.createReadStream(coverPath),
                    ContentLength: coverStats.size,
                    onProgress: function(progressData) {
                        var percent = Math.round(progressData.percent * 100);
                        console.log(`   📊 封面上传进度: ${percent}%`);
                    }
                }, (coverErr, coverData) => {
                    if (coverErr) {
                        console.error('❌ 封面COS上传失败:', coverErr);
                    } else {
                        coverUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/${coverKey}`;
                        console.log('   封面URL:', coverUrl);
                    }
                    completeUpload();
                });
            }
        } else {
            // 如果没有封面路径，直接完成上传
            completeUpload();
        }

        function completeUpload() {
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
                    coverUrl: coverUrl, // 可能是null或上传成功的URL
                    fileSize: fileStats.size,
                    uploadTime: new Date().toISOString()
                }
            });
        }
    });
});


// 传统文件上传（支持进度）
app.post('/api/upload/complete', upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({
            code: 1,
            message: '没有选择文件'
        });
    }

    const uploadId = req.body.uploadId || `upload_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const localPath = req.file.path;
    const fileName = req.file.originalname;
    const fileSize = req.file.size;
    const title = req.body.title || '未命名视频';
    const description = req.body.description || '暂无描述';

    console.log('🚀 上传文件到COS:', fileName);
    console.log('📋 上传ID:', uploadId);

    notifyProgress(uploadId, 0, '开始处理文件', 'started');

    const fileKey = `videos/${Date.now()}_${fileName}`;

    setTimeout(() => {
        notifyProgress(uploadId, 10, '准备上传', 'uploading');

        cos.putObject({
            Bucket: cosConfig.Bucket,
            Region: cosConfig.Region,
            Key: fileKey,
            Body: fs.createReadStream(localPath),
            ContentLength: fileSize,
            onProgress: function(progressData) {
                var percent = Math.round(progressData.percent * 100);
                var mappedProgress = 10 + (percent * 0.85); // 10%到95%
                notifyProgress(uploadId, Math.round(mappedProgress), `上传中: ${percent}%`, 'uploading');
            }
        }, (err, data) => {
            // 清理临时文件
            if (fs.existsSync(localPath)) {
                fs.unlinkSync(localPath);
            }

            if (err) {
                console.error('❌ 上传失败:', err);
                notifyProgress(uploadId, 0, `上传失败: ${err.message}`, 'error');
                return res.status(500).json({
                    code: 1,
                    message: '上传失败: ' + err.message
                });
            }

            const videoUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/${fileKey}`;
            const coverUrl = videoUrl.replace(/\.(mp4|avi|mov|mkv)$/i, '.jpg');

            console.log('✅ 上传成功:', videoUrl);
            notifyProgress(uploadId, 100, '上传完成', 'completed');

            res.json({
                code: 0,
                message: '上传成功',
                data: {
                    uploadId: uploadId,
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
    }, 500);
});

// 获取上传状态
app.get('/api/upload/status/:uploadId', (req, res) => {
    const uploadId = req.params.uploadId;
    const ws = uploadProgressMap.get(uploadId);

    res.json({
        code: 0,
        data: {
            uploadId: uploadId,
            connected: !!(ws && ws.readyState === WebSocket.OPEN),
            status: ws ? 'connected' : 'disconnected'
        }
    });
});

// 封面上传接口
app.post('/api/upload/cover', (req, res) => {
    const { filePath, fileName } = req.body;

    if (!filePath || !fs.existsSync(filePath)) {
        return res.status(400).json({
            code: 1,
            message: '封面文件不存在'
        });
    }

    const fileKey = `covers/${Date.now()}_${fileName || path.basename(filePath)}`;
    const fileStats = fs.statSync(filePath);

    cos.putObject({
        Bucket: cosConfig.Bucket,
        Region: cosConfig.Region,
        Key: fileKey,
        Body: fs.createReadStream(filePath),
        ContentLength: fileStats.size
    }, (err, data) => {
        if (err) {
            return res.status(500).json({
                code: 1,
                message: '封面上传失败: ' + err.message
            });
        }

        const coverUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/${fileKey}`;
        res.json({
            code: 0,
            message: '封面上传成功',
            data: { url: coverUrl }
        });
    });
});



// 存储视频和封面的映射关系
const videoCoverMap = {};

// 关联视频和封面的接口
app.post('/api/associate-video-cover', (req, res) => {
    const { videoUrl, coverUrl } = req.body;

    if (!videoUrl || !coverUrl) {
        return res.status(400).json({
            code: 1,
            message: '视频URL和封面URL都不能为空'
        });
    }

    // 提取视频ID（假设视频URL格式为 https://bucket.cos.region.myqcloud.com/videos/123_video.mp4）
    const videoId = videoUrl.split('/').pop().split('_')[0];

    // 存储关联关系
    videoCoverMap[videoId] = coverUrl;

    res.json({
        code: 0,
        message: '关联成功',
        data: {
            videoId,
            videoUrl,
            coverUrl
        }
    });
});

// 获取视频信息的接口（包含关联的封面）
app.get('/api/video/:videoId', (req, res) => {
    const { videoId } = req.params;

    // 这里应该是从数据库查询，但示例中使用内存存储
    const videoInfo = {
        videoId,
        videoUrl: `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/videos/${videoId}_sample.mp4`,
        coverUrl: videoCoverMap[videoId]
    };

    res.json({
        code: 0,
        message: '获取成功',
        data: videoInfo
    });
});


// 启动服务器
app.listen(port, () => {
    console.log('🚀 HTTP服务启动: http://localhost:' + port);
    console.log('🔌 WebSocket服务: ws://localhost:8080');
});
