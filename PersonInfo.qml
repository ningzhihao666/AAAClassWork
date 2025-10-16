import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

Rectangle {
    id: personInfoPage
    color: "#f4f4f4"

    // 接收全局头像URL属性
    property alias globalAvatarUrl: personInfoPage.avatarUrl
    property string avatarUrl: "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"

    // 状态管理
    property int selectedHistoryIndex: -1//历史记录index
    property bool isHistoryEmpty: false
    property int currentTabIndex: 0//当前个人的历史记录，离线换存的index

    // 设置主窗口头像URL的函数
    function setMainAvatarUrl(url) {
        console.log("个人信息页面设置主窗口头像URL:", url)
        avatarUrl = url
        // 直接更新主窗口的globalAvatarUrl
        root.globalAvatarUrl = url
    }

    // 获取搜索提示文本
      function getSearchPlaceholder() {
          switch(currentTabIndex) {
              case 0: return "搜索你的历史记录";
              case 1: return "搜索你的离线缓存";
              case 2: return "搜索你的收藏";
              case 3: return "搜索你的稍后再看";
              default: return "搜索";
          }
      }

      // 获取清空按钮文本
      function getClearButtonText() {
          switch(currentTabIndex) {
              case 0: return "清空记录";
              case 1: return "清空缓存";
              case 2: return "清空收藏";
              case 3: return "清空列表";
              default: return "清空";
          }
      }

    // 文件选择对话框
    FileDialog {
        id: fileDialog
        title: "选择头像图片"
        nameFilters: ["图片文件 (*.png *.jpg *.jpeg)"]
        onAccepted: {
            console.log("选择的文件: " + selectedFile)
            // 更新头像URL
            setMainAvatarUrl(selectedFile)
        }
    }

    // 头像大图弹窗
    Popup {
        id: largeImagePopup
        width: Math.min(parent.width * 0.9, 500)
        height: Math.min(parent.height * 0.9, 500)
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        contentItem: Image {
            id: largeImage
            source: avatarUrl
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: false

            // 点击关闭
            TapHandler {
                onTapped: largeImagePopup.close()
            }
        }

        // 关闭按钮
        Button {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            width: 30
            height: 30
            padding: 0
            background:null

            contentItem: Text {
                text: "×"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                anchors.centerIn: parent
            }

            onClicked: largeImagePopup.close()
        }
    }

    // 用户信息弹窗
    Popup {
        id: userInfoPopup
        width: 320
        height: 320
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 15

        background: Rectangle {
            color: "white"
            radius: 12
            border.color: "#e0e0e0"
            border.width: 1
        }

        contentItem: Column {
            width: parent.width
            spacing: 20

            // 顶部标题栏和关闭按钮
            Item {
                width: parent.width
                height: 30

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "📷 用户信息"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#333"
                }

                Button {
                    id: closeButton
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 24
                    padding: 0
                    background: null

                    contentItem: Text {
                        text: "×"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#666"
                        anchors.centerIn: parent
                    }

                    onClicked: userInfoPopup.close()
                }
            }

            // 用户头像显示区域
            Column {
                width: parent.width
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 80
                    height: 80
                    radius: 40
                    clip: true
                    opacity: isHistoryEmpty ? 0.6 : 1.0
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        id: avatarImage
                        anchors.fill: parent
                        source: avatarUrl
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Text {
                    text: "用户名"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: 60
                    height: 20
                    color: "#FB7299"
                    radius: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "大会员"
                        color: "white"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }

            // 功能按钮区域
            Column {
                width: parent.width
                spacing: 12

                Button {
                    width: parent.width
                    height: 40
                    text: "查看大图"

                    background: Rectangle {
                        color: parent.hovered ? "#f8f8f8" : "white"
                        radius: 8
                        border.color: parent.down ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#333"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("查看头像大图")
                        largeImagePopup.open()
                    }
                }

                Button {
                    width: parent.width
                    height: 40
                    text: "更换头像"

                    background: Rectangle {
                        color: parent.hovered ? "#f8f8f8" : "white"
                        radius: 8
                        border.color: parent.down ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#333"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("更换头像")
                        fileDialog.open()
                    }
                }
            }
        }
    }

    // 历史记录数据模型
    ListModel {
        id: historyModel
        ListElement {
            title: "孙吧学生会"
            author: "沈井彬-擒史皇"
            duration: "00:20/02:43"
            time: "16:04"
            up: "夏日枯竭中 豆花ono"
            badge: ""
        }
        ListElement {
            title: "50年后的魔怔XX玩家"
            author: "愚昧的羊群 -去看流星雨-"
            duration: "00:10/02:28"
            time: "16:01"
            badge: ""
        }
        ListElement {
            title: "-去看流星雨-"
            author: ""
            duration: "00:06/00:39"
            time: "16:02"
            badge: ""
        }
        ListElement {
            title: "-去看流星雨-"
            author: ""
            duration: "00:11/00:18"
            time: "16:02"
            badge: ""
        }
        ListElement {
            title: "《难绷TV》丁亮他爸当年那一下可不得了"
            author: "抽象TV频道"
            duration: "00:30/02:03"
            time: "16:04"
            badge: "已看完"
        }
    }

    // 清空历史记录函数
    function clearHistory() {
        historyModel.clear()
        selectedHistoryIndex = -1
        isHistoryEmpty = true
    }

    // 主要内容区域(个人硬币，粉丝等东西）
    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 0

            // 用户信息卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: "#f5f5f5"

                Item {
                    anchors.fill: parent
                    anchors.margins: 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        Column {
                            spacing: 10
                            Layout.alignment: Qt.AlignTop

                            Rectangle {
                                id: userAvatar
                                width: 80
                                height: 80
                                radius: 40
                                clip: true
                                opacity: isHistoryEmpty ? 0.6 : 1.0

                                Image {
                                    id: mainAvatarImage
                                    anchors.fill: parent
                                    source: avatarUrl
                                    fillMode: Image.PreserveAspectCrop
                                }

                                TapHandler {
                                    onTapped: {
                                        console.log("头像被点击，打开用户信息弹窗")
                                        userInfoPopup.open()
                                    }
                                }
                            }

                            Column {
                                width: 80
                                spacing: 5

                                Text {
                                    width: parent.width
                                    text: "用户名"
                                    font.pixelSize: 14
                                    font.bold: true
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 20
                                    color: "#FB7299"
                                    radius: 4

                                    Text {
                                        anchors.centerIn: parent
                                        text: "大会员"
                                        color: "white"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 30

                                Column {
                                    Layout.alignment: Qt.AlignCenter
                                    Text {
                                        text: "15"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#FB7299"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "动态"
                                        font.pixelSize: 12
                                        color: "#999"
                                    }
                                }

                                Column {
                                    Layout.alignment: Qt.AlignCenter
                                    Text {
                                        text: "1260"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#FB7299"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "关注"
                                        font.pixelSize: 12
                                        color: "#999"
                                    }
                                }

                                Column {
                                    Layout.alignment: Qt.AlignCenter
                                    Text {
                                        text: "16"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#FB7299"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "粉丝"
                                        font.pixelSize: 12
                                        color: "#999"
                                    }
                                }

                                Column {
                                    Layout.alignment: Qt.AlignCenter
                                    Text {
                                        text: "794"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#FFB11B"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "硬币"
                                        font.pixelSize: 12
                                        color: "#999"
                                    }
                                }

                                Column {
                                    Layout.alignment: Qt.AlignCenter
                                    Text {
                                        text: "0"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#00A1D6"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "B币"
                                        font.pixelSize: 12
                                        color: "#999"
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 1
                                    Layout.preferredHeight: 40
                                    color: "#e0e0e0"
                                }

                                Button {
                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 36
                                    text: "成为大会员"
                                    background: Rectangle {
                                        color: "#FB7299"
                                        radius: 18
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        font.pixelSize: 12
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }
                }
            }

            // 功能标签区域（历史记录等东西）
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "white"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    spacing: 30

                    Repeater {
                        model: ["历史记录", "离线缓存", "我的收藏", "稍后再看"]

                        delegate: Rectangle {
                            id: tabItem
                            width: 80
                            height: parent.height
                            color: "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 14
                                color: currentTabIndex === index ? "#FB7299" : "#666"
                                font.bold: currentTabIndex === index
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 2
                                color: "#FB7299"
                                visible: currentTabIndex === index
                            }

                            TapHandler {
                                onTapped: {
                                    currentTabIndex = index
                                    console.log("点击标签:", modelData)
                                }
                            }
                        }
                    }
                }
            }

            // 搜索和清空区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "white"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    TextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        placeholderText: getSearchPlaceholder()
                        placeholderTextColor: "#999"
                        background: Rectangle {
                            color: "#f4f4f4"
                            radius: 4
                            border.color: parent.focus ? "#FB7299" : "transparent"
                        }
                    }

                    Button {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 36
                        text: getClearButtonText()
                        background: Rectangle {
                            color: "#f4f4f4"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#666"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            if (currentTabIndex === 0) {
                                clearHistory()
                            } else {
                                console.log("清空操作:", getClearButtonText())
                            }
                        }
                    }
                }
            }

            // 内容区域容器
            Rectangle {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: currentTabIndex === 0 ? "transparent" : "#f4f4f4"

                ColumnLayout {
                    width: parent.width
                    spacing: 0
                    visible: currentTabIndex === 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        color: "transparent"
                        visible: isHistoryEmpty

                        Column {
                            anchors.centerIn: parent
                            spacing: 20
                            opacity: 0.5

                            Text {
                                text: "📺"
                                font.pixelSize: 40
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "还没有观看记录哦"
                                font.pixelSize: 16
                                color: "#999"
                            }

                            Text {
                                text: "快去发现精彩内容吧～"
                                font.pixelSize: 12
                                color: "#999"
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 0
                        visible: !isHistoryEmpty

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: "#fafafa"

                            Text {
                                anchors {
                                    left: parent.left
                                    leftMargin: 20
                                    verticalCenter: parent.verticalCenter
                                }
                                text: "今天"
                                font.pixelSize: 14
                                color: "#666"
                            }
                        }

                        ListView {
                            id: historyListView
                            Layout.fillWidth: true
                            Layout.preferredHeight: childrenRect.height
                            clip: true
                            model: historyModel
                            interactive: false

                            delegate: Rectangle {
                                id: historyItem
                                width: historyListView.width
                                height: 80
                                color: selectedHistoryIndex === index ? "#fff0f0" : "white"

                                Rectangle {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        bottom: parent.bottom
                                        margins: 0
                                    }
                                    height: 1
                                    color: "#f0f0f0"
                                    visible: index !== historyModel.count - 1
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 15

                                    Rectangle {
                                        Layout.preferredWidth: 120
                                        Layout.preferredHeight: 70
                                        color: "#e0e0e0"
                                        radius: 4

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            width: parent.width
                                            height: 3
                                            color: "#e0e0e0"

                                            Rectangle {
                                                width: parent.width * 0.3
                                                height: parent.height
                                                color: "#FB7299"
                                            }
                                        }

                                        Rectangle {
                                            anchors {
                                                right: parent.right
                                                bottom: parent.bottom
                                                margins: 5
                                            }
                                            width: durationText.width + 8
                                            height: durationText.height + 4
                                            color: "#99000000"
                                            radius: 2

                                            Text {
                                                id: durationText
                                                anchors.centerIn: parent
                                                text: duration.split("/")[1]
                                                color: "white"
                                                font.pixelSize: 10
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 5

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 10

                                            Text {
                                                Layout.fillWidth: true
                                                text: title
                                                font.pixelSize: 14
                                                elide: Text.ElideRight
                                                color: selectedHistoryIndex === index ? "#FB7299" : "#333"
                                            }

                                            Text {
                                                text: time
                                                font.pixelSize: 12
                                                color: "#999"
                                            }
                                        }

                                        Text {
                                            text: author || up || "UP主"
                                            font.pixelSize: 12
                                            color: "#666"
                                            visible: text !== ""
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 15

                                            Text {
                                                text: duration
                                                font.pixelSize: 12
                                                color: "#999"
                                            }

                                            Rectangle {
                                                visible: badge
                                                width: badgeText.width + 8
                                                height: badgeText.height + 4
                                                color: "#f0f0f0"
                                                radius: 2

                                                Text {
                                                    id: badgeText
                                                    anchors.centerIn: parent
                                                    text: badge || ""
                                                    font.pixelSize: 10
                                                    color: "#999"
                                                }
                                            }

                                            Item { Layout.fillWidth: true }
                                        }
                                    }
                                }

                                TapHandler {
                                    onTapped: {
                                        selectedHistoryIndex = index
                                        console.log("点击历史记录:", title)
                                    }
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    width: parent.width
                    spacing: 0
                    visible: currentTabIndex !== 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        color: "transparent"

                        Column {
                            anchors.centerIn: parent
                            spacing: 15
                            opacity: 0.6

                            Text {
                                text: {
                                    switch(currentTabIndex) {
                                    case 1: return "📥";
                                    case 2: return "❤️";
                                    case 3: return "⏱️";
                                    default: return "📺";
                                    }
                                }
                                font.pixelSize: 40
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: {
                                    switch(currentTabIndex) {
                                    case 1: return "离线缓存功能";
                                    case 2: return "我的收藏功能";
                                    case 3: return "稍后再看功能";
                                    default: return "功能区域";
                                    }
                                }
                                font.pixelSize: 16
                                color: "#666"
                            }

                            Text {
                                text: {
                                    switch(currentTabIndex) {
                                    case 1: return "此功能暂未实现";
                                    case 2: return "此功能暂未实现";
                                    case 3: return "此功能暂未实现";
                                    default: return "请选择其他功能";
                                    }
                                }
                                font.pixelSize: 12
                                color: "#999"
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
            }
        }
    }

    // 初始化时同步头像
    Component.onCompleted: {
        console.log("个人信息页面初始化，同步头像URL:", root.globalAvatarUrl)
        avatarUrl = root.globalAvatarUrl
    }
}
