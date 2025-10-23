// 使用WebSocket
import QtQuick
import QtQuick.Controls
import QtWebSockets

Item {
    id: uploader

    signal uploadProgress(var bytesSent, var bytesTotal)
    signal uploadFinished(string videoUrl, string coverUrl)
    signal uploadError(string error)
    signal uploadCancelled()

    // 配置属性
    property string apiBaseUrl: "http://localhost:3000/api"
    property string wsBaseUrl: "ws://localhost:8080"
    property string currentFilePath: ""
    property string currentTitle: ""
    property string currentDescription: ""
    property bool isUploading: false
    property var currentRequest: null
    property string currentUploadId: ""

    // WebSocket相关属性
    property WebSocket webSocket: null
    property bool wsConnected: false
    property int lastProgress: 0

    // 上传视频方法
    function uploadVideo(filePath, title, description,coverPath = "") {
        console.log("🚀 开始上传视频 - 参数:");
        console.log("  filePath:", filePath);
        console.log("  title:", title);
        console.log("  description:", description);

        if (isUploading) {
            uploadError("已有文件正在上传");
            return;
        }

        // 生成上传ID
        currentUploadId = "upload_" + Date.now() + "_" + Math.random().toString(36).substr(2, 9);

        // 设置属性
        currentFilePath = filePath;
        currentTitle = title || "未命名视频";
        currentDescription = description || "暂无描述";
        isUploading = true;
        lastProgress = 0;

        console.log("📋 上传ID:", currentUploadId);

        // 初始化WebSocket连接
        initWebSocket();

        // 开始上传
        if (coverPath) {
            // 如果有封面路径，先上传封面
            uploadCover(coverPath, function(coverUrl) {
                // 封面上传完成后上传视频
                uploadViaPath(filePath, title, description, coverUrl);
            });
        } else {
            // 没有封面直接上传视频
            uploadViaPath(filePath, title, description);
        }
    }

    // 初始化WebSocket连接 - 修正版本
    function initWebSocket() {
        console.log("🔌 初始化WebSocket连接...");

        if (webSocket) {
            webSocket.active = false;
            webSocket.destroy();
            webSocket = null;
        }

        var wsUrl = wsBaseUrl + "?uploadId=" + currentUploadId;
        console.log("WebSocket URL:", wsUrl);

        // 正确创建 WebSocket 对象
        webSocket = Qt.createQmlObject(`
            import QtWebSockets
            WebSocket {
                url: "` + wsUrl + `"
                active: true
            }
        `, uploader);

        // 正确连接信号 - 使用 statusChanged 而不是 onConnected
        webSocket.statusChanged.connect(function() {
            console.log("WebSocket 状态变化:", webSocket.status);
            if (webSocket.status === WebSocket.Open) {
                console.log("✅ WebSocket连接成功");
                wsConnected = true;
            } else if (webSocket.status === WebSocket.Closed) {
                console.log("🔌 WebSocket连接关闭");
                wsConnected = false;
            } else if (webSocket.status === WebSocket.Error) {
                console.error("❌ WebSocket错误:", webSocket.errorString);
                wsConnected = false;
            }
        });

        // 正确连接文本消息信号
        webSocket.textMessageReceived.connect(function(message) {
            console.log("📨 收到WebSocket消息:", message);

            try {
                var data = JSON.parse(message);
                handleWebSocketMessage(data);
            } catch (e) {
                console.error("解析WebSocket消息失败:", e);
            }
        });
    }

    // 处理WebSocket消息
    function handleWebSocketMessage(data) {
        switch(data.type) {
            case 'connected':
                console.log("🔗 WebSocket连接确认:", data.message);
                break;

            case 'progress':
                console.log("📊 收到进度更新:", data.progress + "% - " + data.message);
                handleProgressUpdate(data);
                break;

            case 'pong':
                // 心跳响应
                break;

            default:
                console.log("未知消息类型:", data.type);
        }
    }

    // 处理进度更新
    function handleProgressUpdate(data) {
        var progress = data.progress;
        var message = data.message;
        var status = data.status;

        // 更新进度显示
        lastProgress = progress;

        // 计算模拟的bytesSent和bytesTotal（用于兼容现有接口）
        var bytesTotal = 100;
        var bytesSent = progress;

        // 发出进度信号
        uploadProgress(bytesSent, bytesTotal);

        // 更新状态文本
        if (status === 'started') {
            progressText.text = "开始上传...";
        } else if (status === 'uploading') {
            progressText.text = "上传进度: " + progress;
        } else if (status === 'completed') {
            progressText.text = "上传完成!";
        } else if (status === 'error') {
            progressText.text = "上传错误: " + message;
        }

        console.log("🔄 更新进度:", progress + "%");
    }

    // 通过文件路径上传
    function uploadViaPath(filePath, title, description, existingCoverUrl = "") {
        console.log("📤 使用文件路径上传方案");

        // 等待WebSocket连接建立
        var waitTimer = Qt.createQmlObject('import QtQuick; Timer { interval: 1000; running: true }', uploader);
        waitTimer.triggered.connect(function() {
            waitTimer.destroy();

            if (!wsConnected) {
                console.log("⚠️ WebSocket未连接，继续上传但可能无法获取实时进度");
            }

            var xhr = new XMLHttpRequest();
            xhr.open("POST", apiBaseUrl + "/upload/by-path");
            xhr.setRequestHeader("Content-Type", "application/json");

            var requestData = {
                filePath: filePath,
                fileName: getFileName(filePath),
                title: title,
                description: description,
                uploadId: currentUploadId
            };

            // 如果有预先上传的封面URL，一并发送
            if (existingCoverUrl) {
                requestData.coverUrl = existingCoverUrl;
            }
            console.log("发送请求数据:", JSON.stringify(requestData));

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

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    isUploading = false;

                    // 关闭WebSocket连接
                    if (webSocket) {
                        webSocket.active = false;
                        webSocket.destroy();
                        webSocket = null;
                    }

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

            xhr.onerror = function() {
                isUploading = false;
                console.error("网络错误");
                uploadError("网络连接错误");

                if (webSocket) {
                    webSocket.active = false;
                    webSocket.destroy();
                    webSocket = null;
                }
            };

            currentRequest = xhr;

            console.log("发送上传请求...");
            xhr.send(JSON.stringify(requestData));
        });
    }

    // 取消上传
    function cancelUpload() {
        console.log("取消上传");

        if (currentRequest && isUploading) {
            currentRequest.abort();
            currentRequest = null;
        }

        if (webSocket) {
            webSocket.active = false;
            webSocket.destroy();
            webSocket = null;
        }

        isUploading = false;
        uploadCancelled();
    }

    // 工具函数：从文件路径中提取文件名
    function getFileName(filePath) {
        var path = filePath.toString();
        if (path.startsWith("file://")) {
            path = path.substring(7);
        }
        var lastSlash = path.lastIndexOf("/");
        return lastSlash >= 0 ? path.substring(lastSlash + 1) : path;
    }
}



