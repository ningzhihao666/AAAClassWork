// my.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: myPage
    //color: mainWindow.isDarkMode ? "#1a1a1a" : "#ffffff"           // 夜间模式

    property var mainWindow
    property string currentPage: "main" // 当前页面: "main", "history", "favorite", etc.

    // 页面数据模型
    ListModel {
        id: myPageModel
        ListElement {
            title: "历史记录"
            icon: "📜"
            count: "127"
            page: "history"
        }
        ListElement {
            title: "我的收藏"
            icon: "⭐"
            count: "86"
            page: "favorite"
        }
        ListElement {
            title: "稍后再看"
            icon: "⏰"
            count: "12"
            page: "watchlater"
        }
        ListElement {
            title: "高档缓存"
            icon: "💾"
            count: "5"
            page: "cache"
        }
        ListElement {
            title: "我的钱包"
            icon: "💰"
            count: "23"
            page: "wallet"
        }
        ListElement {
            title: "我的订单"
            icon: "📦"
            count: "8"
            page: "order"
        }
    }

    // 主页面 - 默认显示
    ScrollView {
        id: mainPage
        anchors.fill: parent
        visible: currentPage === "main"
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 0

            // 用户信息头部
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                color: mainWindow.isDarkMode ? "#252525" : "#f8f9fa"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    // 用户基本信息行
                    RowLayout {
                        spacing: 15

                        // 头像区域
                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 60
                            radius: 30
                            color: "transparent"
                            clip: true

                            Image {
                                id: userAvatar
                                anchors.fill: parent
                                source: userController.avatarUrl
                                        ? userController.avatarUrl + "?t=" + Date.now()
                                        : "https://i0.hdslb.com/bfs/face/member/noface.jpg"
                                fillMode: Image.PreserveAspectCrop
                                cache: false
                            }



                            // 头像边框
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                radius: 30
                                border.color: mainWindow.isDarkMode ? "#ff0000" : "#ff0000"
                                border.width: 10
                            }
                        }

                        // 用户信息
                        ColumnLayout {
                            spacing: 5
                            Layout.fillWidth: true

                            Text {
                                text: mainWindow.isLoggedIn ? mainWindow.username : "未登录用户"
                                font.pixelSize: 18
                                font.bold: true
                                color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                            }

                            Text {
                                text: mainWindow.isLoggedIn ? "UID: 80659548887" : "点击登录享受完整功能"
                                font.pixelSize: 14
                                color: mainWindow.isDarkMode ? "#a0a0a0" : "#666666"
                            }
                        }

                        // 登录/编辑资料按钮
                        Button {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            text: mainWindow.isLoggedIn ? "编辑资料" : "立即登录"
                            background: Rectangle {
                                color: parent.down ? "#e5457a" :
                                       parent.hovered ? "#fb85ab" : "#FB7299"
                                radius: 16
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                if (!mainWindow.isLoggedIn) {
                                    mainWindow.openLoginDialog()
                                } else {
                                    console.log("打开编辑资料")
                                }
                            }
                        }
                    }

                    // 数据统计行
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 30

                        Column {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2

                            Text {
                                text: "127"
                                font.pixelSize: 16
                                font.bold: true
                                color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "动态"
                                font.pixelSize: 12
                                color: mainWindow.isDarkMode ? "#a0a0a0" : "#666666"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Column {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2

                            Text {
                                text: "86"
                                font.pixelSize: 16
                                font.bold: true
                                color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "关注"
                                font.pixelSize: 12
                                color: mainWindow.isDarkMode ? "#a0a0a0" : "#666666"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Column {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2

                            Text {
                                text: "234"
                                font.pixelSize: 16
                                font.bold: true
                                color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "粉丝"
                                font.pixelSize: 12
                                color: mainWindow.isDarkMode ? "#a0a0a0" : "#666666"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }

            // 主要功能区域
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 20
                color: "transparent"

                ColumnLayout {
                    width: parent.width
                    spacing: 0

                    // 功能标题
                    Text {
                        Layout.leftMargin: 20
                        Layout.bottomMargin: 15
                        text: "我的服务"
                        font.pixelSize: 16
                        font.bold: true
                        color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                    }

                    // 功能网格 - 3列布局
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        columns: 3
                        rowSpacing: 10
                        columnSpacing: 10

                        Repeater {
                            model: myPageModel

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 100
                                color: mouseArea.containsMouse ?
                                       (mainWindow.isDarkMode ? "#2d2d2d" : "#f5f5f5") : "transparent"
                                radius: 8

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    width: parent.width - 20

                                    Text {
                                        text: icon
                                        font.pixelSize: 28
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: title
                                        font.pixelSize: 14
                                        color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: count + "条内容"
                                        font.pixelSize: 12
                                        color: mainWindow.isDarkMode ? "#a0a0a0" : "#666666"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        console.log("点击:", title)
                                        navigateToPage(page)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 底部间距
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
            }
        }
    }

    // 历史记录页面
    ColumnLayout {
        id: historyPage
        anchors.fill: parent
        visible: currentPage === "history"
        spacing: 0

        // 顶部导航栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: mainWindow.isDarkMode ? "#252525" : "#f8f9fa"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 15

                // 返回按钮
                Button {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    text: "← 返回"
                    background: Rectangle {
                        color: parent.down ? "#e0e0e0" :
                               parent.hovered ? "#f0f0f0" : "transparent"
                        radius: 16
                    }
                    contentItem: Text {
                        text: parent.text
                        color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: navigateToPage("main")
                }

                Text {
                    text: "历史记录"
                    font.pixelSize: 18
                    font.bold: true
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                    Layout.fillWidth: true
                }
            }
        }

        // 页面内容
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 10
                //padding: 20

                Text {
                    text: "历史记录页面内容"
                    font.pixelSize: 16
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                }

                // 这里可以添加历史记录的具体内容
                Repeater {
                    model: 10
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        color: mainWindow.isDarkMode ? "#2d2d2d" : "#f8f9fa"
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: "#FB7299"
                                radius: 4
                            }

                            ColumnLayout {
                                spacing: 5
                                Layout.fillWidth: true

                                Text {
                                    text: "视频标题 " + (index + 1)
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "UP主名称 • 观看时间: 2024-01-" + (index + 1).toString().padStart(2, '0')
                                    font.pixelSize: 12
                                    color: mainWindow.isDarkMode ? "#a0a0a0" : "#666666"
                                }
                            }
                        }
                    }
                }
            }
        }
    }



    // 我的收藏页面
    ColumnLayout {
        id: favoritePage
        anchors.fill: parent
        visible: currentPage === "favorite"
        spacing: 0

        // 顶部导航栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: mainWindow.isDarkMode ? "#252525" : "#f8f9fa"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 15

                Button {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    text: "← 返回"
                    background: Rectangle {
                        color: parent.down ? "#e0e0e0" :
                               parent.hovered ? "#f0f0f0" : "transparent"
                        radius: 16
                    }
                    contentItem: Text {
                        text: parent.text
                        color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: navigateToPage("main")
                }

                Text {
                    text: "我的收藏"
                    font.pixelSize: 18
                    font.bold: true
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                    Layout.fillWidth: true
                }
            }
        }

        // 页面内容
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 10
                //padding: 20

                Text {
                    text: "我的收藏页面内容"
                    font.pixelSize: 16
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                }

                // 这里可以添加收藏的具体内容
                Repeater {
                    model: 8
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: mainWindow.isDarkMode ? "#2d2d2d" : "#f8f9fa"
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 60
                                color: "#FFB11B"
                                radius: 4
                            }

                            ColumnLayout {
                                spacing: 5
                                Layout.fillWidth: true

                                Text {
                                    text: "收藏夹 " + (index + 1)
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                                }

                                Text {
                                    text: (index + 5) + "个视频"
                                    font.pixelSize: 12
                                    color: mainWindow.isDarkMode ? "#a0a0a0" : "#666666"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 稍后再看页面
    ColumnLayout {
        id: watchLaterPage
        anchors.fill: parent
        visible: currentPage === "watchlater"
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: mainWindow.isDarkMode ? "#252525" : "#f8f9fa"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 15

                Button {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    text: "← 返回"
                    background: Rectangle {
                        color: parent.down ? "#e0e0e0" :
                               parent.hovered ? "#f0f0f0" : "transparent"
                        radius: 16
                    }
                    contentItem: Text {
                        text: parent.text
                        color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: navigateToPage("main")
                }

                Text {
                    text: "稍后再看"
                    font.pixelSize: 18
                    font.bold: true
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                    Layout.fillWidth: true
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 10
                //padding: 20

                Text {
                    text: "稍后再看页面内容"
                    font.pixelSize: 16
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                }
            }
        }
    }

    // 高档缓存页面
    ColumnLayout {
        id: cachePage
        anchors.fill: parent
        visible: currentPage === "cache"
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: mainWindow.isDarkMode ? "#252525" : "#f8f9fa"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 15

                Button {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    text: "← 返回"
                    background: Rectangle {
                        color: parent.down ? "#e0e0e0" :
                               parent.hovered ? "#f0f0f0" : "transparent"
                        radius: 16
                    }
                    contentItem: Text {
                        text: parent.text
                        color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: navigateToPage("main")
                }

                Text {
                    text: "高档缓存"
                    font.pixelSize: 18
                    font.bold: true
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                    Layout.fillWidth: true
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 10
                //padding: 20

                Text {
                    text: "高档缓存页面内容"
                    font.pixelSize: 16
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                }
            }
        }
    }

    // 我的钱包页面
    ColumnLayout {
        id: walletPage
        anchors.fill: parent
        visible: currentPage === "wallet"
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: mainWindow.isDarkMode ? "#252525" : "#f8f9fa"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 15

                Button {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    text: "← 返回"
                    background: Rectangle {
                        color: parent.down ? "#e0e0e0" :
                               parent.hovered ? "#f0f0f0" : "transparent"
                        radius: 16
                    }
                    contentItem: Text {
                        text: parent.text
                        color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: navigateToPage("main")
                }

                Text {
                    text: "我的钱包"
                    font.pixelSize: 18
                    font.bold: true
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                    Layout.fillWidth: true
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 10
                //padding: 20

                Text {
                    text: "我的钱包页面内容"
                    font.pixelSize: 16
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                }
            }
        }
    }

    // 我的订单页面
    ColumnLayout {
        id: orderPage
        anchors.fill: parent
        visible: currentPage === "order"
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: mainWindow.isDarkMode ? "#252525" : "#f8f9fa"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 15

                Button {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    text: "← 返回"
                    background: Rectangle {
                        color: parent.down ? "#e0e0e0" :
                               parent.hovered ? "#f0f0f0" : "transparent"
                        radius: 16
                    }
                    contentItem: Text {
                        text: parent.text
                        color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: navigateToPage("main")
                }

                Text {
                    text: "我的订单"
                    font.pixelSize: 18
                    font.bold: true
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                    Layout.fillWidth: true
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 10
                //padding: 20

                Text {
                    text: "我的订单页面内容"
                    font.pixelSize: 16
                    color: mainWindow.isDarkMode ? "#e0e0e0" : "#333333"
                }
            }
        }
    }

    // 导航到指定页面
    function navigateToPage(page) {
        console.log("导航到页面:", page)
        currentPage = page

    }

    // 设置主窗口引用
    function setMainWindow(window) {
        mainWindow = window
    }

    Component.onCompleted: {
        console.log("我的页面加载完成")
    }
}
