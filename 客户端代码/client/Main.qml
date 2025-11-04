import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: mainWindow
    width: 800
    height: 600
    visible: true
    title: qsTr("AppSocket Client")

    property string activeChatTarget: ""
    property bool connected: msgHandler.clientHandler.connected
    property bool connecting: msgHandler.clientHandler.connecting

    // 连接面板
    ColumnLayout {
        id: connectPanel
        anchors.centerIn: parent
        visible: !connected && !connecting
        spacing: 15
        width: 300

        Label {
            text: "连接到服务器"
            font.bold: true
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
        }

        TextField {
            id: serverAddress
            placeholderText: "服务器 IP 地址"
            text: "49.232.73.239"
            Layout.fillWidth: true
        }

        TextField {
            id: serverPort
            placeholderText: "服务器端口"
            text: "8080"
            validator: IntValidator { bottom: 1; top: 65535 }
            Layout.fillWidth: true
        }

        TextField {
            id: userName
            placeholderText: "您的姓名"
            text: "Saki"
            Layout.fillWidth: true
        }

        Button {
            text: "连接"
            onClicked: {
                msgHandler.clientHandler.setName(userName.text);
                msgHandler.clientHandler.connectToServer(serverAddress.text, parseInt(serverPort.text));
            }
            Layout.fillWidth: true
            highlighted: true
        }
    }

    // 连接中状态提示
    ColumnLayout {
        id: connectingPanel
        anchors.centerIn: parent
        visible: connecting
        spacing: 20

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: connecting
            width: 50
            height: 50
        }

        Label {
            text: "正在连接服务器..."
            font.bold: true
            font.pixelSize: 16
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "请稍候..."
            color: "gray"
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: "取消连接"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                msgHandler.clientHandler.disconnectFromServer()
            }
        }
    }

    // 主聊天界面
    ColumnLayout {
        anchors.fill: parent
        spacing: 5
        visible: connected

        // 状态栏
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: connected ? "lightgreen" : "lightcoral"

            Label {
                anchors.centerIn: parent
                text: {
                    var status = connected ? "已连接" : "未连接";
                    var serverInfo = msgHandler.clientHandler.serverIp + ":" + msgHandler.clientHandler.serverPort;
                    return "状态: " + status + " | 服务器: " + serverInfo + " | 姓名: " + msgHandler.clientHandler.name;
                }
                font.bold: true
            }
        }

        // 聊天目标显示
        Label {
            text: activeChatTarget ? "正在与 " + activeChatTarget + " 聊天" : "请选择一个联系人开始聊天"
            visible: activeChatTarget
            Layout.fillWidth: true
            padding: 10
            background: Rectangle { color: "lightblue"; radius: 5 }
        }

        // 主内容区
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // 联系人列表
            GroupBox {
                title: "联系人列表"
                Layout.preferredWidth: 200
                Layout.fillHeight: true

                ListView {
                    id: contactList
                    anchors.fill: parent
                    model: msgHandler.clientHandler.clientList
                    delegate: Button {
                        width: ListView.view.width
                        text: modelData
                        highlighted: modelData === activeChatTarget
                        onClicked: {
                            activeChatTarget = modelData

                             //!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            // 加载与该联系人的聊天历史
                            msgHandler.clientHandler.setActiveChat(modelData)
                        }
                    }
                    ScrollBar.vertical: ScrollBar {}
                }
            }

            // 聊天区域
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 5

                // 聊天历史
                GroupBox {
                    title: "聊天记录"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ScrollView {
                        anchors.fill: parent
                        TextArea {
                            id: chatHistory
                            readOnly: true
                            text: msgHandler.clientHandler.chatHistory
                            wrapMode: TextArea.Wrap
                            background: Rectangle { color: "white" }
                        }
                    }
                }

                // 消息输入区域
                RowLayout {
                    Layout.fillWidth: true
                    visible: activeChatTarget
                    spacing: 10

                    TextField {
                        id: messageInput
                        Layout.fillWidth: true
                        placeholderText: "输入消息..."
                        onAccepted: {
                            if (activeChatTarget && text) {
                                msgHandler.clientHandler.sendToClient(activeChatTarget, text);
                                clear();
                            }
                        }
                    }

                    Button {
                        text: "发送"
                        enabled: messageInput.text.length > 0
                        onClicked: {
                            if (activeChatTarget && messageInput.text) {
                                msgHandler.clientHandler.sendToClient(activeChatTarget, messageInput.text);
                                messageInput.clear();
                            }
                        }
                    }
                }
            }
        }
    }

    // 错误重连弹窗
    Dialog {
        id: reconnectDialog
        title: "连接失败"
        modal: true
        standardButtons: Dialog.Retry | Dialog.Cancel
        closePolicy: Popup.NoAutoClose

        width: 400
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        ColumnLayout {
            width: parent.width
            spacing: 10

            Label {
                text: "⚠️ 无法连接到服务器"
                font.bold: true
                Layout.fillWidth: true
            }

            Label {
                id: errorMessageLabel
                text: "连接服务器时出现错误"
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Label {
                text: "是否尝试重新连接？"
                color: "gray"
                Layout.fillWidth: true
            }
        }

        onAccepted: {
            msgHandler.clientHandler.reconnect()
        }

        onRejected: {
            reconnectDialog.close()
        }
    }

    // 连接状态指示器
    Rectangle {
        id: statusIndicator
        anchors {
            top: parent.top
            right: parent.right
            margins: 10
        }
        width: 120
        height: 30
        radius: 15
        color: {
            if (connecting) return "orange"
            else if (connected) return "green"
            else return "red"
        }

        Label {
            anchors.centerIn: parent
            text: {
                if (connecting) return "🔄 连接中"
                else if (connected) return "✅ 已连接"
                else return "❌ 未连接"
            }
            color: "white"
            font.bold: true
        }
    }

    // 监听C++信号
    Connections {
        target: msgHandler.clientHandler
        function onConnectionError(errorMessage) {
            errorMessageLabel.text = errorMessage
            reconnectDialog.open()
        }
    }

    // 在连接成功后自动加载聊天历史（如果有活动聊天对象）!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Connections {
        target: msgHandler.clientHandler
        function onConnected() {
            console.log("连接成功，检查是否需要加载历史记录")
            if (activeChatTarget) {
                // 延迟一下，确保客户端列表已经更新
                Qt.callLater(function() {
                    msgHandler.clientHandler.setActiveChat(activeChatTarget)
                })
            }
        }
    }

    // 监听历史记录接收信号!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Connections {
        target: msgHandler.clientHandler
        function onHistoryReceived(contactName, history) {
            console.log("收到", contactName, "的历史记录，消息数量:", history.split('\n').length - 1)
            // 如果当前活动聊天对象匹配，则更新显示
            if (contactName === activeChatTarget) {
                // 聊天记录会自动通过 chatHistory 属性更新
            }
        }
    }

    Connections {
        target: msgHandler.clientHandler
        function onNewMessage(message) {
            console.log("新消息:", message)
        }
    }
}
