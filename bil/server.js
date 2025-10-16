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
    const { filePath, fileName, title, description, uploadId } = req.body;

    console.log('📤 通过文件路径上传:', filePath);
    console.log('📋 上传ID:', uploadId);

    if (!filePath || !fs.existsSync(filePath)) {
        return res.status(400).json({
            code: 1,
            message: '文件不存在: ' + filePath
        });
    }

    // 生成唯一的uploadId（如果客户端没有提供）
    const currentUploadId = uploadId || `upload_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // 通知开始上传
    notifyProgress(currentUploadId, 0, '开始处理文件', 'started');

    const fileKey = `videos/${Date.now()}_${fileName || path.basename(filePath)}`;
    const fileStats = fs.statSync(filePath);

    console.log('   文件大小:', (fileStats.size / 1024 / 1024).toFixed(2) + 'MB');
    console.log('   COS Key:', fileKey);

    // 延迟一下，确保WebSocket连接建立
    setTimeout(() => {
        notifyProgress(currentUploadId, 5, '准备上传到云存储', 'uploading');

        // 上传到腾讯云COS
        cos.putObject({
            Bucket: cosConfig.Bucket,
            Region: cosConfig.Region,
            Key: fileKey,
            Body: fs.createReadStream(filePath),
            ContentLength: fileStats.size,
            onProgress: function(progressData) {
                var percent = Math.round(progressData.percent * 100);
                console.log(`   📊 COS上传进度: ${percent}%`);

                // 映射到更平滑的进度（5%到95%）
                var mappedProgress = 5 + (percent * 0.9);
                notifyProgress(currentUploadId, Math.round(mappedProgress), `上传中: ${percent}%`, 'uploading');
            }
        }, (err, data) => {
            if (err) {
                console.error('❌ COS上传失败:', err);
                notifyProgress(currentUploadId, 0, `上传失败: ${err.message}`, 'error');

                return res.status(500).json({
                    code: 1,
                    message: '上传失败: ' + err.message
                });
            }

            // 生成URL
            const videoUrl = `https://${cosConfig.Bucket}.cos.${cosConfig.Region}.myqcloud.com/${fileKey}`;
            const coverUrl = videoUrl.replace(/\.(mp4|avi|mov|mkv)$/i, '.jpg');

            console.log('✅ 上传成功!');
            console.log('   视频URL:', videoUrl);

            // 通知上传完成
            notifyProgress(currentUploadId, 100, '上传完成', 'completed');

            res.json({
                code: 0,
                message: '上传成功',
                data: {
                    uploadId: currentUploadId,
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
    }, 500);
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

// 启动服务器
app.listen(port, () => {
    console.log('🚀 HTTP服务启动: http://localhost:' + port);
    console.log('🔌 WebSocket服务: ws://localhost:8080');
});
