
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: mainWindow
    width: 800
    height: 600
    visible: true
    title: qsTr("B站风格视频上传器")

    VideoLode {
        anchors.fill: parent
    }
}
