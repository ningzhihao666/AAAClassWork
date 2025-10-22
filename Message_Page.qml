//消息页面

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id:messageWindow
    width: 1200
    height: 800

    signal closeRequested()

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // 左侧菜单
        ColumnLayout {
            Layout.preferredWidth: 100
            Layout.fillHeight: true
            spacing: 0

            // 标题
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#f8f9fa"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    spacing: 8

                    Text { text: "✈️"; font.pixelSize: 20 }
                    Text {
                        text: "消息中心"
                        font.bold: true
                        font.pixelSize: 16
                    }
                }
            }

            // 消息列表
            ListView {
                id: leftMenu
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ListModel {
                    ListElement { name: "我的消息" }
                    ListElement { name: "回复我的" }
                    ListElement { name: "@我的" }
                    ListElement { name: "收到的赞" }
                    ListElement { name: "系统通知" }
                    ListElement { name: "separator" }
                    ListElement { name: "消息设置" }
                }
                currentIndex: 0
                delegate: Item {
                    width: ListView.view.width
                    height: model.name === "separator" ? 20 : 50

                    Rectangle {
                        visible: model.name === "separator"
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 1
                            color: "#e0e0e0"
                        }
                    }

                    Rectangle {
                        visible: model.name !== "separator"
                        width: parent.width
                        height: 50
                        color: leftMenu.currentIndex === index ? "#e3f2fd" : "transparent"

                        Text {
                            text: model.name
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            font.pixelSize: 14
                            color: leftMenu.currentIndex === index ? "#1976d2" : "black"
                        }

                        Button{
                            anchors.fill: parent
                            background: Rectangle{ color:"transparent" }

                            onClicked: {
                                leftMenu.currentIndex = index
                                if (model.name === "我的消息") rightContent.visible=true
                                    else rightContent.visible=false
                                if (model.name==="回复我的")  replyContent.visible=true
                                    else replyContent.visible=false
                                if (model.name==="@我的")  atMeContent.visible=true
                                    else atMeContent.visible=false
                                if (model.name==="收到的赞")  likesContent.visible=true
                                    else likesContent.visible=false
                                if (model.name==="系统通知")  systemNotificationContent.visible=true
                                    else systemNotificationContent.visible=false
                                if (model.name==="消息设置")  messageSettingsContent.visible=true
                                    else messageSettingsContent.visible=false
                            }
                        }
                    }
                }
            }
            // === 底部返回按钮 ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#f8f9fa"
                border.color: "#e0e0e0"
                border.width: 1

                Button {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: 40
                    text: "← 返回"
                    background: Rectangle {
                        color: parent.down ? "#e0e0e0" : "#ffffff"
                        border.color: "#d0d0d0"
                        border.width: 1
                        radius: 6
                    }

                    onClicked: {
                        console.log("返回按钮被点击")
                        //messageWindow.close()
                        onClicked: {
                            closeRequested() // 发出关闭信号
                        }
                    }
                }
            }
        }

        // 右侧内容区域
        Rectangle {
            id: rightContent
            Layout.preferredWidth: 1000
            Layout.fillHeight: true
            visible: true
            color: "#ffffff"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 顶部标题栏
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#f5f5f5"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "我的消息"
                        font.bold: true
                        font.pixelSize: 18
                        color: "#333333"
                    }
                }

                // 主要内容区域
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    // 左侧联系人列表
                    Rectangle {
                        Layout.preferredWidth: 250
                        Layout.fillHeight: true
                        color: "#fafafa"
                        border.color: "#e0e0e0"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            // 联系人列表标题
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                color: "#f0f0f0"

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 15
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "消息列表"
                                    font.bold: true
                                    font.pixelSize: 16
                                    color: "#333333"
                                }
                            }

                            // 联系人列表
                            ListView {
                                id: contactList
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                model: ListModel {
                                    ListElement { name: "张三"; avatar: "👦"; lastMessage: "你好，最近怎么样？" }
                                    ListElement { name: "李四"; avatar: "👧"; lastMessage: "项目进展如何？" }
                                    ListElement { name: "王五"; avatar: "👨"; lastMessage: "晚上一起吃饭吗？" }
                                    ListElement { name: "赵六"; avatar: "👩"; lastMessage: "会议资料已发送" }
                                }
                                currentIndex: 0  // 默认选中第一个联系人
                                delegate: Rectangle {
                                    width: contactList.width
                                    height: 70
                                    color: contactList.currentIndex === index ? "#e3f2fd" : "transparent"
                                    border.color: "#f0f0f0"
                                    border.width: 1

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10

                                        // 用户头像
                                        Rectangle {
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40
                                            radius: 20
                                            color: "#e3f2fd"

                                            Text {
                                                anchors.centerIn: parent
                                                text: avatar
                                                font.pixelSize: 18
                                            }
                                        }

                                        // 用户信息
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            spacing: 4

                                            Text {
                                                text: name
                                                font.bold: true
                                                font.pixelSize: 14
                                                color: "#333333"
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                text: lastMessage
                                                font.pixelSize: 12
                                                color: "#666666"
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            contactList.currentIndex = index
                                            chatArea.visible = true
                                        }
                                    }
                                }

                                // 组件加载完成后自动显示聊天区域
                                Component.onCompleted: {
                                    if (count > 0) {
                                        chatArea.visible = true
                                    }
                                }
                            }
                        }
                    }

                    // 右侧聊天区域
                    Rectangle {
                        id: chatArea
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: true
                        color: "#ffffff"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            // 聊天标题栏
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: "#f8f9fa"
                                border.color: "#e0e0e0"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Text {
                                        text: contactList.currentIndex >= 0 ? contactList.model.get(contactList.currentIndex).avatar : "👦"
                                        font.pixelSize: 20
                                    }

                                    Text {
                                        text: contactList.currentIndex >= 0 ? contactList.model.get(contactList.currentIndex).name : "用户名"
                                        font.bold: true
                                        font.pixelSize: 16
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            // 聊天消息区域
                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                background: Rectangle { color: "#f5f5f5" }

                                TextArea {
                                    id: messageDisplay
                                    readOnly: true
                                    text: {
                                        if (contactList.currentIndex >= 0) {
                                            var contactName = contactList.model.get(contactList.currentIndex).name
                                            return "与 " + contactName + " 的对话\n\n" +
                                                   contactName + ": " + contactList.model.get(contactList.currentIndex).lastMessage + "\n" +
                                                   "我: 你好！"
                                        } else {
                                            return "这里是聊天消息区域\n\n点击左侧联系人开始聊天"
                                        }
                                    }
                                    wrapMode: TextArea.Wrap
                                    background: null
                                    font.pixelSize: 14
                                    color: "#333333"
                                }
                            }

                            // 消息输入区域
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 80
                                color: "#ffffff"
                                border.color: "#e0e0e0"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    TextField {
                                        id: messageInput
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        placeholderText: "输入消息..."
                                        font.pixelSize: 14
                                    }

                                    Button {
                                        text: "发送"
                                        Layout.preferredHeight: 40
                                        Layout.preferredWidth: 80
                                        onClicked: {
                                            if (messageInput.text.trim() !== "") {
                                                var currentTime = new Date().toLocaleTimeString()
                                                messageDisplay.text += "\n[" + currentTime + "] 我: " + messageInput.text
                                                messageInput.text = ""
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

        // === 新增：回复我的内容区域 ===
        Rectangle {
            id: replyContent
            Layout.preferredWidth: 1000
            Layout.fillHeight: true
            visible: false
            color: "#ffffff"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 顶部标题栏
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#f5f5f5"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "回复我的"
                        font.bold: true
                        font.pixelSize: 18
                        color: "#333333"
                    }
                }

                // 回复列表
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    background: Rectangle { color: "#fafafa" }

                    ColumnLayout {
                        width: parent.width
                        spacing: 1

                        // 回复项1
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#e3f2fd"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👦"
                                        font.pixelSize: 20
                                    }
                                }

                                // 回复内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和操作类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "张三"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "回复了我的评论"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // 评论内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#f8f9fa"
                                        radius: 6

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "这个视频拍得真棒！景色太美了，我也想去那里旅行。"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-12-01 14:30"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }

                                        Button {
                                            text: "回复"
                                            Layout.preferredHeight: 28
                                            Layout.preferredWidth: 60
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                color: parent.down ? "#e0e0e0" : "#f0f0f0"
                                                radius: 4
                                            }

                                            onClicked: {
                                                console.log("回复按钮被点击")
                                            }
                                        }

                                        Button {
                                            text: "♥ 12"
                                            Layout.preferredHeight: 28
                                            Layout.preferredWidth: 70
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                color: parent.down ? "#e0e0e0" : "#f0f0f0"
                                                radius: 4
                                            }

                                            onClicked: {
                                                console.log("点赞按钮被点击")
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 回复项2
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#ffeef0"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👧"
                                        font.pixelSize: 20
                                    }
                                }

                                // 回复内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和操作类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "李四"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "回复了我的视频"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // 评论内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#f8f9fa"
                                        radius: 6

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "视频里的配乐很好听，和画面很搭配！请问是什么音乐？"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-11-28 09:15"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }

                                        Button {
                                            text: "回复"
                                            Layout.preferredHeight: 28
                                            Layout.preferredWidth: 60
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                color: parent.down ? "#e0e0e0" : "#f0f0f0"
                                                radius: 4
                                            }

                                            onClicked: {
                                                console.log("回复按钮被点击")
                                            }
                                        }

                                        Button {
                                            text: "♥ 8"
                                            Layout.preferredHeight: 28
                                            Layout.preferredWidth: 70
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                color: parent.down ? "#e0e0e0" : "#f0f0f0"
                                                radius: 4
                                            }

                                            onClicked: {
                                                console.log("点赞按钮被点击")
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 回复项3
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#f0f4ff"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👨"
                                        font.pixelSize: 20
                                    }
                                }

                                // 回复内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和操作类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "王五"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "回复了我的评论"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // 评论内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#f8f9fa"
                                        radius: 6

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "同意你的观点，这个地方确实值得一去，我上个月刚去过。"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-11-25 16:45"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }

                                        Button {
                                            text: "回复"
                                            Layout.preferredHeight: 28
                                            Layout.preferredWidth: 60
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                color: parent.down ? "#e0e0e0" : "#f0f0f0"
                                                radius: 4
                                            }

                                            onClicked: {
                                                console.log("回复按钮被点击")
                                            }
                                        }

                                        Button {
                                            text: "♥ 15"
                                            Layout.preferredHeight: 28
                                            Layout.preferredWidth: 70
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                color: parent.down ? "#e0e0e0" : "#f0f0f0"
                                                radius: 4
                                            }

                                            onClicked: {
                                                console.log("点赞按钮被点击")
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

        // === 新增：@我的内容区域 ===
        Rectangle {
            id: atMeContent
            Layout.preferredWidth: 1000
            Layout.fillHeight: true
            visible: false
            color: "#ffffff"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 顶部标题栏
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#f5f5f5"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "@我的"
                        font.bold: true
                        font.pixelSize: 18
                        color: "#333333"
                    }
                }

                // @我的列表
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    background: Rectangle { color: "#fafafa" }

                    ColumnLayout {
                        width: parent.width
                        spacing: 1

                        // @我的项1
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 130
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#e3f2fd"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👦"
                                        font.pixelSize: 20
                                    }
                                }

                                // @我的内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和操作类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "张三"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "在评论中@了我"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // @我的评论内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 50
                                        color: "#f0f7ff"
                                        radius: 6
                                        border.color: "#d1e9ff"
                                        border.width: 1

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "@旅行达人 这个景点怎么去最方便？有没有推荐的交通方式？"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-12-05 10:30"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }

                                        Button {
                                            text: "回复"
                                            Layout.preferredHeight: 28
                                            Layout.preferredWidth: 60
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                color: parent.down ? "#e0e0e0" : "#f0f0f0"
                                                radius: 4
                                            }

                                            onClicked: {
                                                console.log("回复@我的消息")
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // @我的项2
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 130
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#ffeef0"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👧"
                                        font.pixelSize: 20
                                    }
                                }

                                // @我的内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和操作类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "李四"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "在视频评论中@了我"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // @我的评论内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 50
                                        color: "#f0f7ff"
                                        radius: 6
                                        border.color: "#d1e9ff"
                                        border.width: 1

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "@旅行达人 你上次推荐的这个地方太美了！我也去打卡了，感谢分享！"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-12-03 15:20"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }

                                        Button {
                                            text: "回复"
                                            Layout.preferredHeight: 28
                                            Layout.preferredWidth: 60
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                color: parent.down ? "#e0e0e0" : "#f0f0f0"
                                                radius: 4
                                            }

                                            onClicked: {
                                                console.log("回复@我的消息")
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // @我的项3
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 130
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#f0f4ff"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👨"
                                        font.pixelSize: 20
                                    }
                                }

                                // @我的内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和操作类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "王五"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "在帖子中@了我"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // @我的评论内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 50
                                        color: "#f0f7ff"
                                        radius: 6
                                        border.color: "#d1e9ff"
                                        border.width: 1

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "@旅行达人 请问这个季节去合适吗？天气怎么样？需要准备什么？"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-11-30 08:45"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }

                                        Button {
                                            text: "回复"
                                            Layout.preferredHeight: 28
                                            Layout.preferredWidth: 60
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                color: parent.down ? "#e0e0e0" : "#f0f0f0"
                                                radius: 4
                                            }

                                            onClicked: {
                                                console.log("回复@我的消息")
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // @我的项4
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 130
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#f3e5f5"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👩"
                                        font.pixelSize: 20
                                    }
                                }

                                // @我的内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和操作类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "赵六"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "在回答中@了我"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // @我的评论内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 50
                                        color: "#f0f7ff"
                                        radius: 6
                                        border.color: "#d1e9ff"
                                        border.width: 1

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "@旅行达人 我觉得你说的很对！这个地方确实值得推荐给大家"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-11-28 19:15"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }

                                        Button {
                                            text: "回复"
                                            Layout.preferredHeight: 28
                                            Layout.preferredWidth: 60
                                            font.pixelSize: 12
                                            background: Rectangle {
                                                color: parent.down ? "#e0e0e0" : "#f0f0f0"
                                                radius: 4
                                            }

                                            onClicked: {
                                                console.log("回复@我的消息")
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

        // === 新增：收到的赞内容区域 ===
        Rectangle {
            id: likesContent
            Layout.preferredWidth: 1000
            Layout.fillHeight: true
            visible: false
            color: "#ffffff"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 顶部标题栏
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#f5f5f5"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "收到的赞"
                        font.bold: true
                        font.pixelSize: 18
                        color: "#333333"
                    }
                }

                // 点赞列表
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    background: Rectangle { color: "#fafafa" }

                    ColumnLayout {
                        width: parent.width
                        spacing: 1

                        // 点赞项1 - 点赞视频
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 110
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#e3f2fd"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👦"
                                        font.pixelSize: 20
                                    }
                                }

                                // 点赞内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和点赞类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "张三"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "赞了你的视频"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }

                                        // 点赞图标
                                        Text {
                                            text: "❤️"
                                            font.pixelSize: 16
                                            color: "#ff4757"
                                        }
                                    }

                                    // 被点赞的内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#fff5f5"
                                        radius: 6
                                        border.color: "#ffcccc"
                                        border.width: 1

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "【旅行Vlog】探索神秘的古村落，发现不一样的风景"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-12-06 14:20"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }
                                    }
                                }
                            }
                        }

                        // 点赞项2 - 点赞评论
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 110
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#ffeef0"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👧"
                                        font.pixelSize: 20
                                    }
                                }

                                // 点赞内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和点赞类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "李四"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "赞了你的评论"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }

                                        // 点赞图标
                                        Text {
                                            text: "❤️"
                                            font.pixelSize: 16
                                            color: "#ff4757"
                                        }
                                    }

                                    // 被点赞的内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#fff5f5"
                                        radius: 6
                                        border.color: "#ffcccc"
                                        border.width: 1

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "这个地方真的很适合拍照，光线和角度都很好，推荐大家去打卡"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-12-05 09:30"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }
                                    }
                                }
                            }
                        }

                        // 点赞项3 - 点赞视频
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 110
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#f0f4ff"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👨"
                                        font.pixelSize: 20
                                    }
                                }

                                // 点赞内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和点赞类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "王五"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "赞了你的视频"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }

                                        // 点赞图标
                                        Text {
                                            text: "❤️"
                                            font.pixelSize: 16
                                            color: "#ff4757"
                                        }
                                    }

                                    // 被点赞的内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#fff5f5"
                                        radius: 6
                                        border.color: "#ffcccc"
                                        border.width: 1

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "美食探店：这家餐厅的招牌菜真的太美味了！"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-12-04 16:45"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }
                                    }
                                }
                            }
                        }

                        // 点赞项4 - 点赞评论
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 110
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#f3e5f5"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👩"
                                        font.pixelSize: 20
                                    }
                                }

                                // 点赞内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和点赞类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "赵六"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "赞了你的评论"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }

                                        // 点赞图标
                                        Text {
                                            text: "❤️"
                                            font.pixelSize: 16
                                            color: "#ff4757"
                                        }
                                    }

                                    // 被点赞的内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#fff5f5"
                                        radius: 6
                                        border.color: "#ffcccc"
                                        border.width: 1

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "我觉得这个拍摄角度很独特，把建筑的对称美展现得淋漓尽致"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-12-03 11:15"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }
                                    }
                                }
                            }
                        }

                        // 点赞项5 - 点赞动态
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 110
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 12

                                // 用户头像
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    radius: 25
                                    color: "#e8f5e8"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👦"
                                        font.pixelSize: 20
                                    }
                                }

                                // 点赞内容区域
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 6

                                    // 用户信息和点赞类型
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "钱七"
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }

                                        Text {
                                            text: "赞了你的动态"
                                            font.pixelSize: 13
                                            color: "#666666"
                                            Layout.fillWidth: true
                                        }

                                        // 点赞图标
                                        Text {
                                            text: "❤️"
                                            font.pixelSize: 16
                                            color: "#ff4757"
                                        }
                                    }

                                    // 被点赞的内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#fff5f5"
                                        radius: 6
                                        border.color: "#ffcccc"
                                        border.width: 1

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            text: "今天天气真好，适合出去走走～分享一些随手拍的美景"
                                            font.pixelSize: 13
                                            color: "#333333"
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // 底部信息栏
                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: "2023-12-02 08:30"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }

                                        Item { Layout.fillWidth: true }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // === 新增：系统通知内容区域 ===
        Rectangle {
            id: systemNotificationContent
            Layout.preferredWidth: 1000
            Layout.fillHeight: true
            visible: false
            color: "#ffffff"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 顶部标题栏
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#f5f5f5"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "系统通知"
                        font.bold: true
                        font.pixelSize: 18
                        color: "#333333"
                    }
                }

                // 通知列表
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    background: Rectangle { color: "#fafafa" }

                    ColumnLayout {
                        width: parent.width
                        spacing: 1

                        // 通知项1 - 系统更新
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            color: "#ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 8

                                // 标题和日期行
                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: "📢 系统版本更新通知"
                                        font.bold: true
                                        font.pixelSize: 15
                                        color: "#333333"
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "2023-12-07"
                                        font.pixelSize: 12
                                        color: "#999999"
                                    }
                                }

                                // 通知内容
                                Text {
                                    text: "亲爱的用户，我们已发布新版本v2.5.0，新增了多项功能优化和性能提升。建议您及时更新以获得更好的使用体验。更新内容包括：视频播放优化、消息界面改进、性能提升等。"
                                    font.pixelSize: 13
                                    color: "#666666"
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                }
                            }
                        }

                        // 通知项2 - 活动通知
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            color: "#ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 8

                                // 标题和日期行
                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: "🎉 新年特别活动开启"
                                        font.bold: true
                                        font.pixelSize: 15
                                        color: "#333333"
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "2023-12-05"
                                        font.pixelSize: 12
                                        color: "#999999"
                                    }
                                }

                                // 通知内容
                                Text {
                                    text: "迎接2024新年，我们特别推出了'分享你的年度旅行故事'活动。参与即有机会赢取精美礼品和会员特权！活动时间：2023.12.10 - 2024.1.10。快来分享你的精彩瞬间吧！"
                                    font.pixelSize: 13
                                    color: "#666666"
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                }
                            }
                        }

                        // 通知项3 - 安全提醒
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            color: "#ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 8

                                // 标题和日期行
                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: "🔒 账号安全提醒"
                                        font.bold: true
                                        font.pixelSize: 15
                                        color: "#333333"
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "2023-12-03"
                                        font.pixelSize: 12
                                        color: "#999999"
                                    }
                                }

                                // 通知内容
                                Text {
                                    text: "检测到您的账号在异地登录，如非本人操作，请立即修改密码。建议您开启双重验证功能，保护账号安全。如有疑问，请联系客服支持。"
                                    font.pixelSize: 13
                                    color: "#666666"
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                }
                            }
                        }

                        // 通知项4 - 功能上线
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            color: "#ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 8

                                // 标题和日期行
                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: "✨ 新功能上线：消息分类"
                                        font.bold: true
                                        font.pixelSize: 15
                                        color: "#333333"
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "2023-11-30"
                                        font.pixelSize: 12
                                        color: "#999999"
                                    }
                                }

                                // 通知内容
                                Text {
                                    text: "为了更好地管理您的消息，我们新增了消息分类功能。现在您可以更清晰地查看回复、@提及、点赞等不同类型的消息。希望这个改进能让您的使用体验更加愉悦！"
                                    font.pixelSize: 13
                                    color: "#666666"
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                }
                            }
                        }

                        // 通知项5 - 维护通知
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            color: "#ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 8

                                // 标题和日期行
                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: "🛠️ 系统维护通知"
                                        font.bold: true
                                        font.pixelSize: 15
                                        color: "#333333"
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "2023-11-28"
                                        font.pixelSize: 12
                                        color: "#999999"
                                    }
                                }

                                // 通知内容
                                Text {
                                    text: "为了提升系统稳定性，我们计划于2023年12月10日凌晨2:00-4:00进行系统维护。在此期间，部分服务可能会短暂不可用。给您带来的不便敬请谅解。感谢您的支持！"
                                    font.pixelSize: 13
                                    color: "#666666"
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                }
                            }
                        }

                        // 通知项6 - 社区规则
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            color: "#ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 8

                                // 标题和日期行
                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: "📝 社区规则更新提醒"
                                        font.bold: true
                                        font.pixelSize: 15
                                        color: "#333333"
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "2023-11-25"
                                        font.pixelSize: 12
                                        color: "#999999"
                                    }
                                }

                                // 通知内容
                                Text {
                                    text: "为营造更好的社区环境，我们更新了社区行为规范。主要更新内容包括：明确禁止内容范围、优化举报处理流程、加强原创内容保护等。请仔细阅读新版社区规则，共同维护良好的交流氛围。"
                                    font.pixelSize: 13
                                    color: "#666666"
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                }
                            }
                        }
                    }
                }
            }
        }

        // === 新增：消息设置内容区域 ===
        Rectangle {
            id: messageSettingsContent
            Layout.preferredWidth: 1000
            Layout.fillHeight: true
            visible: false
            color: "#ffffff"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 顶部标题栏
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#f5f5f5"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "消息设置"
                        font.bold: true
                        font.pixelSize: 18
                        color: "#333333"
                    }
                }

                // 设置选项列表
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    background: Rectangle { color: "#fafafa" }

                    ColumnLayout {
                        width: parent.width
                        spacing: 1

                        // 设置项1 - 消息提示
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 4

                                    Text {
                                        text: "消息提示"
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: "#333333"
                                    }

                                    Text {
                                        text: "开启或关闭所有消息提示"
                                        font.pixelSize: 12
                                        color: "#666666"
                                    }
                                }

                                Switch {
                                    checked: true
                                    onCheckedChanged: {
                                        console.log("消息提示: " + (checked ? "开启" : "关闭"))
                                    }
                                }
                            }
                        }

                        // 设置项2 - 私信智能拦截
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 4

                                    Text {
                                        text: "私信智能拦截"
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: "#333333"
                                    }

                                    Text {
                                        text: "自动拦截垃圾私信和骚扰信息"
                                        font.pixelSize: 12
                                        color: "#666666"
                                    }
                                }

                                Switch {
                                    checked: true
                                    onCheckedChanged: {
                                        console.log("私信智能拦截: " + (checked ? "开启" : "关闭"))
                                    }
                                }
                            }
                        }

                        // 设置项3 - 添加消息屏蔽词
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 4

                                    Text {
                                        text: "添加消息屏蔽词"
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: "#333333"
                                    }

                                    Text {
                                        text: "设置关键词屏蔽不想接收的消息"
                                        font.pixelSize: 12
                                        color: "#666666"
                                    }
                                }

                                Button {
                                    text: "管理"
                                    Layout.preferredHeight: 35
                                    Layout.preferredWidth: 80
                                    background: Rectangle {
                                        color: parent.down ? "#e0e0e0" : "#f0f0f0"
                                        radius: 4
                                    }

                                    onClicked: {
                                        console.log("打开屏蔽词管理")
                                    }
                                }
                            }
                        }

                        // 设置项4 - 回复我的消息提醒
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 4

                                    Text {
                                        text: "回复我的消息提醒"
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: "#333333"
                                    }

                                    Text {
                                        text: "设置接收哪些人的回复消息提醒"
                                        font.pixelSize: 12
                                        color: "#666666"
                                    }
                                }

                                ComboBox {
                                    model: ["所有人", "关注的人", "不接受任何消息"]
                                    currentIndex: 0
                                    Layout.preferredWidth: 150
                                    onCurrentIndexChanged: {
                                        console.log("回复消息提醒设置: " + model[currentIndex])
                                    }
                                }
                            }
                        }

                        // 设置项5 - @我的消息提示
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 4

                                    Text {
                                        text: "@我的消息提示"
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: "#333333"
                                    }

                                    Text {
                                        text: "设置接收哪些人的@消息提醒"
                                        font.pixelSize: 12
                                        color: "#666666"
                                    }
                                }

                                ComboBox {
                                    model: ["所有人", "关注的人", "不接受任何消息"]
                                    currentIndex: 0
                                    Layout.preferredWidth: 150
                                    onCurrentIndexChanged: {
                                        console.log("@我的消息提示设置: " + model[currentIndex])
                                    }
                                }
                            }
                        }

                        // 设置项6 - 收到的赞消息提示
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 4

                                    Text {
                                        text: "收到的赞消息提示"
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: "#333333"
                                    }

                                    Text {
                                        text: "开启或关闭点赞消息提示"
                                        font.pixelSize: 12
                                        color: "#666666"
                                    }
                                }

                                Switch {
                                    checked: true
                                    onCheckedChanged: {
                                        console.log("点赞消息提示: " + (checked ? "开启" : "关闭"))
                                    }
                                }
                            }
                        }

                        // 设置项7 - 收到未关注人消息
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            color: "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 4

                                    Text {
                                        text: "收到未关注人消息"
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: "#333333"
                                    }

                                    Text {
                                        text: "开启或关闭未关注人的消息接收"
                                        font.pixelSize: 12
                                        color: "#666666"
                                    }
                                }

                                Switch {
                                    checked: false
                                    onCheckedChanged: {
                                        console.log("未关注人消息: " + (checked ? "开启" : "关闭"))
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
