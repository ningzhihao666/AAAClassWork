// 缓存设置

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    id: cacheSettings

    spacing: 20

    Text {
        text: "缓存设置"
        font.bold: true
        font.pixelSize: 20
        color: "black"
    }

    Column {
        width: parent.width
        spacing: 10

        Text {
            text: "客户端缓存（已缓存：57.37 MB）"
            color: "black"
        }

        Button {
            text: "清理客户端缓存"
            width: 150
            height: 35
        }
    }

    Column {
        width: parent.width
        spacing: 10

        Text {
            text: "系统DNS缓存（登录或数据加载失败，可尝试清除）"
            color: "black"
        }

        Button {
            text: "清除系统DNS缓存"
            width: 150
            height: 35
        }
    }

    Column {
        width: parent.width
        spacing: 10

        Text {
            text: "窗口状态缓存（若播放窗口无法打开，可尝试恢复）"
            color: "black"
        }

        Button {
            text: "强制恢复窗口状态"
            width: 150
            height: 35
        }
    }
}
