// 手柄设置

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    id: gamepadSettings
    spacing: 20

    property bool gamepadConnected: false
    property string currentGamepad: ""

    Text {
        text: "手柄设置"
        font.bold: true
        font.pixelSize: 20
        color: "black"
    }

    // 连接状态显示
    Rectangle {
        width: parent.width
        height: 80
        color: gamepadConnected ? "pink" : "white"
        border.color: gamepadConnected ? "lightgreen" : "lightgray"
        border.width: 1
        radius: 8

        Column {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: gamepadConnected ? "✅ 手柄已连接" : "❌ 未检测到手柄连接"
                font.pixelSize: 16
                color: gamepadConnected ? "darkgreen" : "gray"
            }

            Text {
                text: gamepadConnected ? "设备: " + currentGamepad : "点击下方按钮连接手柄"
                font.pixelSize: 12
                color: "gray"
                visible: gamepadConnected || !gamepadConnected
            }
        }
    }

    // 连接/断开按钮
    Button {
        text: gamepadConnected ? "断开连接" : "连接手柄"
        anchors.horizontalCenter: parent.horizontalCenter
        background: Rectangle {
            color: gamepadConnected ? "red" : "deeppink"
            radius: 5
        }
        contentItem: Text {
            text: parent.text
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        height: 35
        width: 120
        onClicked: {
            if (gamepadConnected) {
                disconnectGamepad()
            } else {
                connectGamepad()
            }
        }
    }

    // 设备选择下拉框（连接时显示）
    ComboBox {
        width: 200
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !gamepadConnected
        model: ["Xbox 无线控制器", "PlayStation DualSense", "Switch Pro 控制器", "通用游戏手柄"]
        onActivated: {
            currentGamepad = model[currentIndex]
            gamepadConnected = true
        }
    }



    // === 简单函数 ===
    function connectGamepad() {
        // 这里会通过ComboBox选择设备
    }

    function disconnectGamepad() {
        gamepadConnected = false
        currentGamepad = ""
    }
}
