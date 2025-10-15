//视频列表

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {

    GridView {
        id: videoGrid
        cellWidth: 200
        cellHeight: 250
        model: 12

        delegate: Rectangle {
            width: videoGrid.cellWidth - 10
            height: videoGrid.cellHeight - 10
            color: "white"
            radius: 4

            Column {
                anchors.fill: parent
                spacing: 5

                Image {
                    source: ""
                    width: parent.width
                    height: 120
                    fillMode: Image.PreserveAspectCrop
                }

                // 视频标题
                Text {
                    width: parent.width
                    text: "【虚拟偶像】超燃 AMV 混剪"
                    wrapMode: Text.Wrap
                    font.pixelSize: 14
                    maximumLineCount: 2
                }

                // 博主信息
                Row {
                    spacing: 5
                    Image {
                        source: ""
                        width: 20
                        height: 20
                    }
                    Text { text: "UP主名称"; color: "gray"; font.pixelSize: 12 }
                }
            }
        }
    }
}

