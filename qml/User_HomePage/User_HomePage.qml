import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Window

Item{
    id: userProfilePage
    width: 1200
    height: 800
    visible: true

    // 用户数据属性
    property string userName: "创意设计师"
    property int userLevel: 6
    property bool isAnnualMember: true
    property string userDescription: "专注于UI/UX设计和前端开发，热爱分享设计经验和技巧。在这里你可以找到各种设计教程和创意作品。"
    property int followingCount: 128
    property int followersCount: 1024
    property int likesCount: 5000
    property int playsCount: 100000
    property string avatarSource: "qrc:/default_avatar.png"

    // 颜色定义
    property color primaryColor: "#fb7299"
    property color secondaryColor: "#ff8eb3"
    property color textPrimary: "#212121"
    property color textSecondary: "#666666"
    property color textHint: "#999999"
    property color backgroundColor: "#f8f9fa"
    property color cardColor: "#ffffff"
    property color borderColor: "#e0e0e0"

    // 数据统计项组件
    Component {
        id: statItemComponent

        ColumnLayout {
            property string title: ""
            property int value: 0
            spacing: 4

            Text {
                text: value.toLocaleString()
                font {
                    pixelSize: 20
                    bold: true
                    family: "Microsoft YaHei"
                }
                color: primaryColor
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: title
                font {
                    pixelSize: 12
                    family: "Microsoft YaHei"
                }
                color: textHint
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // 视频卡片组件
    Component {
        id: videoCardComponent

        Rectangle {
            id: videoCard
            width: 220
            height: 200
            radius: 12
            color: cardColor
            border.color: borderColor
            border.width: 1

            // 阴影效果
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                radius: 8
                samples: 17
                color: "#20000000"
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // 视频缩略图区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 110
                    radius: 6
                    color: "#f0f0f0"

                    LinearGradient {
                        anchors.fill: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(0, parent.height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#e0e0e0" }
                            GradientStop { position: 1.0; color: "#d0d0d0" }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "🎬 视频预览"
                        color: textHint
                        font.pixelSize: 12
                    }

                    // 播放量标签
                    Rectangle {
                        anchors {
                            top: parent.top
                            right: parent.right
                            margins: 4
                        }
                        width: playCountText.width + 12
                        height: 20
                        radius: 10
                        color: "#cc000000"

                        Text {
                            id: playCountText
                            anchors.centerIn: parent
                            text: "10万播放"
                            color: "white"
                            font {
                                pixelSize: 10
                                family: "Microsoft YaHei"
                            }
                        }
                    }
                }

                // 视频信息
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 4

                    Text {
                        text: "UI设计入门教程：从零开始学习界面设计"
                        font {
                            pixelSize: 14
                            family: "Microsoft YaHei"
                        }
                        color: textPrimary
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        lineHeight: 1.2
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "📊 2.5万点赞"
                            font {
                                pixelSize: 11
                                family: "Microsoft YaHei"
                            }
                            color: textHint
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "· 2小时前"
                            font {
                                pixelSize: 11
                                family: "Microsoft YaHei"
                            }
                            color: textHint
                        }
                    }
                }
            }

            // 悬停效果
            states: State {
                name: "hovered"
                PropertyChanges {
                    target: videoCard
                    scale: 1.02
                    border.color: primaryColor
                }
            }

            transitions: Transition {
                NumberAnimation {
                    properties: "scale"
                    duration: 200
                    easing.type: Easing.OutCubic
                }
                ColorAnimation {
                    duration: 200
                }
            }

            HoverHandler {
                id: hoverHandler
            }
        }
    }

    // 背景设计
    Rectangle {
        id: background
        anchors.fill: parent
        color: backgroundColor
    }

    // 主内容区域
    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: scrollView.width
            spacing: 0

            // 用户信息卡片
            Rectangle {
                id: userCard
                Layout.fillWidth: true
                Layout.preferredHeight: 240
                color: cardColor

                // 卡片阴影
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    radius: 12
                    samples: 17
                    color: "#20000000"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 40
                    spacing: 30

                    // 头像区域
                    Item {
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 140

                        Rectangle {
                            id: avatarContainer
                            width: 140
                            height: 140
                            radius: 70
                            anchors.centerIn: parent

                            LinearGradient {
                                anchors.fill: parent
                                start: Qt.point(0, 0)
                                end: Qt.point(parent.width, parent.height)
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: primaryColor }
                                    GradientStop { position: 1.0; color: secondaryColor }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "👤"
                                color: "white"
                                font.pixelSize: 40
                            }

                            // 等级徽章
                            Rectangle {
                                width: 36
                                height: 36
                                radius: 18
                                color: "#ffd700"
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                border.width: 3
                                border.color: cardColor

                                Text {
                                    text: "Lv." + userLevel
                                    anchors.centerIn: parent
                                    color: textPrimary
                                    font {
                                        bold: true
                                        pixelSize: 12
                                        family: "Microsoft YaHei"
                                    }
                                }

                                layer.enabled: true
                                layer.effect: DropShadow {
                                    transparentBorder: true
                                    radius: 4
                                    samples: 9
                                    color: "#40000000"
                                }
                            }
                        }
                    }

                    // 用户基本信息
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12

                        RowLayout {
                            spacing: 12

                            Text {
                                text: userName
                                font {
                                    pixelSize: 28
                                    bold: true
                                    family: "Microsoft YaHei"
                                }
                                color: textPrimary
                            }

                            // 年度大会员标识
                            Rectangle {
                                visible: isAnnualMember
                                width: 100
                                height: 24
                                radius: 12

                                LinearGradient {
                                    anchors.fill: parent
                                    start: Qt.point(0, 0)
                                    end: Qt.point(parent.width, 0)
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#ff8eb3" }
                                        GradientStop { position: 1.0; color: "#fb7299" }
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    spacing: 2

                                    Text {
                                        text: "⭐"
                                        font.pixelSize: 10
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: "年度大会员"
                                        font {
                                            pixelSize: 10
                                            bold: true
                                            family: "Microsoft YaHei"
                                        }
                                        color: "white"
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                }

                                layer.enabled: true
                                layer.effect: DropShadow {
                                    transparentBorder: true
                                    radius: 4
                                    samples: 9
                                    color: "#40fb7299"
                                }
                            }
                        }

                        // 用户简介
                        Text {
                            text: userDescription
                            font {
                                pixelSize: 15
                                family: "Microsoft YaHei"
                            }
                            color: textSecondary
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            lineHeight: 1.4
                        }

                        // 数据统计
                        RowLayout {
                            Layout.topMargin: 8
                            spacing: 30

                            Repeater {
                                model: [
                                    { title: "关注", value: followingCount },
                                    { title: "粉丝", value: followersCount },
                                    { title: "获赞", value: likesCount },
                                    { title: "播放", value: playsCount }
                                ]

                                Loader {
                                    sourceComponent: statItemComponent
                                    onLoaded: {
                                        item.title = modelData.title
                                        item.value = modelData.value
                                    }
                                }
                            }
                        }
                    }

                    // 操作按钮区域
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        spacing: 12

                        Button {
                            text: "➕ 关注"
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                radius: 8
                                color: parent.down ? secondaryColor : primaryColor

                                layer.enabled: true
                                layer.effect: DropShadow {
                                    transparentBorder: true
                                    radius: 6
                                    samples: 13
                                    color: "#30fb7299"
                                }
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font {
                                    pixelSize: 14
                                    bold: true
                                    family: "Microsoft YaHei"
                                }
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "💬 发消息"
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                radius: 8
                                border.color: borderColor
                                border.width: 1
                                color: parent.down ? "#f5f5f5" : cardColor
                            }
                            contentItem: Text {
                                text: parent.text
                                color: textSecondary
                                font {
                                    pixelSize: 14
                                    family: "Microsoft YaHei"
                                }
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // 更多操作按钮
                        Button {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                radius: 8
                                border.color: borderColor
                                border.width: 1
                                color: parent.down ? "#f5f5f5" : cardColor
                            }
                            contentItem: Text {
                                text: "⋯"
                                color: textSecondary
                                font {
                                    pixelSize: 18
                                    bold: true
                                    family: "Microsoft YaHei"
                                }
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: contextMenu.popup()

                            Menu {
                                id: contextMenu
                                y: parent.height

                                MenuItem {
                                    text: "📋 分享主页"
                                    font.family: "Microsoft YaHei"
                                }
                                MenuItem {
                                    text: "🚫 拉黑用户"
                                    font.family: "Microsoft YaHei"
                                }
                                MenuItem {
                                    text: "⚠️ 举报用户"
                                    font.family: "Microsoft YaHei"
                                }
                            }
                        }
                    }
                }
            }

            // 导航标签栏
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: cardColor
                z: 1

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    radius: 8
                    samples: 17
                    color: "#10000000"
                    verticalOffset: 2
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 40
                    anchors.rightMargin: 40
                    spacing: 0

                    Repeater {
                        model: ["🏠 主页", "📱 动态", "🎬 投稿", "📚 合集", "🎓 课程"]

                        Button {
                            text: modelData
                            Layout.preferredHeight: parent.height
                            Layout.preferredWidth: 100
                            flat: true

                            background: Rectangle {
                                color: "transparent"

                                Rectangle {
                                    width: parent.width - 20
                                    height: 3
                                    color: primaryColor
                                    visible: tabBar.currentIndex === index
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    radius: 1.5
                                }
                            }

                            contentItem: Text {
                                text: parent.text
                                color: tabBar.currentIndex === index ? primaryColor : textSecondary
                                font {
                                    pixelSize: 14
                                    bold: tabBar.currentIndex === index
                                    family: "Microsoft YaHei"
                                }
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: tabBar.currentIndex = index
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // 搜索框
                    Rectangle {
                        Layout.preferredWidth: 240
                        Layout.preferredHeight: 40
                        radius: 20
                        border.color: borderColor
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8

                            Text {
                                text: "🔍"
                                font.pixelSize: 14
                                color: textHint
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 8
                            }

                            TextField {
                                placeholderText: "搜索TA的视频..."
                                placeholderTextColor: textHint
                                font {
                                    pixelSize: 14
                                    family: "Microsoft YaHei"
                                }
                                Layout.fillWidth: true
                                background: Rectangle {
                                    color: "transparent"
                                }
                            }
                        }
                    }
                }
            }

            // 标签内容区域
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 600

                StackLayout {
                    id: tabBar
                    anchors.fill: parent
                    currentIndex: 0

                    // 主页标签
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 30
                            spacing: 24

                            Text {
                                text: "🎯 代表作"
                                font {
                                    pixelSize: 22
                                    bold: true
                                    family: "Microsoft YaHei"
                                }
                                color: textPrimary
                            }

                            // 代表作网格
                            GridLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                columns: 4
                                columnSpacing: 24
                                rowSpacing: 24

                                Repeater {
                                    model: 8

                                    Loader {
                                        sourceComponent: videoCardComponent
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 200
                                    }
                                }
                            }
                        }
                    }

                    // 其他标签页内容
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 40

                            Text {
                                text: "📱 动态页面"
                                font {
                                    pixelSize: 24
                                    bold: true
                                    family: "Microsoft YaHei"
                                }
                                color: textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "这里将展示用户的动态和互动内容"
                                font {
                                    pixelSize: 16
                                    family: "Microsoft YaHei"
                                }
                                color: textHint
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // 其他标签页保持类似结构...
                }
            }
        }
    }
}
