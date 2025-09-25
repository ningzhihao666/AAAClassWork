import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1200
    height: 800
    visible: true
    title: "哔哩哔哩 QML 客户端"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ToolBars {
            id: leftNav
            Layout.preferredWidth: 60
            Layout.fillHeight: true
        }

        // 主内容区
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#F9F9F9"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 顶部个人界面
                PersonInfo {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                }

                // 视频类型
                VedioType {
                    id: vediotype
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                }

                // 视频列表
                VedioList {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
