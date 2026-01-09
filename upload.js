// upload.js - 腾讯云COS上传脚本
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// 配置
const CONFIG = {
    secretId: 'AKIDJUSDk4JMCqJahdfcN8lEWbTAdv262nLj',
    secretKey: 'Let7B5pMmrqeItKYkohicS7ZpvpWxBE5',
    bucket: 'video-1380504831',
    region: 'ap-guangzhou',
    basePath: 'videoData/',
    videoPath: 'video/',
    coverPath: 'cover/'
};

// 生成标识符
function generateIdentifier() {
    const timestamp = Date.now();
    const randomNum = Math.floor(Math.random() * 9000) + 1000;
    const hash = crypto.createHash('md5')
    .update(timestamp + '_' + randomNum)
    .digest('hex')
    .substring(0, 8);
    return `${timestamp}_${randomNum}_${hash}`;
}

// 上传文件
function uploadFile(filePath, remotePath, fileType = 'video') {
    return new Promise((resolve, reject) => {
        if (!fs.existsSync(filePath)) {
            reject(`文件不存在: ${filePath}`);
            return;
        }

        const COS = require('cos-nodejs-sdk-v5');
        const cos = new COS({
            SecretId: CONFIG.secretId,
            SecretKey: CONFIG.secretKey
        });

        const stats = fs.statSync(filePath);
        const fileSize = stats.size;
        const fileName = path.basename(filePath);
        const extension = path.extname(fileName) || (fileType === 'video' ? '.mp4' : '.jpg');

        console.log(`上传${fileType === 'video' ? '视频' : '封面'}: ${fileName}`);

        cos.putObject({
            Bucket: CONFIG.bucket,
            Region: CONFIG.region,
            Key: remotePath,
            Body: fs.createReadStream(filePath),
                      ContentLength: fileSize,
                      onProgress: function(progressData) {
                          const percent = Math.round(progressData.percent * 100);
                          console.log(`PROGRESS:${fileType}:${percent}%`);
                      }
        }, function(err, data) {
            if (err) {
                reject(err);
            } else {
                const fileUrl = `https://${CONFIG.bucket}.cos.${CONFIG.region}.myqcloud.com/${remotePath}`;
                resolve({
                    success: true,
                    type: fileType,
                    url: fileUrl,
                    remotePath: remotePath,
                    identifier: remotePath.split('/').pop().split('.').slice(0, -1).join('.')
                });
            }
        });
    });
}

// 接口1: 上传视频
function uploadVideo(videoPath, identifier = null) {
    if (!identifier) {
        identifier = generateIdentifier();
    }

    const extension = path.extname(videoPath) || '.mp4';
    const remotePath = `${CONFIG.basePath}${CONFIG.videoPath}${identifier}${extension}`;

    return uploadFile(videoPath, remotePath, 'video');
}

// 接口2: 上传封面
function uploadCover(coverPath, identifier) {
    if (!identifier) {
        return Promise.reject('上传封面需要提供标识符');
    }

    const extension = path.extname(coverPath) || '.jpg';
    const remotePath = `${CONFIG.basePath}${CONFIG.coverPath}${identifier}${extension}`;

    return uploadFile(coverPath, remotePath, 'cover');
}

// 接口3: 同时上传视频和封面
async function uploadVideoWithCover(videoPath, coverPath, identifier = null) {
    if (!identifier) {
        identifier = generateIdentifier();
    }

    try {
        const videoResult = await uploadVideo(videoPath, identifier);
        const coverResult = await uploadCover(coverPath, identifier);

        return {
            success: true,
            identifier: identifier,
            video: videoResult,
            cover: coverResult,
            videoUrl: videoResult.url,
            coverUrl: coverResult.url
        };
    } catch (error) {
        throw error;
    }
}

// 接口4: 获取文件列表
function listFiles(prefix = '') {
    return new Promise((resolve, reject) => {
        const COS = require('cos-nodejs-sdk-v5');
        const cos = new COS({
            SecretId: CONFIG.secretId,
            SecretKey: CONFIG.secretKey
        });

        cos.getBucket({
            Bucket: CONFIG.bucket,
            Region: CONFIG.region,
            Prefix: prefix || CONFIG.basePath
        }, function(err, data) {
            if (err) {
                reject(err);
            } else {
                resolve(data.Contents || []);
            }
        });
    });
}

// 命令行接口
async function main() {
    const args = process.argv.slice(2);
    const command = args[0] || 'help';

    switch (command) {
        case 'video':
            if (args.length < 2) {
                process.exit(1);
            }
            const result = await uploadVideo(args[1], args[2]);
            console.log(JSON.stringify(result, null, 2));
            break;

        case 'cover':
            if (args.length < 3) {
                process.exit(1);
            }
            const coverResult = await uploadCover(args[1], args[2]);
            console.log(JSON.stringify(coverResult, null, 2));
            break;

        case 'both':
            if (args.length < 3) {
                process.exit(1);
            }
            const bothResult = await uploadVideoWithCover(args[1], args[2], args[3]);
            console.log(JSON.stringify(bothResult));
            break;

        case 'list':
            const prefix = args[1] || CONFIG.basePath;
            const files = await listFiles(prefix);
            console.log(JSON.stringify(files, null, 2));
            break;

        default:
            break;
    }
}

// 如果是直接运行
if (require.main === module) {
    main().catch(error => {
        console.error('错误:', error.message);
        process.exit(1);
    });
}
