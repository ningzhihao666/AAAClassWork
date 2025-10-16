import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FrameLessWindow {
    id: root
    width: 1100
    height: 800

    // 全局头像URL属性
    property string globalAvatarUrl: "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"

    // 状态管理属性
    property string currentLeftMenuItem: ""
    property string currentTopNavItem: "推荐"
    property bool showPersonInfo: false

    // 头像路径处理函数
    function processAvatarUrl(url) {
        if (!url || url === "") {
            return "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"
        }

        console.log("原始头像URL:", url)

        if (url.startsWith("file:///")) {
            console.log("已经是file:///格式，直接使用")
            return url
        }

        if (url.startsWith("http://") || url.startsWith("https://")) {
            console.log("网络URL，直接使用")
            return url
        }

        var processedUrl = "file:///" + url
        console.log("本地路径处理后URL:", processedUrl)
        return processedUrl
    }

    // 当全局头像URL改变时，强制更新侧边栏头像
    onGlobalAvatarUrlChanged: {
        console.log("全局头像URL更新为:", globalAvatarUrl)
        leftSideBar.forceUpdateAvatar()
    }

    // 左侧边栏
    Rectangle {
        id: leftSideBar
        width: 200
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        color: "#f0f0f0"
        z: 100

        // 强制更新头像的函数
        function forceUpdateAvatar() {
        console.log("强制更新侧边栏头像")
        let processedUrl = root.processAvatarUrl(root.globalAvatarUrl)
        console.log("更新头像为:", processedUrl)
        userInfoArea.avatarImage.source = processedUrl
        }

        ColumnLayout {
            spacing: 10
            anchors.fill: parent

            Button {
                id: backButton
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "← 返回"
                flat: true
                font.pixelSize: 14
                background: Rectangle {
                    color: backButton.hovered ? "#e0e0e0" : "transparent"
                }
                onClicked: {
                    console.log("点击返回按钮")
                    root.showPersonInfo = false
                    root.currentLeftMenuItem = ""
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                spacing: 5

                Text {
                    text: "常用功能"
                    font.pixelSize: 12
                    color: "#999"
                    Layout.leftMargin: 15
                    Layout.topMargin: 10
                }

                Repeater {
                    model: [
                        {text: "首页", icon: "🏠"},
                        {text: "精选", icon: "⭐"},
                        {text: "动态", icon: "📱"},
                        {text: "我的", icon: "👤"}
                    ]

                    delegate: Rectangle {
                        id: menuItem
                        width: leftSideBar.width
                        height: 50
                        Layout.preferredHeight: 50
                        color: getBackgroundColor()

                        function getBackgroundColor() {
                            if (root.currentLeftMenuItem === modelData.text) {
                                return "#e0e0e0"
                            } else if (tapHandler.pressed) {
                                return "#d8d8d8"
                            }
                            return "transparent"
                        }

                        Row {
                            anchors.fill: parent
                            spacing: 10
                            leftPadding: 15

                            Text {
                                text: modelData.icon
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.text
                                color: root.currentLeftMenuItem === modelData.text ? "#FB7299" : "#333"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        TapHandler {
                            id: tapHandler
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.Touch
                            gesturePolicy: TapHandler.ReleaseWithinBounds

                            onTapped: {
                                console.log("点击菜单项:", modelData.text)
                                root.currentLeftMenuItem = modelData.text

                                if (modelData.text === "我的") {
                                    root.showPersonInfo = true
                                }
                                if(modelData.text === "首页"){
                                    root.showPersonInfo =false
                                    root.currentLeftMenuItem = ""
                                }
                            }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#d0d0d0"
                Layout.topMargin: 10
                Layout.bottomMargin: 10
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                spacing: 5

                Rectangle {
                    id: userInfoArea
                    width: leftSideBar.width
                    height: 80
                    Layout.preferredHeight: 80
                    color: "transparent"

                    Row {
                        anchors.fill: parent
                        spacing: 10
                        leftPadding: 15

                        Rectangle {
                            width: 50
                            height: 50
                            radius: 25
                            color: "transparent"
                            anchors.verticalCenter: parent.verticalCenter
                            clip: true

                            Image {
                                id: avatarImage
                                anchors.fill: parent
                                source: root.processAvatarUrl(root.globalAvatarUrl)
                                fillMode: Image.PreserveAspectCrop
                                cache: false

                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        source = "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"
                                    }
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                id:username
                                text: "用户名"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Text {
                                text: "查看个人主页"
                                font.pixelSize: 12
                                color: "#666"
                            }
                        }
                    }

                    TapHandler {
                        onTapped: {
                            console.log("点击用户信息")
                            root.currentLeftMenuItem = "用户信息"
                            root.showPersonInfo = true
                        }
                    }
                }

                Repeater {
                    model: [
                        {text: "朋友圈", icon: "📝"},
                        {text: "上传视频", icon: "📹"},
                        {text: "消息", icon: "✉️"},
                        {text: "夜间模式", icon: "🌙"},
                        {text: "设置", icon: "⚙️"}
                    ]

                    delegate: Rectangle {
                        id: bottomMenuItem
                        width: leftSideBar.width
                        height: 50
                        Layout.preferredHeight: 50
                        color: getBackgroundColor()

                        function getBackgroundColor() {
                            if (root.currentLeftMenuItem === modelData.text) {
                                return "#e0e0e0"
                            } else if (bottomTapHandler.pressed) {
                                return "#d8d8d8"
                            }
                            return "transparent"
                        }

                        Row {
                            anchors.fill: parent
                            spacing: 10
                            leftPadding: 15

                            Text {
                                text: modelData.icon
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.text
                                color: root.currentLeftMenuItem === modelData.text ? "#FB7299" : "#333"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        TapHandler {
                            id: bottomTapHandler
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.Touch
                            gesturePolicy: TapHandler.ReleaseWithinBounds

                            onTapped: {
                                console.log("点击菜单项:", modelData.text)
                                root.currentLeftMenuItem = modelData.text
                                root.showPersonInfo = false
                            }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

    // 顶部区域
    Rectangle {
        id: topBar
        width: parent.width - leftSideBar.width
        height: 60
        color: "white"
        anchors {
            top: parent.top
            left: leftSideBar.right
        }

        RowLayout {
            anchors.fill: parent
            anchors.topMargin: 20
            anchors.rightMargin: 10
            spacing: 10

            Label{
                id: bili_icon
                anchors.left: parent.left
                anchors.leftMargin: 10
                text: "bilibili"
                color: "pink"
                font.pixelSize: 14
                width: 30
                height: 30
            }

            Row {
                id: funcRegion
                spacing: 10
                Layout.fillWidth: true
                visible: !root.showPersonInfo

                property real itemWidth: (width - (navRepeater.count - 1) * spacing) / navRepeater.count

                Repeater {
                    id: navRepeater
                    model: ["推荐", "热门", "追番", "影视", "漫画", "赛事", "直播"]

                    delegate: Rectangle {
                        id: navItem
                        width: funcRegion.itemWidth
                        height: 40
                        radius: 4
                        color: getBackgroundColor()

                        function getBackgroundColor() {
                            if (root.currentTopNavItem === modelData) {
                                return "#FB7299"
                            } else if (navTapHandler.pressed) {
                                return "#f5f5f5"
                            }
                            return "white"
                        }

                        Text {
                            text: modelData
                            anchors.centerIn: parent
                            color: root.currentTopNavItem === modelData ? "white" : "black"
                            font.pixelSize: 13
                        }

                        TapHandler {
                            id: navTapHandler
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.Touch
                            gesturePolicy: TapHandler.ReleaseWithinBounds

                            onTapped: {
                                console.log("点击顶部导航项:", modelData)
                                root.currentTopNavItem = modelData
                            }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                }
            }

            TextField {
                id: search
                Layout.preferredWidth: 250
                Layout.preferredHeight: 40
                anchors.rightMargin: 20
                anchors.right: line.left
                visible: true

                placeholderText: "搜索你感兴趣的视频  🔍"
                placeholderTextColor: "gray"
                background: Rectangle {
                    color: "#F0F0F0"
                    border.color: search.focus ? "#00BFFF" : "transparent"
                    radius: 4
                }

                Button{
                    id: clearButton
                    background: Rectangle {
                        color: clearButton.hovered ? "lightgray" : "#F0F0F0"
                    }
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text: "×"
                    onClicked: search.text = ""
                    opacity: search.focus ? 1 : 0
                }
            }

            Rectangle {
                id: line
                anchors.right: controls.left
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                visible: true
                Text {
                    anchors.centerIn: parent
                    text: "|"
                    font.pixelSize: 20
                    color: "lightgray"
                }
            }

            RowLayout {
                id: controls
                spacing: 10
                anchors.right: parent.right
                Layout.rightMargin: 20
                visible: true

                Button {
                    id: minimizeButton
                    text: "—"
                    flat: true
                    width: 40
                    height: 40
                    background: Rectangle {
                        color: minimizeButton.hovered ? "#E5E9EF" : "transparent"
                        radius: 4
                    }
                    onClicked: root.showMinimized()
                }

                Button {
                    id: maximizeButton
                    text: root.visibility === Window.Maximized ? "❐" : "□"
                    flat: true
                    width: 40
                    height: 40
                    background: Rectangle {
                        color: maximizeButton.hovered ? "#E5E9EF" : "transparent"
                        radius: 4
                    }
                    onClicked: {
                        if (root.visibility === Window.Maximized)
                            root.showNormal()
                        else
                            root.showMaximized()
                    }
                }

                Button {
                    id: closeButton
                    text: "×"
                    flat: true
                    width: 40
                    height: 40
                    background: Rectangle {
                        color: closeButton.hovered ? "#FF4D4F" : "transparent"
                        radius: 4
                    }
                    onClicked: Qt.quit()
                }
            }
        }
    }

    // 内容区域
    Item {
        id: contentContainer
        anchors {
            top: topBar.bottom
            left: leftSideBar.right
            right: parent.right
            bottom: parent.bottom
        }

        ScrollView {
            id: contentScrollView
            anchors.fill: parent
            visible: !root.showPersonInfo
            contentWidth: availableWidth
            clip: true
            padding: 20

            ColumnLayout {
                width: root.width - leftSideBar.width - 15
                spacing: 20

                GridView {
                    id: videoGrid
                    Layout.fillWidth: true
                    height: 1200
                    cellWidth: (width - 30) / 4
                    cellHeight: 220
                    clip: true
                    model: 12

                    delegate: Rectangle {
                        width: videoGrid.cellWidth - 10
                        height: videoGrid.cellHeight - 10
                        color: "white"
                        radius: 4
                        border.color: "#E5E9EF"

                        Column {
                            anchors {
                                fill: parent
                                margins: 10
                            }
                            spacing: 8

                            Rectangle {
                                width: parent.width
                                height: 120
                                color: "lightgray"
                                radius: 4

                                Text {
                                    text: "封面图 " + (index + 1)
                                    anchors.centerIn: parent
                                    color: "gray"
                                }
                            }

                            Text {
                                width: parent.width
                                text: "【超燃】这是第 " + (index + 1) + " 个推荐视频标题"
                                font.pixelSize: 14
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                maximumLineCount: 2
                            }

                            Row {
                                spacing: 8

                                Image {
                                    source:"https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"
                                    width: 24
                                    height: 24
                                }

                                Text {
                                    text: "UP主名称"
                                    font.pixelSize: 12
                                    color: "#999"
                                }

                                Text {
                                    text: "▶ 12.3万"
                                    font.pixelSize: 12
                                    color: "#999"
                                }
                            }
                        }

                        TapHandler {
                            onTapped: console.log("点击视频项:", index + 1)
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "white"
                    radius: 4
                    border.color: "#E5E9EF"

                    Text {
                        text: "加载更多..."
                        anchors.centerIn: parent
                        color: "#FB7299"
                        font.pixelSize: 14
                    }

                    TapHandler {
                        onTapped: console.log("加载更多视频")
                    }
                }
            }
        }

        Loader {
            id: personInfoLoader
            anchors.fill: parent
            visible: root.showPersonInfo
            source: root.showPersonInfo ? "PersonInfo.qml" : ""
            active: root.showPersonInfo

            onLoaded: {
                console.log("个人信息界面加载完成")
                // 直接设置头像URL，确保同步
                personInfoLoader.item.setMainAvatarUrl(root.globalAvatarUrl)
            }
        }
    }
}
