//视频上传页面

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window

Item {
    id: videoLode
    width: 800
    height: 750  // 增加高度以容纳标签功能

    // 公共属性
    property alias buttonText: uploadButton.text
    property alias progressVisible: progressBar.visible
    property alias progressValue: progressBar.value
    property alias progressText: progressText.text
    property alias statusText: statusText.text

    // 信号
    signal uploadStarted(string filePath, string title, string description, string coverPath, var tags)
    signal uploadCancelled()
    signal fileSelected(string filePath)
    signal coverSelected(string coverPath)
    signal uploadFinished(string videoUrl, string coverUrl)
    signal uploadError(string error)

    // 选择的文件路径
    property string selectedVideoPath: ""
    property string selectedCoverPath: ""
    property string videoTitle: ""
    property string videoDescription: ""
    property var selectedTags: []  // 存储选中的标签

    // 预定义标签选项
    property var predefinedTags: [
        "科技", "教育", "娱乐", "音乐", "游戏", "生活", "美食", "旅行",
        "体育", "健身", "时尚", "美妆", "宠物", "动漫", "电影", "读书",
        "编程", "设计", "摄影", "舞蹈", "汽车", "财经", "健康", "搞笑"
    ]

    // 视频上传器组件
    VideolodeFunction {
        id: uploader

        onUploadProgress: function(bytesSent, bytesTotal) {
            progressBar.value = bytesSent
            progressBar.to = bytesTotal
            var percent = bytesTotal > 0 ? Math.round((bytesSent / bytesTotal) * 100) : 0
            progressText.text = "上传进度: " + percent + "%"
        }

        onUploadFinished: function(videoUrl, coverUrl) {
            progressText.text = "上传完成!"
            statusText.text = "视频URL: " + videoUrl + "\n封面URL: " + coverUrl
            uploadButton.enabled = true
            progressBar.visible = false
            cancelButton.visible = false
            statusLog.text += "上传完成! 视频URL: " + videoUrl + "\n"
            videoLode.uploadFinished(videoUrl, coverUrl)
            resetForm()
        }

        onUploadError: function(error) {
            progressText.text = "上传错误"
            statusText.text = "错误: " + error
            uploadButton.enabled = true
            progressBar.visible = false
            cancelButton.visible = false
            statusLog.text += "上传错误: " + error + "\n"
            videoLode.uploadError(error)
        }

        onUploadCancelled: {
            progressText.text = "上传已取消"
            statusText.text = ""
            uploadButton.enabled = true
            progressBar.visible = false
            cancelButton.visible = false
            statusLog.text += "上传已取消\n"
        }
    }

    // 渐变背景
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f8f9fa" }
            GradientStop { position: 1.0; color: "#e9ecef" }
        }
    }

    // 添加 ScrollView 包装整个内容区域
    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true

        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AsNeeded

        contentWidth: contentLayout.width
        contentHeight: contentLayout.height

        ColumnLayout {
            id: contentLayout
            width: scrollView.width - 20  // 留出滚动条空间
            anchors.margins: 25
            spacing: 20

            // 标题
            Text {
                text: "视频上传"
                font.pixelSize: 28
                font.bold: true
                color: "#2c3e50"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
            }

            // 视频文件选择区域
            GroupBox {
                title: "🎬 选择视频文件"
                Layout.fillWidth: true
                background: Rectangle {
                    color: "white"
                    radius: 12
                    border.color: "#e1e5e9"
                }

                ColumnLayout {
                    width: parent.width
                    spacing: 12

                    Button {
                        id: selectVideoButton
                        text: selectedVideoPath ? "🔄 重新选择视频文件" : "📁 选择视频文件"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45

                        background: Rectangle {
                            color: selectVideoButton.down ? "#e3f2fd" :
                                   selectedVideoPath ? "#e8f5e8" : "#f0f4f8"
                            border.color: selectedVideoPath ? "#4caf50" : "#2196f3"
                            border.width: 2
                            radius: 8
                        }

                        contentItem: Text {
                            text: selectVideoButton.text
                            color: selectedVideoPath ? "#2e7d32" : "#1565c0"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: videoFileDialog.open()
                    }

                    Text {
                        id: videoFileInfo
                        text: selectedVideoPath ? "✅ 已选择: " + getFileName(selectedVideoPath) : "❌ 未选择视频文件"
                        font.pixelSize: 13
                        color: selectedVideoPath ? "#2e7d32" : "#666"
                        Layout.fillWidth: true
                        elide: Text.ElideLeft
                    }
                }
            }

            // 封面图片选择区域
            GroupBox {
                title: "🖼️ 选择封面图片（可选）"
                Layout.fillWidth: true
                background: Rectangle {
                    color: "white"
                    radius: 12
                    border.color: "#e1e5e9"
                }

                ColumnLayout {
                    width: parent.width
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Button {
                            id: selectCoverButton
                            text: selectedCoverPath ? "🔄 重新选择封面" : "📷 选择封面图片"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45

                            background: Rectangle {
                                color: selectCoverButton.down ? "#e3f2fd" :
                                       selectedCoverPath ? "#e8f5e8" : "#f0f4f8"
                                border.color: selectedCoverPath ? "#4caf50" : "#2196f3"
                                border.width: 2
                                radius: 8
                            }

                            contentItem: Text {
                                text: selectCoverButton.text
                                color: selectedCoverPath ? "#2e7d32" : "#1565c0"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: coverFileDialog.open()
                        }

                        Button {
                            id: clearCoverButton
                            text: "🗑️ 清除封面"
                            visible: selectedCoverPath
                            Layout.preferredHeight: 45
                            Layout.preferredWidth: 120

                            background: Rectangle {
                                color: clearCoverButton.down ? "#ffebee" : "#ffcdd2"
                                border.color: "#f44336"
                                border.width: 2
                                radius: 8
                            }

                            contentItem: Text {
                                text: clearCoverButton.text
                                color: "#c62828"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                selectedCoverPath = ""
                                coverImage.source = ""
                                statusLog.text += "已清除封面选择\n"
                            }
                        }
                    }

                    // 封面预览
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        border.color: selectedCoverPath ? "#4caf50" : "#bdc3c7"
                        border.width: 2
                        radius: 12
                        color: "#fafafa"

                        Image {
                            id: coverImage
                            anchors.fill: parent
                            anchors.margins: 8
                            fillMode: Image.PreserveAspectFit
                            source: selectedCoverPath ? "file://" + selectedCoverPath : ""
                            asynchronous: true
                            opacity: status === Image.Ready ? 1 : 0.3

                            Behavior on opacity {
                                NumberAnimation { duration: 300 }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "封面预览区域"
                            color: "#7f8c8d"
                            font.pixelSize: 14
                            visible: !coverImage.source
                        }
                    }

                    Text {
                        id: coverFileInfo
                        text: selectedCoverPath ? "✅ 已选择封面: " + getFileName(selectedCoverPath) : "💡 未选择封面（将使用默认封面）"
                        font.pixelSize: 13
                        color: selectedCoverPath ? "#2e7d32" : "#666"
                        Layout.fillWidth: true
                        elide: Text.ElideLeft
                    }
                }
            }

            // 视频信息输入区域
            GroupBox {
                title: "📝 视频信息"
                Layout.fillWidth: true
                background: Rectangle {
                    color: "white"
                    radius: 12
                    border.color: "#e1e5e9"
                }

                ColumnLayout {
                    width: parent.width
                    spacing: 15

                    // 标题输入
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: "视频标题 *"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#2c3e50"
                        }

                        TextField {
                            id: titleInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            placeholderText: "请输入吸引人的视频标题..."
                            font.pixelSize: 14

                            // 确保实时更新 videoTitle 属性
                            onTextChanged: videoTitle = text

                            background: Rectangle {
                                border.color: titleInput.focus ? "#3498db" : "#bdc3c7"
                                border.width: titleInput.focus ? 2 : 1
                                radius: 8
                                color: titleInput.focus ? "#f8f9fa" : "white"
                            }
                        }
                    }

                    // 描述输入
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: "视频描述"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#2c3e50"
                        }

                        TextArea {
                            id: descriptionInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            placeholderText: "详细描述视频内容，让更多观众发现你的作品..."
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 14

                            background: Rectangle {
                                border.color: descriptionInput.focus ? "#3498db" : "#bdc3c7"
                                border.width: descriptionInput.focus ? 2 : 1
                                radius: 8
                                color: descriptionInput.focus ? "#f8f9fa" : "white"
                            }
                        }
                    }
                }
            }

            // 标签选择区域
            GroupBox {
                title: "🏷️ 视频标签（可选）"
                Layout.fillWidth: true
                background: Rectangle {
                    color: "white"
                    radius: 12
                    border.color: "#e1e5e9"
                }

                ColumnLayout {
                    width: parent.width
                    spacing: 12

                    // 预定义标签区域
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "选择标签:"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#2c3e50"
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: predefinedTags

                                Rectangle {
                                    width: tagText.contentWidth + 20
                                    height: 32
                                    radius: 16
                                    color: selectedTags.includes(modelData) ? "#3498db" : "#ecf0f1"
                                    border.color: selectedTags.includes(modelData) ? "#2980b9" : "#bdc3c7"

                                    Text {
                                        id: tagText
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: selectedTags.includes(modelData) ? "white" : "#2c3e50"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (selectedTags.includes(modelData)) {
                                                // 移除标签
                                                var index = selectedTags.indexOf(modelData);
                                                selectedTags.splice(index, 1);
                                            } else {
                                                // 添加标签
                                                selectedTags.push(modelData);
                                            }
                                            selectedTagsChanged();
                                            statusLog.text += "标签更新: " + selectedTags.join(", ") + "\n";
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 自定义标签输入
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "自定义标签:"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#2c3e50"
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            TextField {
                                id: customTagInput
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                placeholderText: "输入自定义标签，用逗号分隔多个标签..."
                                font.pixelSize: 14

                                background: Rectangle {
                                    border.color: customTagInput.focus ? "#3498db" : "#bdc3c7"
                                    border.width: customTagInput.focus ? 2 : 1
                                    radius: 8
                                    color: customTagInput.focus ? "#f8f9fa" : "white"
                                }

                                onAccepted: addCustomTags()
                            }

                            Button {
                                text: "添加"
                                Layout.preferredHeight: 40
                                Layout.preferredWidth: 80

                                background: Rectangle {
                                    color: parent.down ? "#27ae60" : "#2ecc71"
                                    radius: 8
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: addCustomTags()
                            }
                        }
                    }

                    // 已选标签显示
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: selectedTags.length > 0

                        Label {
                            text: "已选标签:"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#2c3e50"
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: selectedTags

                                Rectangle {
                                    width: selectedTagText.contentWidth + 40
                                    height: 36
                                    radius: 18
                                    color: "#e74c3c"
                                    border.color: "#c0392b"

                                    Text {
                                        id: selectedTagText
                                        anchors.left: parent.left
                                        anchors.leftMargin: 15
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData
                                        color: "white"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }

                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: "white"
                                        anchors.right: parent.right
                                        anchors.rightMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            anchors.centerIn: parent
                                            text: "×"
                                            color: "#e74c3c"
                                            font.pixelSize: 14
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                var index = selectedTags.indexOf(modelData);
                                                if (index !== -1) {
                                                    selectedTags.splice(index, 1);
                                                    selectedTagsChanged();
                                                    statusLog.text += "移除标签: " + modelData + "\n";
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 上传进度区域
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15

                // 进度条
                ProgressBar {
                    id: progressBar
                    Layout.fillWidth: true
                    visible: false
                    from: 0
                    to: 100
                    value: 0

                    background: Rectangle {
                        implicitHeight: 8
                        color: "#ecf0f1"
                        radius: 4
                    }

                    contentItem: Item {
                        implicitHeight: 8

                        Rectangle {
                            width: progressBar.visualPosition * parent.width
                            height: parent.height
                            radius: 4
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#3498db" }
                                GradientStop { position: 1.0; color: "#2980b9" }
                            }
                        }
                    }
                }

                Text {
                    id: progressText
                    text: "等待上传..."
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2c3e50"
                    Layout.alignment: Qt.AlignHCenter
                }

                // 按钮区域
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        id: uploadButton
                        text: "🚀 开始上传视频"
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50
                        enabled: selectedVideoPath && titleInput.text.trim() !== ""

                        background: Rectangle {
                            color: uploadButton.enabled ?
                                (uploadButton.down ? "#27ae60" : "#2ecc71") : "#bdc3c7"
                            radius: 10
                        }

                        contentItem: Text {
                            text: uploadButton.text
                            color: uploadButton.enabled ? "white" : "#7f8c8d"
                            font.pixelSize: 16
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: startUpload()
                    }

                    Button {
                        id: cancelButton
                        text: "❌ 取消上传"
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 50
                        visible: false

                        background: Rectangle {
                            color: cancelButton.down ? "#c0392b" : "#e74c3c"
                            radius: 10
                        }

                        contentItem: Text {
                            text: cancelButton.text
                            color: "white"
                            font.pixelSize: 16
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            uploader.cancelUpload()
                            uploadCancelled()
                        }
                    }
                }
            }

            // 状态信息显示
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: "📊 上传状态:"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#2c3e50"
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100

                    TextArea {
                        id: statusText
                        placeholderText: "上传状态将显示在这里..."
                        readOnly: true
                        font.pixelSize: 13
                        wrapMode: TextArea.Wrap

                        background: Rectangle {
                            color: "#f8f9fa"
                            border.color: "#dee2e6"
                            border.width: 2
                            radius: 8
                        }
                    }
                }
            }

            // 操作日志区域
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 120

                Label {
                    text: "📋 操作日志:"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#2c3e50"
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    TextArea {
                        id: statusLog
                        readOnly: true
                        placeholderText: "操作日志将显示在这里..."
                        font.pixelSize: 12
                        wrapMode: TextArea.Wrap

                        background: Rectangle {
                            color: "white"
                            border.color: "#dee2e6"
                            border.width: 1
                            radius: 6
                        }
                    }
                }
            }

            // 底部空白区域，确保内容可以完全滚动
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
            }
        }
    }

    // 文件选择对话框（保持不变）
    FileDialog {
        id: videoFileDialog
        title: "选择视频文件"
        nameFilters: ["视频文件 (*.mp4 *.avi *.mov *.mkv *.flv *.wmv)"]
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]

        onAccepted: {
            var fileUrl = selectedFile;
            if (!fileUrl && selectedFiles.length > 0) {
                fileUrl = selectedFiles[0];
            }
            if (fileUrl) {
                var filePath = fileUrl.toString().replace("file://", "");
                selectedVideoPath = filePath
                fileSelected(filePath)
                statusLog.text += "选择了视频文件: " + getFileName(filePath) + "\n"
            }
        }
    }

    FileDialog {
        id: coverFileDialog
        title: "选择封面图片"
        nameFilters: ["图片文件 (*.jpg *.jpeg *.png *.bmp *.gif)"]
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]

        onAccepted: {
            var fileUrl = selectedFile;
            if (!fileUrl && selectedFiles.length > 0) {
                fileUrl = selectedFiles[0];
            }
            if (fileUrl) {
                var filePath = fileUrl.toString().replace("file://", "");
                selectedCoverPath = filePath
                coverSelected(filePath)
                statusLog.text += "选择了封面文件: " + getFileName(filePath) + "\n"
            }
        }
    }

    // 添加自定义标签函数
    function addCustomTags() {
        var customTags = customTagInput.text.split(/[,，]/).map(tag => tag.trim()).filter(tag => tag !== "");

        customTags.forEach(tag => {
            if (!selectedTags.includes(tag)) {
                selectedTags.push(tag);
            }
        });

        customTagInput.text = "";
        selectedTagsChanged();
        statusLog.text += "添加自定义标签: " + customTags.join(", ") + "\n";
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
        console.log("标签:", selectedTags);

        // 更新UI状态
        uploadButton.enabled = false
        progressBar.visible = true
        progressBar.value = 0
        progressText.text = "准备上传..."
        statusText.text = "文件: " + getFileName(selectedVideoPath) + "\n标题: " + videoTitle + "\n标签: " + selectedTags.join(", ")
        cancelButton.visible = true

        // 发出信号（添加tags参数）
        uploadStarted(selectedVideoPath, videoTitle, videoDescription, selectedCoverPath, selectedTags)
        statusLog.text += "开始上传: " + getFileName(selectedVideoPath) + " 标签: " + selectedTags.join(", ") + "\n"

        // 开始上传
        uploader.uploadVideo(selectedVideoPath, videoTitle, videoDescription, selectedCoverPath)
    }

    // 工具函数
    function getFileName(filePath) {
        var path = filePath.toString().replace("file://", "");
        var lastSlash = path.lastIndexOf("/");
        return lastSlash >= 0 ? path.substring(lastSlash + 1) : path;
    }

    // 重置表单
    function resetForm() {
        selectedVideoPath = ""
        selectedCoverPath = ""
        videoTitle = ""
        videoDescription = ""
        selectedTags = []
        titleInput.text = ""
        descriptionInput.text = ""
        customTagInput.text = ""
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
