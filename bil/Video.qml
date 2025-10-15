

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
    property bool isUploading: false
    property var currentRequest: null

    // 上传视频方法
    function uploadVideo(filePath, title, description) {
        console.log("🚀 开始上传视频 - 参数:");
        console.log("  filePath:", filePath);
        console.log("  title:", title);
        console.log("  description:", description);

        if (isUploading) {
            uploadError("已有文件正在上传");
            return;
        }

        // 设置属性
        currentFilePath = filePath;
        currentTitle = title || "未命名视频";
        currentDescription = description || "暂无描述";
        isUploading = true;

        console.log("设置属性完成:");
        console.log("  currentFilePath:", currentFilePath);
        console.log("  currentTitle:", currentTitle);
        console.log("  currentDescription:", currentDescription);

        // 使用模拟上传进行测试（先确保基础功能正常）
        //uploadSimulate(filePath, currentTitle, currentDescription);

        // 如果需要真实上传，取消下面这行的注释
        uploadViaPath(filePath, currentTitle, currentDescription);
    }

    // 通过文件路径上传 - 修正版本
    function uploadViaPath(filePath, title, description) {
        console.log("📤 使用文件路径上传方案");

        // 创建 XMLHttpRequest 对象，配置 POST 请求和 JSON 内容类型
        var xhr = new XMLHttpRequest();
        xhr.open("POST", apiBaseUrl + "/upload/by-path");
        xhr.setRequestHeader("Content-Type", "application/json");

        // 构建请求数据对象，包含文件路径、元数据和文件名
        var requestData = {
            filePath: filePath,
            title: title,
            description: description,
            fileName: getFileName(filePath)
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
            console.log("⚠️ xhr.upload 不支持，使用模拟进度");//暂时还没实！！！

            // 如果没有 upload 支持，使用模拟进度
            //startSimulatedProgress();
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
            }
        });
        progressTimer.start();
    }

    // 模拟上传（用于测试）
    function uploadSimulate(filePath, title, description) {
        console.log("🎭 使用模拟上传");

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
                // 模拟上传完成
                var videoUrl = "https://example.com/videos/" + Date.now() + ".mp4";
                var coverUrl = "https://example.com/covers/" + Date.now() + ".jpg";
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

        // 如果是模拟上传，也需要停止计时器
        // 这里需要额外的逻辑来停止模拟计时器
    }

    // 工具函数.从文件路径中提取文件名
    function getFileName(filePath) {
        // 处理文件路径格式
        var path = filePath.toString();
        if (path.startsWith("file://")) {
            path = path.substring(7); // 移除 file:// 前缀
        }
        var lastSlash = path.lastIndexOf("/");
        return lastSlash >= 0 ? path.substring(lastSlash + 1) : path;
    }
}



