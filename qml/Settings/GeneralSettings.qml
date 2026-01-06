//常规设置

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: generalSettings
    spacing: 20

    Text {
        text: "常规设置"
        font.bold: true
        font.pixelSize: 20
        color: "black"
    }

    ColumnLayout {
        width: parent.width
        spacing: 8

        Text {
            text: "启动时颜色模式："
            font.pixelSize: 14
            color: "black"
        }

        Text {
            text: "更改模式后将于下次启动时生效"
            font.pixelSize: 12
            color: "gray"
        }

        ComboBox {
            model: ["自动记忆", "浅色模式", "深色模式"]
            width: 200
        }
    }

    Column {
        width: parent.width
        spacing: 8

        Text {
            text: "字体选择："
            font.pixelSize: 14
            color: "black"
        }

        Text {
            text: "若字体显示异常，可切换为默认字体"
            font.pixelSize: 12
            color: "gray"
        }

        ComboBox {
            model: ["HarmonyOS Sans", "默认字体", "系统字体"]
            width: 200
        }
    }

    CheckBox {
        text: "开机自动启动"
        font.pixelSize: 14
        width: parent.width
    }
    CheckBox {
        text: "启动时默认进入精选页"
        font.pixelSize: 14
        width: parent.width
    }
    CheckBox {
        text: "禁用GPU加速（如果界面显示异常或模糊尝试勾选此项，一般不推荐禁用）"
        font.pixelSize: 14
        width: parent.width
    }

    Column {
        width: parent.width
        spacing: 8

        Text {
            text: "关闭主界面时："
            font.pixelSize: 14
            color: "black"
        }

        ComboBox {
            model: ["最小化到系统托盘", "退出哔哩哔哩程序", "关闭时提示"]
            width: 250
        }
    }

}
