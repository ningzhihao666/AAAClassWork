//视频上传页面

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window

Item {
    id: videoLode
    width: 800
    height: 600

    // 公共属性
    property alias buttonText: uploadButton.text
    property alias progressVisible: progressBar.visible
    property alias progressValue: progressBar.value
    property alias progressText: progressText.text
    property alias statusText: statusText.text

    // 信号
    signal uploadStarted(string filePath, string title, string description)
    signal uploadCancelled() //取消上传时触发
    signal fileSelected(string filePath) // 文件选择完成时触发
    signal uploadFinished(string videoUrl, string coverUrl) //
    signal uploadError(string error) // 上传过程中发生错误时触发

    // 视频上传器组件
    Video {
        id: uploader

        // 更新进度条的值和最大值(不可以为0) 还没实现！！！！！！！！！！！！！！！！！！！！！！！！！
        onUploadProgress: function(bytesSent, bytesTotal) {
            progressBar.value = bytesSent
            progressBar.to = bytesTotal
            var percent = bytesTotal > 0 ? Math.round((bytesSent / bytesTotal) * 100) : 0
            progressText.text = "上传进度: " + percent + "%"
        }

        // 上传完成处理
        onUploadFinished: function(videoUrl, coverUrl) {
            progressText.text = "上传完成!"
            statusText.text = "视频URL: " + videoUrl + "\n封面URL: " + coverUrl
            uploadButton.enabled = true
            progressBar.visible = false //进度条
            cancelButton.visible = false //取消按钮
            statusLog.text += "上传完成! 视频URL: " + videoUrl + "\n"
            videoLode.uploadFinished(videoUrl, coverUrl)
        }

        // 错误处理
        onUploadError: function(error) {
            progressText.text = "上传错误"
            statusText.text = "错误: " + error
            uploadButton.enabled = true
            progressBar.visible = false
            cancelButton.visible = false
            statusLog.text += "上传错误: " + error + "\n"
            videoLode.uploadError(error)
        }

        // 取消处理 还没实现！！！！！！！！！！！！！！！！！！！！！！！！！
        onUploadCancelled: {
            progressText.text = "上传已取消"
            statusText.text = ""
            uploadButton.enabled = true
            progressBar.visible = false
            cancelButton.visible = false
            statusLog.text += "上传已取消\n"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Button {
            id: uploadButton
            text: qsTr("选择并上传视频")
            Layout.alignment: Qt.AlignCenter

            background: Rectangle {
                color: uploadButton.down ? "#0091c2" : "#00a1d6"
                radius: 5
            }
            contentItem: Text {
                text: uploadButton.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                fileDialog.open()
            }
        }

        // 进度条
        ProgressBar {
            id: progressBar
            Layout.fillWidth: true
            visible: false
            from: 0
            to: 100
            value: 0
        }

        Text {
            id: progressText
            text: qsTr("等待上传...")
            font.pixelSize: 16
            Layout.alignment: Qt.AlignHCenter
        }

        // 可滚动的状态信息显示区域
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 80

            TextArea {
                id: statusText
                placeholderText: "上传状态将显示在这里..."
                readOnly: true
                background: Rectangle {
                    border.color: "#ccc"
                    border.width: 1
                    radius: 5
                }
            }
        }

        Button {
            id: cancelButton
            text: qsTr("取消上传")
            Layout.alignment: Qt.AlignCenter
            visible: false

            background: Rectangle {
                color: cancelButton.down ? "#cc3333" : "#ff4d4f"
                radius: 5
            }
            contentItem: Text {
                text: cancelButton.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                uploader.cancelUpload()
                uploadCancelled()
            }
        }

        // 控制按钮区域
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 20

            Button {
                text: "重置上传器"
                onClicked: {
                    reset()
                    statusLog.text += "上传器已重置\n"
                }

                background: Rectangle {
                    color: parent.down ? "#e6f7ff" : "#f0f0f0"
                    border.color: "#d9d9d9"
                    radius: 4
                }
            }

            //前期测试用
            Button {
                text: "模拟进度"
                onClicked: {
                    var progress = Math.random() * 100
                    setProgress(progress)
                    setStatus("模拟上传进度: " + progress.toFixed(1) + "%")
                    statusLog.text += "设置模拟进度: " + progress.toFixed(1) + "%\n"
                }

                background: Rectangle {
                    color: parent.down ? "#f6ffed" : "#f0f0f0"
                    border.color: "#d9d9d9"
                    radius: 4
                }
            }

            Item { Layout.fillWidth: true }
        }

        // 日志区域，测试用
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                text: "操作日志:"
                font.bold: true
                font.pixelSize: 14
                color: "#333"
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TextArea {
                    id: statusLog
                    readOnly: true
                    placeholderText: "操作日志将显示在这里..."
                    background: Rectangle {
                        color: "white"
                        border.color: "#ccc"
                        border.width: 1
                        radius: 3
                    }
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "选择视频文件"
        nameFilters: ["视频文件 (*.mp4 *.avi *.mov *.mkv)"]
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]

        onAccepted: {
            console.log("文件对话框选择完成");
            console.log("selectedFile:", selectedFile);
            console.log("selectedFiles:", selectedFiles);

            var fileUrl = selectedFile;
            if (!fileUrl) {
                if (selectedFiles.length > 0) {
                    fileUrl = selectedFiles[0];
                } else {
                    console.error("没有选择文件");
                    return;
                }
            }

            var filePath = fileUrl.toString();
            if (filePath.startsWith("file://")) {
                filePath = filePath.substring(7);
            }

            console.log("处理后的文件路径:", filePath);
            fileSelected(filePath)
            statusLog.text += "选择了文件: " + filePath + "\n"
            startUpload(filePath);
        }

        onRejected: {
            console.log("用户取消了文件选择");
            statusLog.text += "用户取消了文件选择\n"
        }
    }

    function startUpload(filePath) {
        var title = "我的视频_" + new Date().toLocaleString(Qt.locale(), "yyyyMMdd_hhmmss")
        var description = "通过B站风格上传器上传的视频"

        console.log("开始上传流程 - 文件:", filePath);
        console.log("标题:", title);
        console.log("描述:", description);

        // 更新UI状态
        uploadButton.enabled = false
        progressBar.visible = true
        progressBar.value = 0
        progressText.text = "准备上传..."
        statusText.text = "文件: " + filePath + "\n标题: " + title
        cancelButton.visible = true

        // 发出信号
        uploadStarted(filePath, title, description)
        statusLog.text += "开始上传: " + filePath + "\n"

        // 开始上传
        uploader.uploadVideo(filePath, title, description)
    }

    // 公共方法
    function reset() {
        uploadButton.enabled = true
        progressBar.visible = false
        progressBar.value = 0
        progressText.text = "等待上传..."
        statusText.text = ""
        cancelButton.visible = false
    }

    function setProgress(percent) {
        progressBar.value = percent
        progressText.text = "上传进度: " + percent + "%"
    }

    function setStatus(message) {
        statusText.text = message
    }
}
