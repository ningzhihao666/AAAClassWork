//推送设置

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: pushSettings

    spacing: 25

    Text {
        text: "推送设置"
        font.bold: true
        font.pixelSize: 20
        color: "black"
    }

    ColumnLayout {
        width: parent.width
        spacing: 10

        Text {
            text: "热门内容推送："
            font.pixelSize: 14
            color: "black"
        }

        Text {
            text: "开启后，每周五将推送每周必看"
            width: parent.width
            font.pixelSize: 12
            color: "gray"
        }

        RowLayout {
            spacing: 20
            RadioButton { text: "开启" }//单选按钮，只能选择一个
            RadioButton { text: "关闭"; checked: true }
        }
    }

    ColumnLayout {
        width: parent.width
        spacing: 10

        Text {
            text: "主播开播提醒："
            font.pixelSize: 14
            color: "black"
        }

        Text {
            text: "开启后，将推送主播开播提示"
            width: parent.width
            font.pixelSize: 12
            color: "gray"
        }

        Row {
            spacing: 20
            RadioButton { text: "开启" }
            RadioButton { text: "关闭"; checked: true }
        }
    }

    ColumnLayout {
        width: parent.width
        spacing: 10

        Text {
            text: "关注UP主更新推送："
            font.pixelSize: 14
            color: "black"
        }

        Text {
            text: "开启后，推送关注的UP主稿件"
            width: parent.width
            font.pixelSize: 12
            color: "gray"
        }

        RowLayout {
            spacing: 20
            RadioButton { text: "开启" }
            RadioButton { text: "关闭"; checked: true }
        }
    }
}
