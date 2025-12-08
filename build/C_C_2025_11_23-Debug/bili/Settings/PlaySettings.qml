//播放设置

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: playSettings

    spacing: 20

    Text {
        text: "播放设置"
        font.bold: true
        font.pixelSize: 20
        color: "black"
    }

    CheckBox {
        text: "动态页视频自动播放"
        width: parent.width
    }
    CheckBox {
        text: "开启多媒体会话服务"
        checked: true
        width: parent.width
    }
    CheckBox {
        text: "本地视频默认通过哔哩哔哩打开"
        width: parent.width
    }
    CheckBox {
        text: "全屏播放切换窗口消除白边"
        width: parent.width
    }

}
