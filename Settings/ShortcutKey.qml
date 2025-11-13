//快捷键设置

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: shortcutKey

    spacing: 20
    Text {
        text: "快捷键"
        font.bold: true
        font.pixelSize: 16
        color: "black"
    }

    Text {
        text: "快捷键使用说明"
        font.pixelSize: 14
        color: "gray"
    }

    Text {
        text: "老板键：（快速隐藏和显示程序，隐藏时会暂停正在播放的视频）"
        width: parent.width
        color: "gray"
    }

    RowLayout {
        spacing: 10
        CheckBox {
            id: bossKeyCheckbox
            text: "开启老板键"
            checked: true
        }
        Rectangle {
            width: keyLabel.width + 20
            height: 25
            color: "whitesmoke"
            border.color: "gray"
            border.width: 1
            radius: 4

            Text {
                id: keyLabel
                text: "Ctrl + Shift + C"
                anchors.centerIn: parent
                font.pixelSize: 12
                color: "black"
            }
        }
    }

}
