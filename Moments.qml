import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FrameLessWindow
{
    id:father
    width: 1200
    height: 800

    ColumnLayout
    {
        anchors.fill: parent

        // 顶部导航栏容器
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "white"

            RowLayout
            {
                anchors.fill: parent
                Text {
                    text: "bilibili"
                    width: 80
                    height: 50
                    font.pixelSize: 40
                    color: "pink"
                    font.bold: true
                    Layout.leftMargin: 20
                    Layout.topMargin: 10
                }

                Button {
                    id: zongheButton
                    Layout.preferredWidth: parent.width * 0.03
                    Layout.preferredHeight: father.height * 0.05

                    Layout.leftMargin: 30
                    Layout.topMargin: 10
                    text: "综合"

                    font.pixelSize: 15
                    Layout.alignment: Qt.AlignVCenter
                    contentItem: Text {
                        text:parent.text
                        font: parent.font
                        color : zongheButton.hovered || zongheButton.active ?  "pink" : "black"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }  //自定义字体格式
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            visible: zongheButton.active
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: "pink"
                        }
                    }
                    property bool active: true
                    onClicked: {
                        zongheButton.active = true
                        shipinButton.active = false
                    }
                 }

                Button {
                    id: shipinButton
                    Layout.preferredWidth: parent.width * 0.03
                    Layout.preferredHeight:father.height * 0.05
                    Layout.leftMargin: 30
                    Layout.topMargin: 10
                    text: "视频"

                    font.pixelSize: 15
                    Layout.alignment: Qt.AlignVCenter
                    contentItem: Text {
                        text:parent.text
                        font: parent.font
                        color : shipinButton.hovered || shipinButton.active ?  "pink" : "black"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }  //自定义字体格式
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            visible: shipinButton.active
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: "pink"
                        }
                    }
                    property bool active: false
                    onClicked: {
                        zongheButton.active = false
                        shipinButton.active = true
                    }
                 }

                Item {
                    Layout.fillWidth: true
                }

                TextField {
                    id: searchField
                    Layout.preferredWidth: parent.width * 0.2
                    Layout.preferredHeight: father.height * 0.04
                    Layout.topMargin: 10
                    placeholderText: "搜索你感兴趣的视频  🔍"
                    placeholderTextColor: "gray"
                    background: Rectangle {
                        color: "#F0F0F0"
                        radius: 4
                        border.color: searchField.activeFocus ? "pink" : "transparent"
                        border.width: 1
                    }
                    onActiveFocusChanged: {
                        if (activeFocus) {
                            placeholderText = ""
                        } else if (text === "") {
                            placeholderText = "搜索你感兴趣的视频  🔍"
                        }
                    }
                }

                Rectangle
                {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: father.height * 0.03
                    color: "grey"
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                }

                // 最小化按钮
                Button {
                    id: minimizeButton
                    Layout.preferredWidth: parent.width * 0.04
                    Layout.preferredHeight: parent.height * 0.7
                    text: "—"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter

                    contentItem: Text {
                        text:minimizeButton.text
                        font: minimizeButton.font
                        color: minimizeButton.hovered ? "white" : "grey"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 5
                        color: minimizeButton.down ? "#6A6A6A" : minimizeButton.hovered ? "#5A5A5A" : "transparent"
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: "最小化"
                    onClicked: {
                        father.visibility = Window.Minimized
                    }
                }

                // 最大化/还原按钮
                Button {
                    id: maximizeButton
                    Layout.preferredWidth: parent.width * 0.04
                    Layout.preferredHeight: parent.height * 0.7
                    text:father.visibility === Window.Maximized ? "❐" : "□"
                    font.pixelSize: 25
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                    contentItem: Text {
                        text:maximizeButton.text
                        font: maximizeButton.font
                        color: maximizeButton.hovered ? "white" : "grey"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 5
                        color: maximizeButton.down ? "#6A6A6A" : maximizeButton.hovered ? "#5A5A5A" : "transparent"
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: father.visibility === Window.Maximized ? "还原" : "最大化"
                    onClicked: {
                        if (father.visibility === Window.Maximized) {
                            father.visibility = Window.Windowed
                        } else {
                            father.visibility = Window.Maximized
                        }
                    }
                }

                // 关闭按钮
                Button {
                    id: closeButton
                    Layout.preferredWidth: parent.width * 0.04
                    Layout.preferredHeight: parent.height * 0.7
                    Layout.rightMargin: 20
                    font.pixelSize: 25
                    font.bold: true
                    text: "×"
                    Layout.alignment: Qt.AlignVCenter
                    contentItem: Text {
                        text:closeButton.text
                        font: closeButton.font
                        color: closeButton.hovered ? "white" : "grey"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 5
                        color: closeButton.down ? "#E81123" : closeButton.hovered ? "#F1707A" : "transparent"
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: "关闭"
                    onClicked: {
                        Qt.quit();
                    }
                 }
            }
        }

        // 主内容区域
        Rectangle
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#F5F5F5"

            // 左右分栏布局
            RowLayout {
                anchors.fill: parent
                spacing: 0

                // 左侧导航栏
                Rectangle {
                    Layout.preferredWidth: parent.width * 0.2
                    Layout.fillHeight: true
                    color: "white"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // 全部动态按钮
                        Button {
                            id: allDynamicButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            text: "全部动态"
                            font.pixelSize: 16
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: allDynamicButton.hovered || allDynamicButton.active ? "#FB7299" : "#666666"
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 20
                            }
                            background: Rectangle {
                                color: allDynamicButton.active ? "#FFF0F5" : "transparent"
                                Rectangle {
                                    visible: allDynamicButton.active
                                    width: 4
                                    height: parent.height
                                    color: "#FB7299"
                                }
                            }
                            property bool active: true
                            onClicked: {
                                allDynamicButton.active = true
                            }
                        }

                        // UP主列表标题
                        Text {
                            text: "关注UP主"
                            font.pixelSize: 14
                            color: "#999999"
                            Layout.leftMargin: 20
                            Layout.topMargin: 15
                            Layout.bottomMargin: 5
                        }

                        // UP主列表
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            Column {
                                id: upList
                                width: parent.width
                                spacing: 10

                                // UP主1
                                Rectangle {
                                    id: up1
                                    width: parent.width
                                    height: 60
                                    color: up1MouseArea.containsMouse ? "#F5F5F5" : "transparent"

                                    MouseArea {
                                        id: up1MouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            // 切换到该UP主的动态
                                        }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10

                                        // 头像
                                        Rectangle {
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40
                                            Layout.leftMargin: 15
                                            radius: 20
                                            color: "#E0E0E0"
                                        }

                                        // 用户名
                                        Text {
                                            text: "科技小新"
                                            font.pixelSize: 14
                                            Layout.fillWidth: true
                                        }

                                        // 新动态标记
                                        Rectangle {
                                            Layout.preferredWidth: 8
                                            Layout.preferredHeight: 8
                                            Layout.rightMargin: 15
                                            radius: 4
                                            color: "#FB7299"
                                            visible: true
                                        }
                                    }
                                }

                                // UP主2
                                Rectangle {
                                    id: up2
                                    width: parent.width
                                    height: 60
                                    color: up2MouseArea.containsMouse ? "#F5F5F5" : "transparent"

                                    MouseArea {
                                        id: up2MouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            // 切换到该UP主的动态
                                        }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10

                                        // 头像
                                        Rectangle {
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40
                                            Layout.leftMargin: 15
                                            radius: 20
                                            color: "#E0E0E0"
                                        }

                                        // 用户名
                                        Text {
                                            text: "美食家老王"
                                            font.pixelSize: 14
                                            Layout.fillWidth: true
                                        }

                                        // 新动态标记
                                        Rectangle {
                                            Layout.preferredWidth: 8
                                            Layout.preferredHeight: 8
                                            Layout.rightMargin: 15
                                            radius: 4
                                            color: "#FB7299"
                                            visible: false
                                        }
                                    }
                                }

                                // UP主3
                                Rectangle {
                                    id: up3
                                    width: parent.width
                                    height: 60
                                    color: up3MouseArea.containsMouse ? "#F5F5F5" : "transparent"

                                    MouseArea {
                                        id: up3MouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            // 切换到该UP主的动态
                                        }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10

                                        // 头像
                                        Rectangle {
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40
                                            Layout.leftMargin: 15
                                            radius: 20
                                            color: "#E0E0E0"
                                        }

                                        // 用户名
                                        Text {
                                            text: "游戏达人"
                                            font.pixelSize: 14
                                            Layout.fillWidth: true
                                        }

                                        // 新动态标记
                                        Rectangle {
                                            Layout.preferredWidth: 8
                                            Layout.preferredHeight: 8
                                            Layout.rightMargin: 15
                                            radius: 4
                                            color: "#FB7299"
                                            visible: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // 分隔线
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: "#E0E0E0"
                }

                // 右侧动态内容 (宽度80%)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#F5F5F5"

                    // 动态列表
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 15
                        clip: true

                        Column {
                            width: parent.width
                            spacing: 15

                            // 动态1
                            Rectangle {
                                id: dynamic1
                                width: parent.width
                                height: 300
                                radius: 8
                                color: dynamic1MouseArea.containsMouse ? "#F9F9F9" : "white"

                                MouseArea {
                                    id: dynamic1MouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        // 打开动态详情
                                    }
                                }

                                Column {
                                    width: parent.width - 20
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.margins: 15
                                    spacing: 15

                                    // 用户信息行
                                    RowLayout {
                                        width: parent.width

                                        // 头像
                                        Rectangle {
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40
                                            radius: 20
                                            color: "#E0E0E0"
                                        }

                                        // 用户名和时间
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            Text {
                                                text: "科技小新"
                                                font.bold: true
                                                font.pixelSize: 16
                                            }

                                            Text {
                                                text: "2小时前"
                                                font.pixelSize: 12
                                                color: "#999999"
                                            }
                                        }

                                        // 关注按钮
                                        Button {
                                            id: followButton1
                                            Layout.preferredWidth: 70
                                            Layout.preferredHeight: 30
                                            text: "已关注"
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                radius: 15
                                                color: followButton1.hovered ? "#F0F0F0" : "#F5F5F5"
                                                border.color: "#CCCCCC"
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#999999"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            onClicked: {
                                                text = text === "已关注" ? "+关注" : "已关注"
                                            }
                                        }
                                    }

                                    // 动态内容
                                    Text {
                                        width: parent.width
                                        text: "今天给大家开箱最新款手机，性能超强！摄像头升级明显，夜景模式效果惊艳。电池续航也很给力，重度使用一天没问题。"
                                        font.pixelSize: 14
                                        wrapMode: Text.Wrap
                                    }

                                    // 图片展示
                                    Row {
                                        width: parent.width
                                        spacing: 10

                                        Rectangle {
                                            width: 200
                                            height: 120
                                            color: "#F0F0F0"
                                        }

                                        Rectangle {
                                            width: 200
                                            height: 120
                                            color: "#F0F0F0"
                                        }
                                    }

                                    // 互动按钮行
                                    RowLayout {
                                        width: parent.width
                                        spacing: 15

                                        // 点赞
                                        Button {
                                            id: likeButton1
                                            Layout.preferredWidth: 80
                                            Layout.preferredHeight: 30
                                            background: Rectangle {
                                                color: "transparent"
                                            }
                                            contentItem: Row {
                                                spacing: 5
                                                Text {
                                                    text: "👍"
                                                    font.pixelSize: 16
                                                    color: likeButton1.active ? "#FB7299" : "#666666"
                                                }
                                                Text {
                                                    text: "1289"
                                                    font.pixelSize: 12
                                                    color: likeButton1.active ? "#FB7299" : "#666666"
                                                }
                                            }
                                            property bool active: false
                                            onClicked: {
                                                active = !active
                                            }
                                        }

                                        // 评论
                                        Button {
                                            Layout.preferredWidth: 80
                                            Layout.preferredHeight: 30
                                            background: Rectangle {
                                                color: "transparent"
                                            }
                                            contentItem: Row {
                                                spacing: 5
                                                Text {
                                                    text: "💬"
                                                    font.pixelSize: 16
                                                    color: "#666666"
                                                }
                                                Text {
                                                    text: "342"
                                                    font.pixelSize: 12
                                                    color: "#666666"
                                                }
                                            }
                                            onClicked: {
                                                // 打开评论
                                            }
                                        }

                                        // 转发
                                        Button {
                                            Layout.preferredWidth: 80
                                            Layout.preferredHeight: 30
                                            background: Rectangle {
                                                color: "transparent"
                                            }
                                            contentItem: Row {
                                                spacing: 5
                                                Text {
                                                    text: "↪"
                                                    font.pixelSize: 16
                                                    color: "#666666"
                                                }
                                                Text {
                                                    text: "56"
                                                    font.pixelSize: 12
                                                    color: "#666666"
                                                }
                                            }
                                            onClicked: {
                                                // 转发动态
                                            }
                                        }
                                    }
                                }
                            }

                            // 动态2
                            Rectangle {
                                id: dynamic2
                                width: parent.width
                                height: 300
                                radius: 8
                                color: dynamic2MouseArea.containsMouse ? "#F9F9F9" : "white"

                                MouseArea {
                                    id: dynamic2MouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        // 打开动态详情
                                    }
                                }

                                Column {
                                    width: parent.width - 20
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.margins: 15
                                    spacing: 15

                                    // 用户信息行
                                    RowLayout {
                                        width: parent.width

                                        // 头像
                                        Rectangle {
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40
                                            radius: 20
                                            color: "#E0E0E0"
                                        }

                                        // 用户名和时间
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            Text {
                                                text: "美食家老王"
                                                font.bold: true
                                                font.pixelSize: 16
                                            }

                                            Text {
                                                text: "4小时前"
                                                font.pixelSize: 12
                                                color: "#999999"
                                            }
                                        }

                                        // 关注按钮
                                        Button {
                                            id: followButton2
                                            Layout.preferredWidth: 70
                                            Layout.preferredHeight: 30
                                            text: "已关注"
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                radius: 15
                                                color: followButton2.hovered ? "#F0F0F0" : "#F5F5F5"
                                                border.color: "#CCCCCC"
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#999999"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            onClicked: {
                                                text = text === "已关注" ? "+关注" : "已关注"
                                            }
                                        }
                                    }

                                    // 动态内容
                                    Text {
                                        width: parent.width
                                        text: "发现一家超好吃的火锅店，强烈推荐！汤底浓郁，食材新鲜，特别是他们的招牌牛肉，入口即化。位置在市中心，交通便利。"
                                        font.pixelSize: 14
                                        wrapMode: Text.Wrap
                                    }

                                    // 图片展示
                                    Rectangle {
                                        width: parent.width
                                        height: 200
                                        color: "#F0F0F0"
                                    }

                                    // 互动按钮行
                                    RowLayout {
                                        width: parent.width
                                        spacing: 15

                                        // 点赞
                                        Button {
                                            id: likeButton2
                                            Layout.preferredWidth: 80
                                            Layout.preferredHeight: 30
                                            background: Rectangle {
                                                color: "transparent"
                                            }
                                            contentItem: Row {
                                                spacing: 5
                                                Text {
                                                    text: "👍"
                                                    font.pixelSize: 16
                                                    color: likeButton2.active ? "#FB7299" : "#666666"
                                                }
                                                Text {
                                                    text: "2456"
                                                    font.pixelSize: 12
                                                    color: likeButton2.active ? "#FB7299" : "#666666"
                                                }
                                            }
                                            property bool active: false
                                            onClicked: {
                                                active = !active
                                            }
                                        }

                                        // 评论
                                        Button {
                                            Layout.preferredWidth: 80
                                            Layout.preferredHeight: 30
                                            background: Rectangle {
                                                color: "transparent"
                                            }
                                            contentItem: Row {
                                                spacing: 5
                                                Text {
                                                    text: "💬"
                                                    font.pixelSize: 16
                                                    color: "#666666"
                                                }
                                                Text {
                                                    text: "189"
                                                    font.pixelSize: 12
                                                    color: "#666666"
                                                }
                                            }
                                            onClicked: {
                                                // 打开评论
                                            }
                                        }

                                        // 转发
                                        Button {
                                            Layout.preferredWidth: 80
                                            Layout.preferredHeight: 30
                                            background: Rectangle {
                                                color: "transparent"
                                            }
                                            contentItem: Row {
                                                spacing: 5
                                                Text {
                                                    text: "↪"
                                                    font.pixelSize: 16
                                                    color: "#666666"
                                                }
                                                Text {
                                                    text: "78"
                                                    font.pixelSize: 12
                                                    color: "#666666"
                                                }
                                            }
                                            onClicked: {
                                                // 转发动态
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
    }
}
