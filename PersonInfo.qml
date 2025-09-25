import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    RowLayout {
        anchors.fill: parent
        anchors.margins: 10

        // 用户头像
        Image {
            source: "qrc:/avatar.png"
            width: 40
            height: 40
            fillMode: Image.PreserveAspectFit
        }

        // 用户名和硬币数
        Column {
            spacing: 5
            Text { text: "aaa 🎮 大会员"; font.bold: true }
            Text { text: "B币: 0  硬币: 794"; color: "gray" }
        }

        // 动态/关注/粉丝数
        RowLayout {
            spacing: 20
            Text { text: "1 动态" }
            Text { text: "63 关注" }
            Text { text: "1 粉丝" }
        }

        // 成为大会员按钮
        Button {
            text: "成为大会员"
            background: Rectangle { color: "pink"; radius: 4 }
        }
    }
}
