//主页
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FrameLessWindow{
    id: root
    width: 1100
    height: 800
    visible: true
    title: "哔哩哔哩 (゜-゜)つロ 干杯~"
    flags: Qt.FramelessWindowHint // 无边框窗口

    Rectangle {
        id: topBar
        width: parent.width
        height: 60
        color: "white"

        RowLayout {

            anchors.fill: parent
            anchors.topMargin: 20
            anchors.rightMargin: 10
            spacing: 10

            Label{
                // anchors.fill: parent
                anchors.left: parent.left
                anchors.right: funcRegion.left
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                text:"bilibili"
                color:"pink"
                font.pixelSize: 14
                width: 30
                height: 30
            }
            RowLayout {
                id:funcRegion
                spacing: 10
                width: parent.width-50

                Repeater {
                    model: ["直播", "推荐", "热门", "追番", "影视", "热门", "漫画", "赛事", "直播"]
                    delegate: Rectangle {
                        width: 60
                        height: 40
                        radius: 20
                        color: index === 1 ? "#FB7299" : "white"
                        border.color: index === 1 ? "#FB7299" : "#E5E9EF"

                        Text {
                            text: modelData
                            anchors.centerIn: parent
                            color: index === 1 ? "white" : "black"
                            font.pixelSize: 13
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.border.color = "#FB7299"
                            onExited: parent.border.color = index === 1 ? "#FB7299" : "#E5E9EF"
                            onClicked: console.log("切换到:", modelData)
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

                placeholderText: "搜索你感兴趣的视频  🔍"
                placeholderTextColor: "gray"
                background: Rectangle {
                    color: "#F0F0F0"
                    border.color: search.focus ? "#00BFFF" : "transparent"
                    radius: 4
                }

                Button{
                    id: clearButton
                    background:Rectangle{
                        color: clearButton.hovered ? "lightgray" : "#F0F0F0"
                    }
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text: "×"
                    onClicked:
                    search.text = ""
                    opacity: search.focus ? 1 :0
                }
            }

            Rectangle{
                id:line
                anchors.right: controls.left
                // anchors.left: search.right
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                Text {
                        anchors.centerIn: parent
                        text: "|"
                        font.pixelSize: 20
                        color: "lightgray"
                    }
            }

            RowLayout {
                id:controls
                spacing: 10
                anchors.right:parent.right
                Layout.rightMargin: 20


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


    ScrollView {
        anchors {
            top: topBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentWidth: availableWidth
        clip: true
        padding: 20

        ColumnLayout {
            width: root.width - 15
            spacing: 20

            // 视频推荐网格
            GridView {
                id: videoGrid
                Layout.fillWidth: true
                height: 1200
                cellWidth: width / 4 - 10
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
                                source: "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"
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
                }
            }

            // 加载更多
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

                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("加载更多视频")
                }
            }
        }
    }
}
