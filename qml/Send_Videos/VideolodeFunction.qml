//视频上传功能函数

import QtQuick
import QtQuick.Controls

Item {
    id: uploader

    signal uploadProgress(var bytesSent, var bytesTotal)
    signal uploadFinished(string videoUrl, string coverUrl)
    signal uploadError(string error)
    signal uploadCancelled()

    // 配置属性
    property string apiBaseUrl: "http://localhost:3000/api"
    property string currentFilePath: ""
    property string currentTitle: ""
    property string currentDescription: ""
    property string currentCoverPath: ""
    property string currentAuthorName: ""
    property string currentAuthorId: ""
    property string currentAvatar: ""
    property bool isUploading: false
    property var currentRequest: null

    // 上传视频方法 - 修改：添加封面路径参数
    function uploadVideo(filePath, title, description, coverPath = "") {
        console.log("🚀 开始上传视频 - 参数:");
        if (isUploading) {
            uploadError("已有文件正在上传");
            return;
        }

        // 设置属性
        currentFilePath = filePath;
        currentTitle = title || "未命名视频";
        currentDescription = description || "暂无描述";
        currentCoverPath = coverPath || "";
        currentAuthorName=userController.currentUser.nickname;
        currentAuthorId=userController.currentUser.id;
        currentAvatar=userController.avatarUrl;
        isUploading = true;

        // 调用上传方法，传递封面路径
        uploadViaPath(filePath, currentTitle, currentDescription, currentCoverPath,currentAuthorName,currentAuthorId,currentAvatar);
    }

    // 通过文件路径上传 - 修改：添加封面路径参数
    function uploadViaPath(filePath, title, description, coverPath = "",author,authorId,avatar) {
        console.log("📤 使用文件路径上传方案");
        console.log("  封面路径:", coverPath || "未提供封面");

        // 创建 XMLHttpRequest 对象，配置 POST 请求和 JSON 内容类型
        var xhr = new XMLHttpRequest();
        xhr.open("POST", apiBaseUrl + "/upload/by-path");
        xhr.setRequestHeader("Content-Type", "application/json");

        // 构建请求数据对象，包含文件路径、元数据、文件名和封面路径
        var requestData = {
            filePath: filePath,
            title: title,
            description: description,
            fileName: getFileName(filePath),
            coverPath: coverPath,  // 新增封面路径参数
            author:author,
            authorId:authorId,
            avatar:avatar,
        };

        console.log("发送请求数据:", JSON.stringify(requestData));

        // 修正：检查 upload 属性是否存在
        if (xhr.upload) {
            xhr.upload.onprogress = function(event) {
                if (event.lengthComputable) {
                    var percent = Math.round((event.loaded / event.total) * 100);
                    console.log("上传进度:", percent + "%");
                    uploadProgress(event.loaded, event.total);
                }
            };
        } else {
            console.log("⚠️ xhr.upload 不支持，使用模拟进度");
            // 如果没有 upload 支持，使用模拟进度
            startSimulatedProgress();
        }

        // 状态变化监听
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isUploading = false;

                console.log("请求完成 - 状态:", xhr.status, "响应:", xhr.responseText);

                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        console.log("上传响应:", response);

                        if (response.code === 0) {
                            var videoUrl = response.data.videoUrl;
                            var coverUrl = response.data.coverUrl;
                            console.log("✅ 上传成功 - 视频URL:", videoUrl, "封面URL:", coverUrl);
                            uploadFinished(videoUrl, coverUrl);
                        } else {
                            uploadError("上传失败: " + response.message);
                        }
                    } catch (e) {
                        console.error("解析响应失败:", e);
                        uploadError("解析服务器响应失败: " + e.toString());
                    }
                } else {
                    console.error("请求失败:", xhr.status, xhr.statusText);
                    uploadError("上传请求失败: " + xhr.status + " " + xhr.statusText);
                }
            }
        };

        // 错误处理
        xhr.onerror = function() {
            isUploading = false;
            console.error("网络错误");
            uploadError("网络连接错误");
        };

        currentRequest = xhr;

        console.log("发送上传请求...");
        xhr.send(JSON.stringify(requestData));
    }

    // 模拟进度（当 xhr.upload 不可用时）
    function startSimulatedProgress() {
        var total = 100;
        var current = 0;
        var step = 2;

        var progressTimer = Qt.createQmlObject('import QtQuick; Timer { interval: 100; repeat: true }', uploader);
        progressTimer.triggered.connect(function() {
            if (current < total) {
                current += step;
                if (current > total) current = total;
                console.log("模拟进度:", current + "%");
                uploadProgress(current, total);
            } else {
                progressTimer.stop();
                progressTimer.destroy();
            }
        });
        progressTimer.start();
    }

    // 模拟上传（用于测试）- 修改：添加封面路径参数
    function uploadSimulate(filePath, title, description, coverPath = "") {
        console.log("🎭 使用模拟上传");
        console.log("  封面路径:", coverPath || "未提供封面");

        isUploading = true;

        // 模拟上传进度
        var total = 100;
        var current = 0;
        var step = 2;

        var timer = Qt.createQmlObject('import QtQuick; Timer { interval: 100; repeat: true }', uploader);
        timer.triggered.connect(function() {
            current += step;
            if (current <= total) {
                uploadProgress(current, total);
                console.log("模拟进度:", current + "%");
            } else {
                timer.stop();
                timer.destroy();
                // 模拟上传完成
                var videoUrl = "https://example.com/videos/" + Date.now() + ".mp4";
                var coverUrl = coverPath ?
                    "https://example.com/covers/" + getFileName(coverPath) :
                    "https://example.com/covers/default.jpg";
                console.log("✅ 模拟上传成功");
                uploadFinished(videoUrl, coverUrl);
                isUploading = false;
            }
        });
        timer.start();
    }

    // 取消上传
    function cancelUpload() {
        console.log("取消上传");
        if (currentRequest && isUploading) {
            currentRequest.abort();
            currentRequest = null;
            isUploading = false;
            uploadCancelled();
        }

        // 清理模拟进度计时器
        // 这里需要额外的逻辑来停止模拟计时器
    }

    // 工具函数：从文件路径中提取文件名
    function getFileName(filePath) {
        // 处理文件路径格式
        var path = filePath.toString();
        if (path.startsWith("file://")) {
            path = path.substring(7); // 移除 file:// 前缀
        }
        var lastSlash = path.lastIndexOf("/");
        return lastSlash >= 0 ? path.substring(lastSlash + 1) : path;
    }

    // 新增：获取文件扩展名
    function getFileExtension(filePath) {
        var fileName = getFileName(filePath);
        var lastDot = fileName.lastIndexOf(".");
        return lastDot >= 0 ? fileName.substring(lastDot + 1).toLowerCase() : "";
    }

    // 新增：验证文件类型
    function isValidVideoFile(filePath) {
        var ext = getFileExtension(filePath);
        var videoExtensions = ["mp4", "avi", "mov", "mkv", "flv", "wmv", "webm"];
        return videoExtensions.includes(ext);
    }

    function isValidImageFile(filePath) {
        var ext = getFileExtension(filePath);
        var imageExtensions = ["jpg", "jpeg", "png", "bmp", "gif"];
        return imageExtensions.includes(ext);
    }
}

