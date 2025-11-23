import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
            id: mainWindow
            // width: 900
            // height: 650
            // title: "哔哩哔哩设置"
            // visible: true
            anchors.fill: parent

            Flickable { //这个就是可以通过鼠标或者键盘滑动
                        id: mainFlickable
                        anchors.fill: parent
                        contentWidth: parent.width
                        contentHeight: settingsColumn.height + 40 //内容区域的大小
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds //这个的意思是就是滚动到边界时停止

                        ColumnLayout {
                                    id: settingsColumn
                                    anchors.margins: 25
                                    width: parent.width-25
                                    x:25
                                    y:25

                                    spacing: 30



                                    PlaySettings {Layout.fillWidth: true }

                                    SectionDivider { Layout.fillWidth: true}

                                    ShortcutKey{Layout.fillWidth: true}

                                    SectionDivider { Layout.fillWidth: true}

                                    PushSettings { Layout.fillWidth: true}

                                    SectionDivider { Layout.fillWidth: true}

                                    DownloadSettings { Layout.fillWidth: true}

                                    SectionDivider { Layout.fillWidth: true}

                                    CacheSettings { Layout.fillWidth: true}

                                    SectionDivider { Layout.fillWidth: true}

                                    GamepadSettings { Layout.fillWidth: true}

                                    SectionDivider { Layout.fillWidth: true}

                                    GeneralSettings { Layout.fillWidth: true}

                                    SectionDivider { Layout.fillWidth: true}

                                    AboutSettings { Layout.fillWidth: true}
                        }
            }


            FileDialog {
                        id: fileDialog
                        title: "选择缓存目录"
                        // selectFolder: true
                        onAccepted: {
                                    // 处理文件选择
                        }
            }
            // }
            // 分隔线组件
            // Rectangle {
            //             id: dividedLine
            //             width: parent.width
            //             height: 2
            //             color: "lightgray"
            // }
}
