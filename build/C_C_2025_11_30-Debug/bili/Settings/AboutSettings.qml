//关于页面

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    id: aboutSettings

    spacing: 20

    Text {
        text: "关于哔哩哔哩"
        font.bold: true
        font.pixelSize: 20
        color: "black"
    }

    Rectangle {
        width: parent.width
        height: 80
        color: "whitesmoke"
        border.color: "lightgray"
        border.width: 1
        radius: 8

        Column {
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: "当前版本：117.3"
                font.pixelSize: 16
                color: "black"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "构建号：10010170032510141117(21104969)"
                font.pixelSize: 12
                color: "gray"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    RowLayout {
        spacing: 15
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            text: "检查更新"
            background: Rectangle {
                color: "deeppink"
                radius: 5
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            height: 35
            width: 100
        }
        Button {
            text: "反馈意见"
            height: 35
            width: 100
        }
        Button {
            text: "客服中心"
            height: 35
            width: 100
        }
    }

    Rectangle {
        width: parent.width
        height: 60
        color: "whitesmoke"
        radius: 8

        Row {
            anchors.centerIn: parent
            spacing: 25

            Button {
                text: "《哔哩哔哩官网》"
                flat: true
                contentItem: Text {
                    text: parent.text
                    color: "skyblue"
                }
            }
            Button {
                text: "《用户协议》"
                flat: true
                contentItem: Text {
                    text: parent.text
                    color: "skyblue"
                }
            }
            Button {
                text: "《隐私政策》"
                flat: true
                contentItem: Text {
                    text: parent.text
                    color: "skyblue"
                }
            }
        }
    }

    Text {
        text: "© 2023 哔哩哔哩 版权所有"
        font.pixelSize: 12
        color: "lightgray"
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
