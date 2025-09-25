import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Repeater {
            model: ["🏠", "🔥", "👤"]
            delegate: Button {
                width: 40
                height: 40
                text: modelData
                font.pixelSize: 20
                background: Rectangle {
                    color: "transparent"
                }
            }
        }
    }
}
