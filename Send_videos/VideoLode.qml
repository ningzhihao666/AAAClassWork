//视频上传页面

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window
import QtCore

Item {
    id: videoLode
    width: 800
    height: 700  // 增加高度以容纳新控件

    // 公共属性
    property alias buttonText: uploadButton.text
    property alias progressVisible: progressBar.visible
    property alias progressValue: progressBar.value
    property alias progressText: progressText.text
    property alias statusText: statusText.text

    // 信号
    signal uploadStarted(string filePath, string title, string description, string coverPath)
    signal uploadCancelled() //取消上传时触发
    signal fileSelected(string filePath) // 文件选择完成时触发
    signal coverSelected(string coverPath) // 封面选择完成时触发
    signal uploadFinished(string videoUrl, string coverUrl) //
    signal uploadError(string error) // 上传过程中发生错误时触发

    // 选择的文件路径
    property string selectedVideoPath: ""
    property string selectedCoverPath: ""
    property string videoTitle: ""
    property string videoDescription: ""

    // 视频上传器组件
    VideolodeFunction {
        id: uploader

        // 更新进度条的值和最大值
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

            // 重置表单
            resetForm()
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

        // 取消处理
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
        spacing: 15

        // 视频文件选择区域
        GroupBox {
            title: "选择视频文件"
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: 10

                Button {
                    id: selectVideoButton
                    text: selectedVideoPath ? "重新选择视频文件" : "选择视频文件"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: selectVideoButton.down ? "#e6f7ff" : "#f0f0f0"
                        border.color: "#d9d9d9"
                        radius: 4
                    }

                    onClicked: {
                        videoFileDialog.open()
                    }
                }

                Text {
                    id: videoFileInfo
                    text: selectedVideoPath ? "已选择: " + getFileName(selectedVideoPath) : "未选择视频文件"
                    font.pixelSize: 12
                    color: selectedVideoPath ? "green" : "gray"
                    Layout.fillWidth: true
                    elide: Text.ElideLeft
                }
            }
        }

        // 封面图片选择区域
        GroupBox {
            title: "选择封面图片（可选）"
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        id: selectCoverButton
                        text: selectedCoverPath ? "重新选择封面" : "选择封面图片"
                        Layout.fillWidth: true

                        background: Rectangle {
                            color: selectCoverButton.down ? "#e6f7ff" : "#f0f0f0"
                            border.color: "#d9d9d9"
                            radius: 4
                        }

                        onClicked: {
                            coverFileDialog.open()
                        }
                    }

                    Button {
                        id: clearCoverButton
                        text: "清除封面"
                        visible: selectedCoverPath
                        onClicked: {
                            selectedCoverPath = ""
                            coverImage.source = ""
                            statusLog.text += "已清除封面选择\n"
                        }

                        background: Rectangle {
                            color: clearCoverButton.down ? "#fff2f0" : "#ffccc7"
                            border.color: "#ffa39e"
                            radius: 4
                        }
                    }
                }

                // 封面预览
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    border.color: "#d9d9d9"
                    border.width: 1
                    radius: 4
                    color: "#fafafa"

                    Image {
                        id: coverImage
                        anchors.fill: parent
                        anchors.margins: 5
                        fillMode: Image.PreserveAspectFit
                        source: selectedCoverPath ? "file://" + selectedCoverPath : ""
                        asynchronous: true

                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.log("封面图片加载失败")
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "封面预览"
                        color: "gray"
                        visible: !coverImage.source
                    }
                }

                Text {
                    id: coverFileInfo
                    text: selectedCoverPath ? "已选择封面: " + getFileName(selectedCoverPath) : "未选择封面（将使用默认封面）"
                    font.pixelSize: 12
                    color: selectedCoverPath ? "green" : "gray"
                    Layout.fillWidth: true
                    elide: Text.ElideLeft
                }
            }
        }

        // 视频信息输入区域
        GroupBox {
            title: "视频信息"
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: 10

                // 标题输入
                Label {
                    text: "视频标题 *"
                    font.bold: true
                }

                TextField {
                    id: titleInput
                    Layout.fillWidth: true
                    placeholderText: "请输入视频标题..."
                    onTextChanged: videoTitle = text

                    background: Rectangle {
                        border.color: titleInput.focus ? "#40a9ff" : "#d9d9d9"
                        border.width: 1
                        radius: 4
                    }
                }

                // 描述输入
                Label {
                    text: "视频描述"
                    font.bold: true
                }

                TextArea {
                    id: descriptionInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    placeholderText: "请输入视频描述（可选）..."
                    wrapMode: TextArea.Wrap
                    onTextChanged: videoDescription = text

                    background: Rectangle {
                        border.color: descriptionInput.focus ? "#40a9ff" : "#d9d9d9"
                        border.width: 1
                        radius: 4
                    }
                }
            }
        }

        // 上传按钮
        Button {
            id: uploadButton
            text: qsTr("开始上传视频")
            Layout.alignment: Qt.AlignCenter
            enabled: selectedVideoPath && videoTitle.trim() !== ""

            background: Rectangle {
                color: uploadButton.enabled ?
                    (uploadButton.down ? "#0091c2" : "#00a1d6") : "#cccccc"
                radius: 5
            }
            contentItem: Text {
                text: uploadButton.text
                color: uploadButton.enabled ? "white" : "#999999"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                startUpload()
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
                text: "重置表单"
                onClicked: {
                    resetForm()
                    statusLog.text += "表单已重置\n"
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

    // 视频文件选择对话框
    FileDialog {
        id: videoFileDialog
        title: "选择视频文件"
        nameFilters: ["视频文件 (*.mp4 *.avi *.mov *.mkv *.flv *.wmv)"]
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]

        onAccepted: {
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

            console.log("选择的视频文件路径:", filePath);
            selectedVideoPath = filePath
            fileSelected(filePath)
            statusLog.text += "选择了视频文件: " + getFileName(filePath) + "\n"
        }

        onRejected: {
            console.log("用户取消了视频文件选择");
            statusLog.text += "用户取消了视频文件选择\n"
        }
    }

    // 封面文件选择对话框
    FileDialog {
        id: coverFileDialog
        title: "选择封面图片"
        nameFilters: ["图片文件 (*.jpg *.jpeg *.png *.bmp *.gif)"]
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]

        onAccepted: {
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

            console.log("选择的封面文件路径:", filePath);
            selectedCoverPath = filePath
            coverSelected(filePath)
            statusLog.text += "选择了封面文件: " + getFileName(filePath) + "\n"
        }

        onRejected: {
            console.log("用户取消了封面文件选择");
            statusLog.text += "用户取消了封面文件选择\n"
        }
    }

    function startUpload() {
        if (!selectedVideoPath) {
            statusText.text = "错误: 请先选择视频文件"
            return
        }

        if (!videoTitle.trim()) {
            statusText.text = "错误: 请输入视频标题"
            return
        }

        console.log("开始上传流程 - 文件:", selectedVideoPath);
        console.log("封面:", selectedCoverPath);
        console.log("标题:", videoTitle);
        console.log("描述:", videoDescription);

        // 更新UI状态
        uploadButton.enabled = false
        progressBar.visible = true
        progressBar.value = 0
        progressText.text = "准备上传..."
        statusText.text = "文件: " + getFileName(selectedVideoPath) + "\n标题: " + videoTitle
        cancelButton.visible = true

        // 发出信号
        uploadStarted(selectedVideoPath, videoTitle, videoDescription, selectedCoverPath)
        statusLog.text += "开始上传: " + getFileName(selectedVideoPath) + "\n"

        // 开始上传
        uploader.uploadVideo(selectedVideoPath, videoTitle, videoDescription, selectedCoverPath)
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

    // 重置表单
    function resetForm() {
        selectedVideoPath = ""
        selectedCoverPath = ""
        videoTitle = ""
        videoDescription = ""
        titleInput.text = ""
        descriptionInput.text = ""
        coverImage.source = ""
        uploadButton.enabled = true
        progressBar.visible = false
        progressBar.value = 0
        progressText.text = "等待上传..."
        statusText.text = ""
        cancelButton.visible = false
    }

    // 公共方法
    function reset() {
        resetForm()
    }

    function setProgress(percent) {
        progressBar.value = percent
        progressText.text = "上传进度: " + percent + "%"
    }

    function setStatus(message) {
        statusText.text = message
    }
}
