import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

FrameLessWindow {
    id: videoPlayerPage
    color: "transparent"
    width: 1300
    height: 800
    visible: true
    title: "B站视频播放器"

    property string currentView:"info"  //获取当前简介或者评论状态
    property string currentCommit: "close"  //获取当前展开或者关闭
    property bool attention: false;     //获取关注的up


    property bool isAlwaysOnTop: false   //置顶窗口
    flags: {
            var baseFlags = Qt.Window | Qt.FramelessWindowHint;
            if (isAlwaysOnTop) {
                return baseFlags | Qt.WindowStaysOnTopHint;
            } else {
                return baseFlags;
            }
        }

    // 主容器 - 添加圆角效果
    Rectangle {
        id: mainContainer
        anchors.fill: parent
        radius: 10
        color: "#121212"
        clip: true

        // 顶部标题栏
        Rectangle {
            id: titleBar
            width: parent.width
            height:60
            topLeftRadius: 10
            topRightRadius: 10
            bottomLeftRadius: 0
            bottomRightRadius: 0
            anchors.top: parent.top
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#3A3A3A" }
                GradientStop { position: 1.0; color: "#2D2D2D" }
            }   //渐变，从左到右

            TapHandler
            {
                acceptedButtons: Qt.LeftButton
                onDoubleTapped:
                {
                    if (videoPlayerPage.visibility === Window.Maximized) {
                                    videoPlayerPage.visibility = Window.Windowed
                                } else {
                                    videoPlayerPage.visibility = Window.Maximized
                                }
                }
            }  //双击窗口放大或缩小

            RowLayout
            {
                anchors.fill: parent
                anchors.margins: 10

                spacing: 8

                Button
                {
                    id:backButton
                    text:"回到主界面"
                    font.pixelSize: 18
                    font.bold: true
                    Layout.preferredWidth: parent.width * 0.12
                    Layout.preferredHeight: parent.height


                    contentItem: Text {
                        text:backButton.text
                        font: backButton.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }  //自定义字体格式

                    background:Rectangle
                    {
                        id:buttonBackground
                        radius: 10
                        color: backButton.hovered ? "#6A6A6A"  :  "#4A4A4A"
                        opacity:backButton.down? 0.5 : 1
                    }  //设置按钮背景

                    onClicked:
                    {
                        //点击操作
                    }
                }

                Button
                {
                    id:leftButton
                    text:"<"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.preferredWidth: parent.width * 0.04
                    Layout.preferredHeight: parent.height

                    contentItem: Text {
                        text:leftButton.text
                        font: leftButton.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }  //自定义字体格式

                    background:Rectangle
                    {
                        id:leftbackground
                        radius: 10
                        color: leftButton.down ? "#6A6A6A":"#7A7A7A"
                        opacity:leftButton.hovered? 0.5 : 0
                    }  //设置按钮背景

                    onClicked:
                    {
                        //点击操作
                    }
                }

                Button
                {
                    id:rightButton
                    text:">"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.preferredWidth: parent.width * 0.04
                    Layout.preferredHeight: parent.height

                    contentItem: Text {
                        text:rightButton.text
                        font: rightButton.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }  //自定义字体格式

                    background:Rectangle
                    {
                        id:rightbackground
                        radius: 10
                        color: rightButton.down ? "#6A6A6A":"#7A7A7A"
                        opacity:rightButton.hovered? 0.5 : 0
                    }  //设置按钮背景

                    onClicked:
                    {
                        //点击操作
                    }
                }

                Item {
                     Layout.fillWidth: true
                 }


            }


            // 窗口控制按钮
            RowLayout {
                id:f
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                anchors.margins: 10
                height: parent.height

                Button {
                    id: pinButton
                    Layout.preferredWidth: titleBar.width * 0.04
                    Layout.preferredHeight: parent.height * 0.7
                    text: videoPlayerPage.isAlwaysOnTop ? "📌" : "📍"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter // 添加垂直居中

                    contentItem: Text {
                        text:pinButton.text
                        font: pinButton.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }  //自定义字体格式

                    background: Rectangle {
                        radius: 5
                        color: pinButton.down ? "#6A6A6A":"#7A7A7A"
                        opacity:pinButton.hovered? 0.5 : 0
                    }
                    onClicked: {
                        videoPlayerPage.isAlwaysOnTop = !videoPlayerPage.isAlwaysOnTop
                    }
                }

                    // 分隔线
                    Rectangle {
                        width: 1
                        height: parent.height * 0.6
                        color: "#666666"
                        Layout.alignment: Qt.AlignVCenter
                        opacity: 0.7
                    }

                // 最小化按钮
                Button {
                    id: minimizeButton
                    Layout.preferredWidth: titleBar.width * 0.04
                    Layout.preferredHeight: parent.height * 0.7
                    text: "—"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter // 添加垂直居中

                    contentItem: Text {
                        text:minimizeButton.text
                        font: minimizeButton.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }  //自定义字体格式

                    background: Rectangle {
                        radius: 5
                        color: minimizeButton.down ? "#6A6A6A":"#7A7A7A"
                        opacity:minimizeButton.hovered? 0.5 : 0
                    }
                    onClicked: {
                        videoPlayerPage.visibility = Window.Minimized
                    }
                }

                // 最大化/还原按钮
                Button {
                    id: maximizeButton
                    Layout.preferredWidth: titleBar.width * 0.04
                    Layout.preferredHeight: parent.height * 0.7
                    text: videoPlayerPage.visibility === Window.Maximized ? "❐" : "□"
                    font.pixelSize: 25
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter // 添加垂直居中
                    contentItem: Text {
                        text:maximizeButton.text
                        font: maximizeButton.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }  //自定义字体格式
                    background: Rectangle {
                        radius: 5
                        color: maximizeButton.down ? "#6A6A6A":"#7A7A7A"
                        opacity:maximizeButton.hovered? 0.5 : 0
                    }
                    onClicked: {
                        if (videoPlayerPage.visibility === Window.Maximized) {
                            videoPlayerPage.visibility = Window.Windowed
                        } else {
                            videoPlayerPage.visibility = Window.Maximized
                        }
                    }


                }

                // 关闭按钮 - 修复版本
                Button {
                    id: closeButton
                    Layout.preferredWidth: titleBar.width * 0.04
                    Layout.preferredHeight: parent.height * 0.7
                    font.pixelSize: 25
                    font.bold: true
                    text: "×"
                    Layout.alignment: Qt.AlignVCenter // 添加垂直居中
                    contentItem: Text {
                        text:closeButton.text
                        font: closeButton.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }  //自定义字体格式
                    background: Rectangle {
                        radius: 5
                        color: closeButton.down ? "#6A6A6A":"#7A7A7A"
                        opacity:closeButton.hovered? 0.5 : 0
                    }
                    onClicked: {
                        Qt.quit();
                    }

                 }
            }

          } //标题栏部分

        //=======视频部分=========

        Rectangle
        {
            id:content
            anchors
            {
                top:titleBar.bottom
                left:parent.left
                right:parent.right
                bottom:parent.bottom
            }
            color: "transparent"

            RowLayout
            {
                anchors.fill: parent

                Rectangle
                {
                    id:vedio
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 5/7
                    color: "transparent"

                    Text {
                                                text: "视频播放区域"
                                                color: "#666666"
                                                font.pixelSize: 24
                                                anchors.centerIn: parent
                                            }
                }

                Rectangle
                {

                    id:info
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 2/7
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#2A2A2A" }
                        GradientStop { position: 1.0; color: "#1D1D1D" }
                    }

                    ColumnLayout
                    {
                        anchors.fill: parent

                        RowLayout
                        {
                            id:widthNum
                            Layout.preferredWidth: parent.width
                            Layout.preferredHeight: parent.height * 0.08
                            spacing: 25

                            Button {
                                id: infoButton
                                Layout.preferredWidth: parent.width * 0.15
                                Layout.preferredHeight: parent.height * 0.7
                                Layout.leftMargin:20
                                font.pixelSize: 18
                                text: "简介"
                                Layout.alignment: Qt.AlignVCenter // 添加垂直居中
                                contentItem: Text {
                                    text:infoButton.text
                                    font: infoButton.font
                                    color:
                                    {
                                        if(videoPlayerPage.currentView === "info" || infoButton.hovered)
                                            "pink"
                                          else
                                            "#F0F0F0"
                                    }

                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }  //自定义字体格式
                                background: Rectangle {
                                    radius: 5
                                    color:"transparent"
                                    // Rectangle {
                                    //             anchors {
                                    //                 bottom: parent.bottom
                                    //                 horizontalCenter: parent.horizontalCenter
                                    //             }
                                    //             width: parent.width * 0.8
                                    //             height: 3
                                    //             color: "pink"
                                    //             visible: videoPlayerPage.currentView === "info"
                                    //         }

                                }
                                onClicked: {
                                    videoPlayerPage.currentView = "info"
                                    //操作
                                }

                             }

                            Button {
                                id: commitButton
                                Layout.preferredWidth: parent.width * 0.15
                                Layout.preferredHeight: parent.height * 0.7
                                anchors.leftMargin: 40
                                font.pixelSize: 18
                                text: "评论"
                                Layout.alignment: Qt.AlignVCenter // 添加垂直居中
                                contentItem: Text {
                                    text:commitButton.text
                                    font: commitButton.font
                                    color:
                                    {
                                        if(videoPlayerPage.currentView === "commit" || commitButton.hovered)
                                            "pink"
                                        else
                                            "#F0F0F0"
                                    }
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }  //自定义字体格式
                                background: Rectangle {
                                    radius: 5
                                    color: "transparent"
                                    // Rectangle {
                                    //             anchors {
                                    //                 bottom: parent.bottom
                                    //                 horizontalCenter: parent.horizontalCenter
                                    //             }
                                    //             width: parent.width * 0.8
                                    //             height: 3
                                    //             color: "pink"
                                    //             visible: videoPlayerPage.currentView === "commit"
                                    //         }
                                }
                                onClicked: {
                                    videoPlayerPage.currentView = "commit"
                                    //操作
                                }

                             }


                            Rectangle
                            {

                                radius: 10
                                Layout.preferredHeight: commitButton.height * 0.7
                                implicitWidth: te.implicitWidth + 20
                                color:"#3A3A3A"
                                Layout.leftMargin: -30

                                Text {
                                    id:te
                                    text: "这里获得评论数"
                                    color:"#F0F0F0"
                                    anchors.centerIn: parent
                                }
                            }

                            Button {
                                id: aButton
                                Layout.preferredWidth: parent.width * 0.15
                                Layout.preferredHeight: parent.height * 0.7
                                font.pixelSize: 18
                                Layout.rightMargin: 15
                                text: "*"
                                Layout.alignment: Qt.AlignVCenter // 添加垂直居中
                                contentItem: Text {
                                    text: aButton.text
                                    font:  aButton.font
                                    color: "#F0F0F0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }  //自定义字体格式
                                background: Rectangle {
                                    radius: 5
                                    color:  aButton.down ? "#6A6A6A":"#7A7A7A"
                                    opacity: aButton.hovered? 0.5 : 0
                                }
                                onClicked: {
                                    settingsPopup.open()
                                    //操作
                                }

                             }

                            Popup {
                                id: settingsPopup
                                x: aButton.x - width + aButton.width
                                y: aButton.y + aButton.height
                                width: parent.width * 0.4
                                height: contentItem.implicitHeight + padding * 2
                                padding: 5
                                closePolicy: Popup.CloseOnPressOutside

                                background: Rectangle {
                                    color: "#2A2A2A"
                                    radius: 5
                                    border.color: "#4A4A4A"
                                }

                                contentItem: ColumnLayout {
                                    spacing: 5

                                    // 第一个设置按钮
                                    Button {
                                        id:button1
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: titleBar.height * 0.8
                                        text: "稍后观看"
                                        background: Rectangle {
                                            color:
                                            {
                                                if(parent.hovered)
                                                    return "#6A6A6A"
                                                else if(parent.down)
                                                    return "#4A4A4A"
                                                else
                                                    return "transparent"
                                            }
                                            radius: 3
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 10
                                        }

                                        onClicked: {
                                            console.log("设置1被点击")
                                            settingsPopup.close()
                                        }
                                    }

                                    // 第二个设置按钮
                                    Button {
                                        id:button2
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: titleBar.height * 0.8
                                        text:"重新加载"
                                        background: Rectangle {
                                            color:
                                            {
                                                if(parent.hovered)
                                                    return "#6A6A6A"
                                                else if(parent.down)
                                                    return "#4A4A4A"
                                                else
                                                    return "transparent"
                                            }
                                            radius: 3
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 10
                                        }
                                        onClicked: {
                                            console.log("设置2被点击")
                                            settingsPopup.close()
                                        }
                                    }

                                    // 第三个设置按钮
                                    Button {
                                        id:button3
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: titleBar.height * 0.8
                                        text:"稿件举报"
                                        background: Rectangle {
                                            color:
                                            {
                                                if(parent.hovered)
                                                    return "#6A6A6A"
                                                else if(parent.down)
                                                    return "#4A4A4A"
                                                else
                                                    return "transparent"
                                            }

                                            radius: 3
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 10
                                        }
                                        onClicked: {
                                            console.log("设置3被点击")
                                            settingsPopup.close()
                                        }
                                    }
                                }
                            }

                        }

                        Rectangle {
                                    id:currentRect
                                    width: infoButton.width * 0.8
                                    height: infoButton.height * 0.2
                                    color: "pink"
                                    visible: true
                                    z:500
                                    x: {
                                        if (videoPlayerPage.currentView === "info") {
                                            return infoButton.x + (infoButton.width - width) / 2
                                        } else {
                                            return commitButton.x + (commitButton.width - width) / 2
                                        }
                                    }
                                    // 添加动画效果
                                    Behavior on x {
                                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                }  //简介和评论下标

         // 简介部分===================//========================
                        Item {
                            visible: videoPlayerPage.currentView === "info"
                            Layout.fillHeight: true // 填充可用高度
                            Layout.fillWidth: true  // 填充可用宽度

                    ColumnLayout
                    {
                        anchors.fill: parent

                        RowLayout
                        {
                            Layout.topMargin: 15
                            Layout.fillWidth: true
                            Rectangle
                            {
                                 Layout.leftMargin: 15
                                width:videoPlayerPage.height/16
                                height: width
                                radius: width/2
                                color: "grey"
                            }


                            ColumnLayout
                            {
                                Layout.leftMargin: 10
                                Text {
                                    text: "UP主名字"
                                    color:"white"
                                }

                                Text {
                                    text: "粉丝数量，点赞数"
                                    color:"grey"
                                }
                            }

                            Item {
                                 Layout.fillWidth: true
                             } //填充


                            Button {
                                id:bButton
                                Layout.rightMargin: 20
                                Layout.preferredWidth: parent.width * 0.2
                                Layout.preferredHeight: parent.height * 0.7
                                font.pixelSize: 18
                                font.bold: true

                                text:
                                {
                                    if(videoPlayerPage.attention)
                                        return "已关注"
                                    else
                                        return "+关注"
                                }

                                Layout.alignment: Qt.AlignVCenter // 添加垂直居中
                                contentItem: Text {
                                    text: bButton.text
                                    font:  bButton.font
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }  //自定义字体格式
                                background: Rectangle {
                                    radius: 5
                                    color:
                                    {
                                        if(videoPlayerPage.attention)
                                            return "black"
                                        else
                                            return bButton.down ? "#6A6A6A":"#FF5252"
                                    }

                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: 300
                                                    easing.type: Easing.InOutQuad
                                                }
                                            }

                                }
                                onClicked: {
                                    videoPlayerPage.attention = !videoPlayerPage.attention;
                                    //操作
                                }

                             }

                        }

                        RowLayout
                        {
                            Layout.topMargin: 15
                            width:parent.width

                            ColumnLayout
                            {
                                Layout.leftMargin: 15
                                Text {
                                    text: "视频标题"
                                    color:"white"
                                    font.bold: true;
                                    font.pixelSize: 18
                                }

                                RowLayout
                                {
                                    spacing: 30

                                    Text {
                                        text: "播放量"
                                        color:"grey"
                                    }

                                    Text {
                                        text: "评论数"
                                        color:"grey"
                                    }

                                    Text {
                                        text: "日期"
                                        color:"grey"
                                    }
                                }
                            }


                            Item {
                                 Layout.fillWidth: true
                             } //填充

                            Button {
                                id:cButton
                                Layout.rightMargin: 20
                                Layout.preferredWidth: parent.width * 0.15
                                Layout.preferredHeight: parent.height * 0.5
                                text:
                                {
                                    if(videoPlayerPage.currentCommit=== "open")
                                    {
                                         return "关闭"
                                    }else
                                    {
                                       return "展开"
                                    }
                                }

                                font.pixelSize: 15
                                Layout.alignment: Qt.AlignVCenter // 添加垂直居中
                                contentItem: Text {
                                    text: cButton.text
                                    font:  cButton.font
                                    color  :cButton.hovered ?  "#FF5252" : "grey"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }  //自定义字体格式
                                background: Rectangle {
                                    color: "transparent"
                                    // opacity: bButton.hovered? 0.5 : 0
                                }
                                onClicked: {
                                    if(videoPlayerPage.currentCommit === "open")
                                    {
                                        videoPlayerPage.currentCommit = "close"
                                    }else
                                    {
                                        videoPlayerPage.currentCommit = "open"
                                    }
                                    //操作
                                }

                             }

                        }

                        // 可展开的内容区域
                            Rectangle {
                                Layout.leftMargin: 15
                                Layout.topMargin: 5
                                id: expandableContent
                                Layout.fillWidth: true
                                Layout.preferredHeight: videoPlayerPage.currentCommit==="open" ? 200 : 0   //200改成具体的简介数量
                                color: "transparent"
                                clip: true

                                Behavior on Layout.preferredHeight {
                                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                }

                                // 这里添加展开后的内容
                                Text {
                                    text: "这里是展开后的内容"
                                    color: "grey"
                                    }
                        }

                            RowLayout
                            {
                              width: parent.width
                              Layout.topMargin: 20
                              Layout.fillWidth: true
                              ColumnLayout
                              {
                                Layout.leftMargin: 25
                                  spacing: 5
                                  Text {
                                      text: "图片"
                                      color: "white"
                                      }
                                  Text {
                                      text:"点赞数"
                                      color: "white"
                                  }
                              }

                              Item {
                                   Layout.fillWidth: true
                               } //填充

                              ColumnLayout
                              {
                                  spacing: 5
                                  Text {
                                      text: "图片"
                                      color: "white"
                                      }
                                  Text {
                                      text:"点赞数"
                                      color: "white"
                                  }
                              }

                              Item {
                                   Layout.fillWidth: true
                               } //填充

                              ColumnLayout
                              {
                                  spacing: 5
                                  Text {
                                      text: "图片"
                                      color: "white"
                                      }
                                  Text {
                                      text:"点赞数"
                                      color: "white"
                                  }
                              }

                              Item {
                                   Layout.fillWidth: true
                               } //填充

                              ColumnLayout
                              {
                                  spacing: 5
                                  Text {
                                      text: "图片"
                                      color: "white"
                                      }
                                  Text {
                                      text:"点赞数"
                                      color: "white"
                                  }
                              }

                              Item {
                                   Layout.fillWidth: true
                               } //填充


                              ColumnLayout
                              {
                                  Layout.rightMargin: 25
                                  spacing: 5
                                  Text {
                                      text: "图片"
                                      color: "white"
                                      }
                                  Text {
                                      text:"点赞数"
                                      color: "white"
                                  }
                              }

                            }

                            Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 1
                                    Layout.topMargin: 15
                                    Layout.bottomMargin: 10
                                    color: "#333333"
                                }

                            ScrollView
                            {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.topMargin: 20

                                contentWidth: parent.width // 内容宽度与父组件相同
                                contentHeight: videoColumn.height // 内容高度由视频列表决定

                                // 视频列表容器
                                Column {
                                    id: videoColumn
                                    width: parent.width
                                    spacing: 15 // 视频项之间的间距

                                    Repeater {
                                        model: 15

                                        // 单个视频项
                                        Rectangle {
                                            id:father
                                            width: videoColumn.width
                                            height: titleBar.height * 1.5
                                            color: "transparent"

                                            HoverHandler {
                                                id: hoverHandler
                                                acceptedDevices: PointerDevice.Mouse
                                                cursorShape: Qt.PointingHandCursor
                                                onHoveredChanged: {
                                                    if (hovered) {
                                                        titleText.color = "pink"
                                                    } else {
                                                        titleText.color = "white"
                                                    }
                                                }
                                            }

                                            RowLayout {
                                                anchors.fill: parent
                                                spacing: 10

                                                Rectangle {
                                                    Layout.preferredWidth: father.width * 0.4
                                                    Layout.preferredHeight: father.height
                                                    radius: 5
                                                    color: "#2A2A2A"

                                                    // 模拟视频时长
                                                    Text {
                                                        anchors {
                                                            right: parent.right
                                                            bottom: parent.bottom
                                                            margins: 5
                                                        }
                                                        text: "10:30"
                                                        color: "white"
                                                        font.pixelSize: 12
                                                    }
                                                }

                                                // 视频信息
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    spacing: 5

                                                    // 视频标题
                                                    Text {
                                                        id:titleText
                                                        Layout.bottomMargin: 10
                                                        Layout.fillWidth: true
                                                        text: "视频标题"
                                                        color: "white"
                                                        font.pixelSize: 16
                                                        wrapMode: Text.Wrap    //单词边界换行
                                                        maximumLineCount: 2
                                                        elide: Text.ElideRight  //超出部分右边使用...
                                                    }

                                                    Item {
                                                         Layout.fillHeight: true
                                                     } //填充

                                                    Text {
                                                        text: "UP主名字"
                                                        color: "#AAAAAA"
                                                        font.pixelSize: 12
                                                    }

                                                    RowLayout
                                                    {
                                                        spacing: 10
                                                        Text {
                                                            text: "播放数"
                                                            color: "#AAAAAA"
                                                            font.pixelSize: 12
                                                        }

                                                        Text {
                                                            text: "评论数"
                                                            color: "#AAAAAA"
                                                            font.pixelSize: 12
                                                        }
                                                    }

                                                }
                                            }

                                        }
                                    }
                                }
                            }

                        Item {
                             Layout.fillHeight: true
                         } //填充


                        } //Column  简介的父

                    }  //Item

        //简介部分============================//==================================


                        Commit{
                            visible: videoPlayerPage.currentView === "commit"
                        }  //评论部分


                    }  //Column  父

                }

            }

        }

    }

}
