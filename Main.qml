import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    StackView {
        id: stackView
        // anchors.fill: parent
        initialItem: Component {
                    MainPage {}
                }  // 加载外部QML文件作为初始页面
    }
}
