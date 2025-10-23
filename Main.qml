import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    StackView {
        id: stackView
        // anchors.fill: parent
        initialItem: MainPage{}  // 加载外部QML文件作为初始页面
    }
}

//===============聊天窗口代码==================//
// import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts
// import QtQuick.Window

// ApplicationWindow {
//     id: mainWindow
//     width: 800
//     height: 600
//     visible: true
//     title: qsTr("TCP 聊天应用")

//     property bool server: false
//     property string activeChatTarget: "" // 当前聊天对象
//     property bool mainView: false       //主布局显示

//     // 初始选择面板
//     GroupBox {
//         id: initPanel
//         anchors.centerIn: parent
//         title: "选择模式"
//         visible: true

//         ColumnLayout {
//             spacing: 10

//             Button {
//                 text: "启动服务端"
//                 onClicked: {
//                     msgHandler.startServer();
//                     initPanel.visible = false;
//                     server = true;
//                     mainView = true
//                 }
//             }

//             Button {
//                 text: "启动客户端"
//                 onClicked: {
//                     msgHandler.startClient();
//                     initPanel.visible = false;
//                     server = false;
//                 }
//             }
//         }
//     }

//     ColumnLayout
//     {
//         id:input_name
//         anchors.fill: parent
//         // spacing: 10
//         visible:  !initPanel.visible && !server

//         TextField
//         {
//             id:name_input
//             Layout.fillWidth: true
//             Layout.preferredHeight: 40
//             placeholderText: "输入名字..."
//             placeholderTextColor: "#a0a0a0"
//             font.pixelSize: 14
//             Layout.alignment: Qt.AlignHCenter
//             Layout.margins: 50
//             color: "#333333"
//             background: Rectangle {
//                     color: "#ffffff"
//                     border.color: "#cccccc"
//                     border.width: 1
//                     radius: 4
//             }
//             onAccepted:
//             {
//                 if(name_input.text !=="")
//                   msgHandler.clientHandler.setName(name_input.text);
//                 mainView  = true;
//                 input_name.visible = false;
//             }
//         }

//         Button
//         {
//             Layout.alignment: Qt.AlignHCenter
//             text: "发送"
//             Layout.preferredHeight: 20
//             Layout.preferredWidth: 40
//             onClicked:
//             {
//                 if(name_input.text !=="")
//                    msgHandler.clientHandler.setName(name_input.text);
//                 mainView  = true;
//                 input_name.visible = false;
//             }
//         }

//     }

//     // 主布局
//     ColumnLayout {
//         anchors.fill: parent
//         spacing: 10
//         visible: mainView

//         // 状态显示
//         Label {
//             id: statusLabel

//             // 文本内容
//             text: {
//                 // 将IP地址列表转换为逗号分隔的字符串
//                 var ipString = msgHandler.serverHandler.ip

//                 if(server) {
//                     // 服务端模式
//                     var portStatus = msgHandler.serverPort > 0 ?
//                         msgHandler.serverPort : "未启动";

//                     return "状态: 服务端 | 主机名: " + msgHandler.hostname +
//                            " | IP: " + ipString +
//                            " | 端口: " + portStatus
//                 } else {
//                     // 客户端模式
//                     var portInfo = "未连接";
//                     var clientId = "未连接";
//                     var clientName = msgHandler.clientHandler.name;

//                     if (msgHandler.clientHandler) {
//                         if(msgHandler.clientHandler.serverPort > 0)
//                           portInfo = msgHandler.clientHandler.serverPort;
//                         if(msgHandler.clientHandler.serverIp !== "")
//                          clientId = msgHandler.clientHandler.serverIp;
//                     }

//                     return "状态: 客户端 | 主机名: " + msgHandler.hostname +
//                            " | IP: " + ipString +
//                                " | 服务端端口: " + portInfo +
//                                " | 服务端IP: " + clientId +
//                                " | 名字: " + clientName
//                 }
//             }

//             color: "green"

//             // 字体设置
//             font.pixelSize: 16
//             font.bold: true

//             // 水平居中
//             horizontalAlignment: Text.AlignHCenter

//             // 布局设置
//             Layout.fillWidth: true

//             // 边距设置（使用 Layout 属性）
//             Layout.margins: 10

//             // 文本换行
//             wrapMode: Text.Wrap

//         }

//         // 聊天目标显示
//         Label {
//             text: activeChatTarget ? "与 " + activeChatTarget + " 聊天" : "请选择聊天对象"
//             font.bold: true
//             visible: !server
//             Layout.fillWidth: true
//         }

//         // 主内容区域
//         RowLayout {
//             Layout.fillWidth: true
//             Layout.fillHeight: true
//             spacing: 10

//             // 左侧面板 - 在线用户列表
//             GroupBox {
//                 title: "在线用户"
//                 Layout.preferredWidth: 200
//                 Layout.fillHeight: true
//                 visible: !server

//                 ScrollView {
//                     anchors.fill: parent
//                     spacing: 10

//                     ListView {
//                         id: clientListView
//                         model: msgHandler.clientHandler ? msgHandler.clientHandler.clientList : []
//                         spacing: 10
//                         delegate: Button {
//                             id: contactButton
//                             width: ListView.view.width
//                             height: 52
//                             text: modelData
//                             font.pixelSize: 14
//                             font.bold: modelData === activeChatTarget
//                             hoverEnabled: true

//                             // 内容区域
//                             contentItem: Text {
//                                 text: contactButton.text
//                                 font: contactButton.font
//                                 color: {
//                                                 // 自己的名字用深绿色，其他用户用深蓝色
//                                                 if (modelData === msgHandler.clientHandler.name) {
//                                                     return "#006400" // 深绿色
//                                                 } else if (modelData === activeChatTarget) {
//                                                     return "#0d47a1" // 深蓝色
//                                                 } else {
//                                                     return "#37474f" // 深灰色
//                                                 }
//                                             }
//                                 horizontalAlignment: Text.AlignLeft
//                                 verticalAlignment: Text.AlignVCenter
//                                 leftPadding: 20
//                                 rightPadding: 10
//                                 elide: Text.ElideRight
//                             }

//                             // 背景和边框
//                             background: Rectangle {
//                                 id: buttonBg
//                                 color: {
//                                                 // 自己的名字用浅绿色，其他用户用白色
//                                                 if (modelData === msgHandler.clientHandler.name) {
//                                                     // 自己的名字
//                                                     if (contactButton.pressed) {
//                                                         return "#c8e6c9" // 按下状态：稍深的绿色
//                                                     } else if (modelData === activeChatTarget) {
//                                                         return "#a5d6a7" // 选中状态：中等绿色
//                                                     } else if (contactButton.hovered) {
//                                                         return "#e8f5e9" // 悬停状态：浅绿色
//                                                     } else {
//                                                         return "#f1f8e9" // 正常状态：非常浅的绿色
//                                                     }
//                                                 } else {
//                                                     // 其他用户
//                                                     if (contactButton.pressed) {
//                                                         return "#e0e0e0" // 按下状态：灰色
//                                                     } else if (modelData === activeChatTarget) {
//                                                         return "#bbdefb" // 选中状态：浅蓝色
//                                                     } else if (contactButton.hovered) {
//                                                         return "#f5f5f5" // 悬停状态：浅灰色
//                                                     } else {
//                                                         return "#ffffff" // 正常状态：白色
//                                                     }
//                                                 }
//                                             }
//                                 border.color: {
//                                                 if (modelData === activeChatTarget) {
//                                                     return modelData === msgHandler.clientHandler.name ?
//                                                         "#2e7d32" : "#0d47a1" // 深绿色或深蓝色
//                                                 } else {
//                                                     return contactButton.hovered ? "#b0bec5" : "#cfd8dc"
//                                                 }
//                                             }
//                                 border.width: modelData === activeChatTarget ? 2 : 1
//                                 radius: 0

//                                 // 添加活动指示器
//                                 Rectangle {
//                                     visible: modelData === activeChatTarget
//                                     width: 5
//                                     height: parent.height
//                                     color: "#0d47a1" // 深蓝色
//                                     anchors.left: parent.left
//                                     anchors.verticalCenter: parent.verticalCenter
//                                 }

//                                 // 添加动画效果
//                                 Behavior on color {
//                                     ColorAnimation { duration: 150 }
//                                 }
//                                 Behavior on border.color {
//                                     ColorAnimation { duration: 150 }
//                                 }
//                             }

//                             // 添加悬停效果动画
//                             Behavior on scale {
//                                 NumberAnimation { duration: 100 }
//                             }

//                             // 悬停时轻微放大
//                             onHoveredChanged: {
//                                 if (hovered) {
//                                     scale = 1.01
//                                 } else {
//                                     scale = 1.0
//                                 }
//                             }

//                             onClicked: {
//                                 activeChatTarget = modelData;
//                                 // 设置活动聊天
//                                 msgHandler.clientHandler.setActiveChat(modelData);
//                             }
//                         }
//                     }
//                 }
//             }

//             // 右侧面板 - 聊天区
//             ColumnLayout {
//                 Layout.fillWidth: true
//                 Layout.fillHeight: true
//                 spacing: 10

//                 // 聊天历史显示
//                 GroupBox {
//                     title: "聊天记录"
//                     Layout.fillWidth: true
//                     Layout.fillHeight: true
//                     spacing: 5

//                     ScrollView {
//                         anchors.fill: parent

//                         TextEdit {
//                                         id: chatArea
//                                         width: parent.width // 确保宽度匹配父容器
//                                         height: implicitHeight // 高度根据内容自动调整
//                                         readOnly: true
//                                         wrapMode: TextEdit.Wrap
//                                         font.pixelSize: 14
//                                         text: msgHandler.clientHandler ? msgHandler.clientHandler.chatHistory : ""
//                                         selectByMouse: true // 允许选择文本
//                                         textFormat: TextEdit.PlainText // 使用纯文本格式

//                                         // 确保文本不会提前换行
//                                         Component.onCompleted: {
//                                             if (typeof chatArea.implicitWidth !== "undefined") {
//                                                 chatArea.width = Qt.binding(function() {
//                                                     return Math.max(chatArea.implicitWidth, parent.width);
//                                                 });
//                                             }
//                                         }
//                          }
//                     }
//                 }

//                 // 消息输入区
//                 GroupBox {
//                     title: "发送消息"
//                     Layout.fillWidth: true
//                     visible: activeChatTarget !== ""

//                     ColumnLayout {
//                         width: parent.width

//                         TextField {
//                             id: messageInput
//                             Layout.fillWidth: true
//                             placeholderText: "输入消息..."
//                             placeholderTextColor: "#a0a0a0" // 设置占位文本颜色
//                             font.pixelSize: 14
//                             color: "#333333"
//                             background: Rectangle {
//                                     color: "#ffffff"
//                                     border.color: "#cccccc"
//                                     border.width: 1
//                                     radius: 4
//                             }

//                             onAccepted: {
//                                 if (msgHandler.clientHandler && activeChatTarget) {
//                                     msgHandler.clientHandler.sendToClient(activeChatTarget, messageInput.text);
//                                     messageInput.clear();
//                                 }
//                             }
//                         }

//                         Button {
//                             text: "发送"
//                             Layout.alignment: Qt.AlignRight
//                             onClicked: {
//                                 if (msgHandler.clientHandler && activeChatTarget) {
//                                     msgHandler.clientHandler.sendToClient(activeChatTarget, messageInput.text);
//                                     messageInput.clear();
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }
//         }
//     }

// }
