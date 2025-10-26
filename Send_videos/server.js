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

// 存储视频元数据（在实际项目中应该使用数据库）
let videoMetadata = {};

// ==================== API 路由 ====================

// 1. 健康检查
app.get('/', (req, res) => {
    res.json({
        message: '视频上传服务运行正常',
        timestamp: new Date().toISOString()
    });
});

// 2. 获取视频列表 API - 从COS获取真实数据
app.get('/api/videos', async (req, res) => {
    console.log('📋 获取视频列表请求');

    try {
        // 从COS获取视频文件列表
        const videoFiles = await listCOSVideos();

        console.log(`✅ 从COS获取到 ${videoFiles.length} 个视频`);

        res.json({
            code: 0,
            message: '获取成功',
            data: videoFiles
        });
    } catch (error) {
        console.error('❌ 获取视频列表失败:', error);

        // 如果COS获取失败，返回模拟数据
        const mockVideos = getMockVideos();
        console.log(`🔄 使用模拟数据: ${mockVideos.length} 个视频`);

        res.json({
            code: 0,
            message: '获取成功（模拟数据）',
            data: mockVideos
        });
    }
});

// 从COS列出视频文件 - 修改版：包含用户设置的标题和描述
function listCOSVideos() {
    return new Promise((resolve, reject) => {
        cos.getBucket({
            Bucket: cosConfig.Bucket,
            Region: cosConfig.Region,
            Prefix: 'videos/',
            MaxKeys: 100
        }, (err, data) => {
            if (err) {
                reject(err);
                return;
            }

            const videos = [];

            if (data.Contents) {
                data.Contents.forEach((item, index) => {
                    const fileName = item.Key;

                    // 只处理视频文件
                    if (fileName.match(/\.(mp4|avi|mov|mkv|flv|wmv|webm)$/i)) {
                        const baseName = path.basename(fileName, path.extname(fileName));
                        const videoUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/${fileName}`;

                        // 生成封面图URL
                        const coverUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/covers/${baseName}.jpg`;

                        // 从文件名中提取时间戳
                        const timestampMatch = fileName.match(/(\d+)_/);
                        const timestamp = timestampMatch ? timestampMatch[1] : Date.now();

                        // 查找存储的元数据
                        const metadata = videoMetadata[timestamp] || {};

                        // 使用用户设置的标题和描述，如果没有则使用默认值
                        const userTitle = metadata.title || baseName.replace(/[_-]/g, ' ');
                        const userDescription = metadata.description || `视频文件: ${baseName}`;

                        videos.push({
                            videoId: `video_${timestamp}`,
                            title: userTitle,
                            description: userDescription,
                            videoUrl: videoUrl,
                            coverUrl: coverUrl,
                            duration: getRandomDuration(),
                                    views: getRandomViews(),
                                    uploadTime: new Date(item.LastModified).toISOString(),
                                    fileSize: formatFileSize(item.Size),
                                    originalFileName: baseName
                        });
                    }
                });
            }

            resolve(videos);
        });
    });
}

// 辅助函数
function getMockVideos() {
    return [
        {
            videoId: 'video_1',
            title: '测试视频1',
            description: '这是一个测试视频描述',
            videoUrl: 'https://video-1380504831.cos.ap-guangzhou.myqcloud.com/videos/sample1.mp4',
            coverUrl: 'https://video-1380504831.cos.ap-guangzhou.myqcloud.com/covers/sample1.jpg',
            duration: '05:23',
            views: '12500',
            uploadTime: new Date().toISOString(),
            fileSize: '45.2MB'
        },
        {
            videoId: 'video_2',
            title: '测试视频2',
            description: '另一个测试视频描述',
            videoUrl: 'https://video-1380504831.cos.ap-guangzhou.myqcloud.com/videos/sample2.mp4',
            coverUrl: 'https://video-1380504831.cos.ap-guangzhou.myqcloud.com/covers/sample2.jpg',
            duration: '03:45',
            views: '8700',
            uploadTime: new Date().toISOString(),
            fileSize: '32.1MB'
        }
    ];
}

function getRandomDuration() {
    const minutes = Math.floor(Math.random() * 10) + 1;
    const seconds = Math.floor(Math.random() * 60);
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
}

function getRandomViews() {
    const views = Math.floor(Math.random() * 100000) + 1000;
    return views.toString();
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// 2. 通过文件路径上传（QML专用）- 修改版：保存用户设置的标题和描述
app.post('/api/upload/by-path', (req, res) => {
    // 接收文件路径、文件名、标题、描述和封面路径参数
    const { filePath, fileName, title, description, coverPath } = req.body;

    console.log('📤 通过文件路径上传:', filePath);
    console.log('🖼️ 封面路径:', coverPath || '未提供封面');
    console.log('📝 标题:', title || '未设置标题');
    console.log('📄 描述:', description || '未设置描述');

    // 检查视频文件是否存在
    if (!filePath || !fs.existsSync(filePath)) {
        return res.status(400).json({
            code: 1,
            message: '视频文件不存在: ' + filePath
        });
    }

    // 检查封面文件是否存在（如果提供了封面路径）
    if (coverPath && !fs.existsSync(coverPath)) {
        return res.status(400).json({
            code: 1,
            message: '封面文件不存在: ' + coverPath
        });
    }

    // 生成 COS 存储的文件键名
    const timestamp = Date.now();
    const videoFileKey = `videos/${timestamp}_${fileName || path.basename(filePath)}`;
    const coverFileKey = `covers/${timestamp}_${path.basename(filePath).replace(/\.[^/.]+$/, "")}.jpg`;

    const fileStats = fs.statSync(filePath);

    console.log('   视频文件大小:', (fileStats.size / 1024 / 1024).toFixed(2) + 'MB');
    console.log('   视频COS Key:', videoFileKey);
    console.log('   封面COS Key:', coverFileKey);

    // 保存用户设置的标题和描述到元数据存储
    videoMetadata[timestamp] = {
        title: title || '未命名视频',
        description: description || '暂无描述',
        uploadTime: new Date().toISOString(),
         originalFileName: path.basename(filePath)
    };

    console.log('💾 保存视频元数据:', videoMetadata[timestamp]);

    // 上传视频到腾讯云COS
    uploadToCOS(videoFileKey, filePath, fileStats.size)
    .then(() => {
        // 如果有封面文件，上传封面
        if (coverPath && fs.existsSync(coverPath)) {
            const coverStats = fs.statSync(coverPath);
            console.log('   封面文件大小:', (coverStats.size / 1024).toFixed(2) + 'KB');
            return uploadToCOS(coverFileKey, coverPath, coverStats.size);
        } else {
            console.log('   ℹ️ 未提供封面文件，跳过封面上传');
            return Promise.resolve(); // 没有封面，继续执行
        }
    })
    .then(() => {
        // 生成最终的URL
        const videoUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/${videoFileKey}`;
        const coverUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/${coverFileKey}`;

        console.log('✅ 上传成功!');
        console.log('   视频URL:', videoUrl);
        console.log('   封面URL:', coverUrl);

        res.json({
            code: 0,
            message: '上传成功',
            data: {
                videoId: 'video_' + timestamp,
                title: title || '未命名视频',
                description: description || '暂无描述',
                videoUrl: videoUrl,
                coverUrl: coverUrl,
                fileSize: fileStats.size,
                uploadTime: new Date().toISOString()
            }
        });
    })
    .catch((err) => {
        console.error('❌ 上传失败:', err);
        res.status(500).json({
            code: 1,
            message: '上传失败: ' + err.message
        });
    });
});

// 通用的COS上传函数
function uploadToCOS(fileKey, filePath, fileSize) {
    return new Promise((resolve, reject) => {
        cos.putObject({
            Bucket: cosConfig.Bucket,
            Region: cosConfig.Region,
            Key: fileKey,
            Body: fs.createReadStream(filePath),
                      ContentLength: fileSize,
                      onProgress: function(progressData) {
                          var percent = Math.round(progressData.percent * 100);
                          console.log(`   📊 ${fileKey} 上传进度: ${percent}%`);
                      }
        }, (err, data) => {
            if (err) {
                reject(err);
            } else {
                console.log(`   ✅ ${fileKey} 上传完成`);
                resolve(data);
            }
        });
    });
}

// 3. 传统文件上传（支持multipart/form-data）- 修改版：保存用户设置的标题和描述
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

    const timestamp = Date.now();
    const fileKey = `videos/${timestamp}_${fileName}`;

    console.log('🚀 上传文件到COS:', fileName);
    console.log('📝 标题:', title);
    console.log('📄 描述:', description);

    // 保存用户设置的标题和描述到元数据存储
    videoMetadata[timestamp] = {
        title: title,
        description: description,
        uploadTime: new Date().toISOString(),
         originalFileName: fileName
    };

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
        const coverUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/covers/${timestamp}_${fileName.replace(/\.[^/.]+$/, "")}.jpg`;

        console.log('✅ 上传成功:', videoUrl);

        res.json({
            code: 0,
            message: '上传成功',
            data: {
                videoId: 'video_' + timestamp,
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

// 4. 获取单个视频的详细信息
app.get('/api/videos/:videoId', (req, res) => {
    const videoId = req.params.videoId;
    const timestamp = videoId.replace('video_', '');

    const metadata = videoMetadata[timestamp];

    if (metadata) {
        res.json({
            code: 0,
            message: '获取成功',
            data: metadata
        });
    } else {
        res.status(404).json({
            code: 1,
            message: '视频不存在'
        });
    }
});

// 启动 Express 服务器
app.listen(port, () => {
    console.log('🚀 服务启动: http://localhost:' + port);
    console.log('💾 视频元数据存储已初始化');
});
