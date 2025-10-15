//个人信息

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: personInfoPage
    color: "#f4f4f4"

    // 状态管理
    property int selectedHistoryIndex: -1  // 当前选中的历史记录索引
    property bool isHistoryEmpty: false    // 历史记录是否为空
    property int currentTabIndex: 0        // 当前选中的功能标签索引

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

    // 历史记录数据模型（添加示例数据）
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

    // 主要内容区域
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
                color: "#f5f5f5"  // 浅灰色背景

                // 使用Item确保内容填满整个卡片
                Item {
                    anchors.fill: parent
                    anchors.margins: 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        // 用户头像区域
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

                                Behavior on opacity {
                                    NumberAnimation { duration: 300 }
                                }

                                Image {
                                    anchors.fill: parent
                                     source:"https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"
                                    // source: "file:///root/bilibli/AAAClassWork/maomao.jpg"
                                    fillMode: Image.PreserveAspectCrop
                                }
                            }

                            // 用户名和大会员标识
                            Column {
                                width: 80
                                spacing: 5

                                Text {
                                    width: parent.width
                                    text: "提醒喝水小..."
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

                        // 用户数据统计和按钮区域
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10

                            // 数据统计行
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 30

                                // 动态
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

                                // 关注
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

                                // 粉丝
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

                                // 硬币
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

                                // B币
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

                                // 分隔线
                                Rectangle {
                                    Layout.preferredWidth: 1
                                    Layout.preferredHeight: 40
                                    color: "#e0e0e0"
                                }

                                // 成为大会员按钮
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

                            // 占位空间
                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }
                }
            }

            // 功能标签区域
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

                            // 下划线指示器
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

            // 搜索和清空区域 - 根据当前标签动态变化
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
                        placeholderText: getSearchPlaceholder() // 动态提示文本
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
                        text: getClearButtonText() // 动态按钮文本
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
                                // 这里可以添加其他标签的清空逻辑
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
                color: currentTabIndex === 0 ? "transparent" : "#f4f4f4" // 其他标签使用灰色背景

                // 历史记录列表
                ColumnLayout {
                    width: parent.width
                    spacing: 0
                    visible: currentTabIndex === 0

                    // 空状态提示
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

                    // 历史记录列表
                    ColumnLayout {
                        spacing: 0
                        visible: !isHistoryEmpty

                        // 今天标题
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

                        // 历史记录列表
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

                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }

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

                                    // 视频缩略图
                                    Rectangle {
                                        Layout.preferredWidth: 120
                                        Layout.preferredHeight: 70
                                        color: "#e0e0e0"
                                        radius: 4

                                        // 播放进度条
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

                                        // 时长标签
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

                                    // 视频信息
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 5

                                        // 标题行
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

                                        // UP主信息
                                        Text {
                                            text: author || up || "UP主"
                                            font.pixelSize: 12
                                            color: "#666"
                                            visible: text !== ""
                                        }

                                        // 底部信息行
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 15

                                            Text {
                                                text: duration
                                                font.pixelSize: 12
                                                color: "#999"
                                            }

                                            // 已看完标签
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

                                // 点击处理
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

                // 其他标签内容区域 - 修复位置问题
                ColumnLayout {
                    width: parent.width
                    spacing: 0
                    visible: currentTabIndex !== 0

                    // 使用与历史记录空状态相同的结构
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

            // 底部留白
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
            }
        }
    }
}
