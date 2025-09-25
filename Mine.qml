import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1200
    height: 800
    visible: true
    title: "哔哩哔哩 QML 客户端"

    // 工具栏
    RowLayout{
        anchors.fill: parent
        spacing: 10

        ToolBars{
            id: leftNav
            visible: true
            Layout.preferredWidth: 60
            Layout.preferredHeight: parent.height
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }


        // 主内容区
        Rectangle {
            anchors.left: leftNav.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "#F9F9F9"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 顶部个人界面
                PersonInfo {
                    Layout.fillWidth: true
                    height: 60
                    color: "white"
                }

                //视频类型
                VedioType {
                    id:vediotype
                    Layout.fillWidth: true
                }
                // 视频列表
                VedioList {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                }
            }
        }
    }
}
