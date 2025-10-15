//“我的”视频分类

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    spacing: 20
    Repeater {
        model: ["历史记录", "离线缓存", "我的收藏", "稍后再看"]
        delegate: Button {
            text: modelData
            font.pixelSize: 14
            background: Rectangle{
                color:parent.hovered ? "grey" : "transparent" // 悬停时背景框变为灰色
            }
            contentItem: Text {
                text: parent.text
                color: parent.focus ? "red" : "black"  // 按下时文本变为红色
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 20
            }
        }
    }
}
