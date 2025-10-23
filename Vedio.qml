import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

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
    property bool forceControlBarVisible: false //状态栏打开或者关闭



    property var danmuList: [
            {time: 5.2, text: "前方高能预警！", color: "#FF6699", duration: 25},
            {time: 5.2, text: "这个UP主太强了", color: "#FFFFFF", duration: 25},
            {time: 5.2, text: "哈哈哈笑死我了", color: "#FFCC00", duration: 25},
            {time: 5.2, text: "这个特效太棒了", color: "#00FFCC", duration: 25},
            {time: 5.1, text: "求BGM名字", color: "#FF99CC", duration: 25},
            {time: 5.0, text: "三连支持", color: "#6699FF", duration: 25},
            {time: 5.0, text: "打卡第100天", color: "#99FF66", duration: 25},
            {time: 5.0, text: "泪目了", color: "#CC66FF", duration: 25},
            {time: 5.1, text: "进度条撑住", color: "#FF9966", duration: 25},
            {time: 5.1, text: "完结撒花", color: "#66CCFF", duration: 25}
        ]


    property bool isAlwaysOnTop: false   //置顶窗口
    flags: {
            var baseFlags = Qt.Window | Qt.FramelessWindowHint;
            if (isAlwaysOnTop) {
                return baseFlags | Qt.WindowStaysOnTopHint;
            } else {
                return baseFlags;
            }
        }//用于固定窗口

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

                    HoverHandler {
                             cursorShape: Qt.PointingHandCursor
                         }

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

                    HoverHandler {
                             cursorShape: Qt.PointingHandCursor
                         }

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

                    HoverHandler {
                             cursorShape: Qt.PointingHandCursor
                         }

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

                    HoverHandler {
                             cursorShape: Qt.PointingHandCursor
                         }

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

                    HoverHandler {
                             cursorShape: Qt.PointingHandCursor
                         }

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

                    HoverHandler {
                             cursorShape: Qt.PointingHandCursor
                         }

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

                    HoverHandler {
                             cursorShape: Qt.PointingHandCursor
                         }

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

        //=======内容部分=========
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

                //==================================视频区域====================================//

                Rectangle
                {
                    Connections {
                        target: videoManager
                        function onRequestPlayVideo(videoUrl) {
                                vedio.videoUrl = videoUrl
                        }
                    }
                    property url videoUrl: ""//TODO
                    id:vedio
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 5/7
                    color: "transparent"

                    MediaPlayer
                    {
                        id:mediaPlayer
                        source:vedio.videoUrl//TODO
                        autoPlay: true
                        videoOutput: videoOutput
                        audioOutput: AudioOutput{}

                    }
                    VideoOutput
                    {
                        id:videoOutput
                        anchors.fill: parent

                        HoverHandler
                        {
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler
                        {
                            acceptedButtons: Qt.LeftButton
                            onTapped:
                            {
                                if(mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                                    mediaPlayer.pause()
                                } else {
                                    mediaPlayer.play()
                                }
                                buttonAnimation.start()
                            }
                        }
                    }

                    // 弹幕系统
                    Item {
                                    id: danmuSystem
                                    anchors.fill: parent
                                    z: 100 // 确保在视频上方

                                    // 弹幕设置
                                    property int fontSize: 20
                                    property int maxCount: 50
                                    property int rowCount: 20
                                    property int speed: 100 // 像素/秒

                                    // 当前弹幕列表
                                    property var activeDanmus: []

                                    // 初始化
                                    Component.onCompleted: {
                                        mediaPlayer.positionChanged.connect(updateDanmu);
                                    }

                                    // 更新弹幕
                                    function updateDanmu() {
                                        var currentTime = mediaPlayer.position / 1000; // 转换为秒

                                        // 添加新弹幕
                                        for (var i = 0; i < videoPlayerPage.danmuList.length; i++) {
                                            var danmu = videoPlayerPage.danmuList[i];
                                            if (danmu.time <= currentTime && !danmu.displayed) {
                                                addDanmu(danmu);
                                                danmu.displayed = true;
                                            }
                                        }

                                        // 移除过期弹幕
                                        for (var j = activeDanmus.length - 1; j >= 0; j--) {
                                            var activeDanmu = activeDanmus[j];
                                            if (activeDanmu.startTime + activeDanmu.duration < currentTime) {
                                                activeDanmu.destroy();
                                                activeDanmus.splice(j, 1);
                                            }
                                        }
                                    }

                                    // 添加弹幕
                                    function addDanmu(danmuData) {
                                        if (activeDanmus.length >= maxCount) return;

                                        var danmu = danmuComponent.createObject(danmuSystem, {
                                            "text": danmuData.text,
                                            "color": danmuData.color,
                                            "fontSize": fontSize,
                                            "speed": speed,
                                            "duration": danmuData.duration,
                                            "startTime": mediaPlayer.position / 1000
                                        });

                                        activeDanmus.push(danmu);
                                    }

                                    // 弹幕组件
                                    Component {
                                        id: danmuComponent

                                        Text {
                                            id: danmuItem
                                            color: parent.color
                                            font.pixelSize: parent.fontSize
                                            font.bold: true
                                            text: parent.text
                                            style: Text.Outline
                                            styleColor: "black"

                                            property int speed: parent.speed
                                            property int duration: parent.duration
                                            property double startTime: parent.startTime
                                            property int row: Math.floor(Math.random() * danmuSystem.rowCount)
                                            property int trackHeight: parent.height / danmuSystem.rowCount

                                            x: parent.width
                                            y: row * trackHeight + (trackHeight - height) / 2

                                            // 弹幕移动动画
                                            NumberAnimation on x {
                                                from: parent.width
                                                to: -danmuItem.width
                                                duration: (parent.width + danmuItem.width) * 1000 / speed
                                                running: true
                                            }
                                        }
                                    }

                                    // 清空所有弹幕
                                    function clearAll() {
                                        for (var i = 0; i < activeDanmus.length; i++) {
                                            activeDanmus[i].destroy();
                                        }
                                        activeDanmus = [];

                                        // 重置显示状态
                                        for (var j = 0; j < videoPlayerPage.danmuList.length; j++) {
                                            videoPlayerPage.danmuList[j].displayed = false;
                                        }
                                    }
                                }

                    TapHandler
                        {
                            acceptedButtons: Qt.LeftButton
                            gesturePolicy: TapHandler.WithinBounds

                            onDoubleTapped: {
                                if (videoPlayerPage.visibility === Window.FullScreen) {
                                    videoPlayerPage.visibility = Window.Windowed
                                } else {
                                    videoPlayerPage.visibility = Window.FullScreen
                                }
                            }
                        }

                    HoverHandler {
                           id: videoHoverHandler
                           acceptedDevices: PointerDevice.Mouse
                           onHoveredChanged: {
                               if (forceControlBarVisible) {
                                           controlBar.opacity = 1.0
                                           return
                                       }

                               if (hovered) {
                                       controlBar.opacity = 1.0
                               } else {
                                       controlBar.opacity = 0.0
                               }
                           }
                       }

                    Rectangle
                    {
                        id:video_progress
                        anchors
                        {
                            left:parent.left
                            right:parent.right
                            bottom:parent.bottom
                        }
                        visible: controlBar.opacity === 0.0 ? true : false
                        color: "grey"
                        height: 7
                        Rectangle
                            {
                                width: mediaPlayer.duration > 0 ?
                                       (mediaPlayer.position / mediaPlayer.duration) * parent.width : 0
                                height: parent.height
                                color: "#FF6699" // 粉色进度条
                            }    //播放进度条

                    }

                    Rectangle
                    {
                        id:controlBar
                        anchors
                        {
                            left:parent.left
                            right:parent.right
                            bottom:parent.bottom
                        }
                        height:70
                        color: "transparent"
                        z:5

                        Behavior on opacity {
                                    NumberAnimation {
                                        duration: 300
                                        easing.type: Easing.InOutQuad
                                    }
                                }

                        MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.AllButtons
                                propagateComposedEvents: false

                                // 正确声明参数
                                onClicked: function(mouse) {
                                    mouse.accepted = true
                                }
                                onDoubleClicked: function(mouse) {
                                    mouse.accepted = true
                                }
                                onPressed: function(mouse) {
                                    mouse.accepted = true
                                }
                                onReleased: function(mouse) {
                                    mouse.accepted = true
                                }
                            } //TapHandler使用会变复杂

                        ColumnLayout
                        {
                           anchors.fill: parent

                           Rectangle
                           {
                               id:none_name
                               Layout.preferredWidth: parent.width
                               height: hoverHandler.hovered ? 5 + 4 : 5
                               color: "grey"

                               signal playRequested()

                               Rectangle
                                   {
                                       id: progressBar
                                       width: mediaPlayer.duration > 0 ?
                                              (mediaPlayer.position / mediaPlayer.duration) * parent.width : 0
                                       height: parent.height
                                       color: "#FF6699" // 粉色进度条


                                       Behavior on width {
                                           NumberAnimation { duration: 100 }
                                       }
                                   }    //播放进度条

                               Behavior on height {
                                        NumberAnimation { duration: 150 }
                                            }

                               HoverHandler {
                                       id: hoverHandler
                                       cursorShape: Qt.PointingHandCursor
                                   }

                               TapHandler {
                                      id: tapHandler
                                      acceptedButtons: Qt.LeftButton
                                      gesturePolicy: TapHandler.ReleaseWithinBounds
                                      onTapped: {
                                          // 计算点击位置对应的播放时间
                                          var newPosition = (point.position.x / parent.width) * mediaPlayer.duration
                                          mediaPlayer.position = newPosition
                                      }
                                  }

                               DragHandler {
                                       id: dragHandler
                                       acceptedButtons: Qt.LeftButton
                                       target: null

                                       onActiveChanged: {
                                           if (active) {
                                               // 拖动开始
                                               var newPosition = (centroid.position.x / parent.width) * mediaPlayer.duration
                                               mediaPlayer.position = newPosition
                                           }
                                       }

                                       onCentroidChanged: {
                                           if (active) {
                                               // 拖动中
                                               var newPosition = (centroid.position.x / parent.width) * mediaPlayer.duration
                                               mediaPlayer.position = newPosition
                                           }
                                       }
                                   }  //拖动控制

                                   Rectangle
                                   {
                                       id: dragHandle
                                       visible: dragHandler.active || tapHandler.pressed
                                       x: progressBar.width - width/2
                                       y: (parent.height - height)/2
                                       width: 16
                                       height: 16
                                       radius: width/2
                                       color: "#FF6699" // 粉色滑块
                                       border.color: "#FFFFFF"
                                       border.width: 2

                                   }

                           }//进度条

                           RowLayout
                           {
                               Layout.fillWidth: true
                               Layout.preferredHeight: 40
                               Layout.margins: 10
                               Button {
                                               id: playPauseButton
                                               Layout.preferredWidth: 40
                                               Layout.preferredHeight: 40
                                               Layout.alignment: Qt.AlignVCenter
                                               Layout.bottomMargin: 7

                                               // 根据播放状态显示不同图标
                                               text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "⏸" : "▶"
                                               font.pixelSize:25

                                               HoverHandler {
                                                   cursorShape: Qt.PointingHandCursor
                                               }

                                               background:Rectangle
                                               {
                                                   color:"transparent"
                                               }

                                               contentItem: Text {
                                                   text: playPauseButton.text
                                                   font: playPauseButton.font
                                                   color: "white"
                                                   horizontalAlignment: Text.AlignHCenter
                                                   verticalAlignment: Text.AlignVCenter
                                               }

                                               onClicked: {
                                                   if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                                                       mediaPlayer.pause()
                                                   } else {
                                                       mediaPlayer.play()
                                                   }
                                                   buttonAnimation.start()
                                               }

                                               SequentialAnimation {
                                                       id: buttonAnimation

                                                       // 放大动画
                                                       PropertyAnimation {
                                                           target: playPauseButton
                                                           property: "scale"
                                                           to: 1.2
                                                           duration: 300
                                                           easing.type: Easing.OutCubic
                                                       }

                                                       // 恢复动画
                                                       PropertyAnimation {
                                                           target: playPauseButton
                                                           property: "scale"
                                                           to: 1.0
                                                           duration: 300
                                                           easing.type: Easing.OutBack
                                                       }
                                                   }
                               } //暂停按钮

                               Text {
                                   text:formatTime(mediaPlayer.position) + "/" + formatTime(mediaPlayer.duration)
                                   color: "white"
                                   font.pixelSize: 15
                                   Layout.alignment: Qt.AlignVCenter
                                   Layout.leftMargin: 10

                                   function formatTime(milliseconds) {
                                               if (milliseconds <= 0) return "00:00";
                                               var seconds = Math.floor(milliseconds / 1000);
                                               var minutes = Math.floor(seconds / 60);
                                               seconds = seconds % 60;
                                               return minutes.toString().padStart(2, '0') + ":" + seconds.toString().padStart(2, '0');
                                           }
                               }

                               Button {
                                               id: dm
                                               Layout.preferredWidth: 40
                                               Layout.preferredHeight: 40
                                               Layout.alignment: Qt.AlignVCenter
                                               Layout.bottomMargin: 6
                                               Layout.leftMargin: widthNum.width * 0.2

                                               // 根据播放状态显示不同图标
                                               text: "弹幕"
                                               font.pixelSize:15

                                               HoverHandler {
                                                   cursorShape: Qt.PointingHandCursor
                                               }

                                               background:Rectangle
                                               {
                                                   color:"transparent"
                                               }

                                               contentItem: Text {
                                                   text: dm.text
                                                   font: dm.font
                                                   color: "white"
                                                   horizontalAlignment: Text.AlignHCenter
                                                   verticalAlignment: Text.AlignVCenter
                                               }

                                               onClicked: {

                                               }

                               } //弹幕打开关闭按钮

                               Button {
                                               id: dm_set
                                               Layout.preferredWidth: 40
                                               Layout.preferredHeight: 40
                                               Layout.alignment: Qt.AlignVCenter
                                               Layout.bottomMargin: 6
                                               Layout.leftMargin: 10

                                               // 根据播放状态显示不同图标
                                               text: "弹幕set"
                                               font.pixelSize:15

                                               HoverHandler {
                                                   cursorShape: Qt.PointingHandCursor
                                               }

                                               background:Rectangle
                                               {
                                                   color:"transparent"
                                               }

                                               contentItem: Text {
                                                   text: dm_set.text
                                                   font: dm_set.font
                                                   color: "white"
                                                   horizontalAlignment: Text.AlignHCenter
                                                   verticalAlignment: Text.AlignVCenter
                                               }

                                               onClicked: {

                                               }

                               } //设置弹幕

                               TextField
                               {
                                   Layout.preferredWidth: widthNum.width * 0.4
                                   Layout.preferredHeight: 30
                                   Layout.leftMargin: 15
                                   Layout.bottomMargin: 6
                                   placeholderText: "点击发送弹幕"
                                   placeholderTextColor: "grey"
                                   color: "white"

                                   HoverHandler {
                                            cursorShape: Qt.IBeamCursor
                                        }

                                   background: Rectangle {
                                           id: commentInputBg
                                           color: "#2D2D2D"
                                           radius: 5
                                           border.width: 1
                                           border.color: "transparent" // 初始透明边框

                                           // 添加边框颜色动画
                                           Behavior on border.color {
                                               ColorAnimation { duration: 200 }
                                           }
                                       }

                                       // 聚焦变化处理
                                       onFocusChanged: {
                                           if (focus) {
                                               commentInputBg.border.color = "#FF6699"; // 粉色边框
                                           } else {
                                               commentInputBg.border.color = "transparent";
                                           }
                                       }

                                       Keys.onPressed: (event) => {
                                               if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                                   // 清除文字
                                                   text = "";
                                                   // 取消焦点
                                                   focus = false;
                                               }
                                           }
                               }  //发送弹幕

                               Item {
                                   Layout.fillWidth: true
                               }

                               Button {
                                               id: resolution
                                               Layout.preferredWidth: 40
                                               Layout.preferredHeight: 40
                                               Layout.alignment: Qt.AlignVCenter
                                               Layout.bottomMargin: 6
                                               Layout.leftMargin: widthNum.width * 0.15

                                               // 根据播放状态显示不同图标
                                               text: "分辨率设置"
                                               font.pixelSize:15

                                               HoverHandler {
                                                   cursorShape: Qt.PointingHandCursor
                                               }

                                               background:Rectangle
                                               {
                                                   color:"transparent"
                                               }

                                               contentItem: Text {
                                                   text: resolution.text
                                                   font: resolution.font
                                                   color: "white"
                                                   horizontalAlignment: Text.AlignHCenter
                                                   verticalAlignment: Text.AlignVCenter
                                               }

                                               onClicked: {
                                                   if(resolutionPopup.opened)
                                                        resolutionPopup.close()
                                                   else
                                                       resolutionPopup.open()
                                               }

                               } //视频分辨率设置

                               Popup {
                                   id: resolutionPopup
                                   x: resolution.x + resolution.width / 2 - width / 2
                                   y: resolution.y - height - 10
                                   width: 150
                                   height: contentItem.implicitHeight + 20
                                   padding: 1
                                   closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent

                                   opacity: 0.9

                                   onOpened:
                                   {
                                       forceControlBarVisible = true
                                   }

                                   onClosed:
                                   {
                                       forceControlBarVisible = false
                                       if (!videoHoverHandler.hovered) {
                                                   controlBar.opacity = 0.0
                                               }
                                   }

                                   // 弹出动画
                                   enter: Transition {
                                       NumberAnimation { property: "opacity"; from: 0.0; to: 0.9; duration: 150 }
                                       NumberAnimation { property: "scale"; from: 0.5; to: 1.0; duration: 100 }
                                   }

                                   exit: Transition {
                                       NumberAnimation { property: "opacity"; from: 0.9; to: 0.0; duration: 100 }
                                       NumberAnimation { property: "scale"; from: 1.0; to: 0.5; duration: 150 }
                                   }

                                   background: Rectangle {
                                       color: "black"
                                       radius: 5
                                       border.color: "#505050"
                                       border.width: 1
                                   }

                                   contentItem: ColumnLayout {
                                       spacing: 5
                                       anchors.fill: parent
                                       anchors.margins: 5

                                       // 720p选项
                                       Button {
                                           Layout.fillWidth: true
                                           Layout.preferredHeight: 50
                                           text: "720p"
                                           font.pixelSize: 14

                                           background: Rectangle {
                                               color: parent.hovered ? "#3D3D40" : "transparent"
                                               radius: 3
                                           }

                                           contentItem: Text {
                                               text: parent.text
                                               font: parent.font
                                               color: "white"
                                               horizontalAlignment: Text.AlignHCenter
                                               verticalAlignment: Text.AlignVCenter
                                           }

                                           HoverHandler
                                           {
                                               cursorShape: Qt.PointingHandCursor
                                           }

                                           onClicked: {
                                               resolutionPopup.close()
                                               controlBar.opacity = 0.0
                                           }
                                       }

                                       // 1080p选项
                                       Button {
                                           Layout.fillWidth: true
                                           Layout.preferredHeight: 50
                                           text: "1080p"
                                           font.pixelSize: 14

                                           background: Rectangle {
                                               color: parent.hovered ? "#3D3D40" : "transparent"
                                               radius: 3
                                           }

                                           HoverHandler
                                           {
                                               cursorShape: Qt.PointingHandCursor
                                           }

                                           contentItem: Text {
                                               text: parent.text
                                               font: parent.font
                                               color: "white"
                                               horizontalAlignment: Text.AlignHCenter
                                               verticalAlignment: Text.AlignVCenter
                                           }

                                           onClicked: {
                                               resolutionPopup.close()


                                           }
                                       }
                                   }
                               }

                               Button {
                                               id: multipe
                                               Layout.preferredWidth: 40
                                               Layout.preferredHeight: 40
                                               Layout.alignment: Qt.AlignVCenter
                                               Layout.bottomMargin: 6
                                               Layout.leftMargin: 40

                                               // 根据播放状态显示不同图标
                                               text: "倍数"
                                               font.pixelSize:15

                                               HoverHandler {
                                                   cursorShape: Qt.PointingHandCursor
                                               }

                                               background:Rectangle
                                               {
                                                   color:"transparent"
                                               }

                                               contentItem: Text {
                                                   text: multipe.text
                                                   font: multipe.font
                                                   color: "white"
                                                   horizontalAlignment: Text.AlignHCenter
                                                   verticalAlignment: Text.AlignVCenter
                                               }

                                               onClicked: {
                                                   if(multipe_set.opened)
                                                        multipe_set.close()
                                                   else
                                                       multipe_set.open()

                                               }

                               } //倍数设置

                               Popup
                               {
                                   id:multipe_set
                                   x: multipe.x + multipe.width/2 - width/2
                                   y: multipe.y - height - 10
                                   width: 90
                                   height: contentItem.implicitHeight + 20
                                   padding: 5
                                   closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent

                                   onOpened:
                                   {
                                       forceControlBarVisible = true
                                   }

                                   onClosed:
                                   {
                                       forceControlBarVisible = false
                                       if (!videoHoverHandler.hovered) {
                                                   controlBar.opacity = 0.0
                                               }
                                   }

                                   // 弹出动画
                                   enter: Transition {
                                       NumberAnimation { property: "opacity"; from: 0.0; to: 0.9; duration: 150 }
                                       NumberAnimation { property: "scale"; from: 0.5; to: 1.0; duration: 100 }
                                   }

                                   exit: Transition {
                                       NumberAnimation { property: "opacity"; from: 0.9; to: 0.0; duration: 100 }
                                       NumberAnimation { property: "scale"; from: 1.0; to: 0.5; duration: 150 }
                                   }

                                   background: Rectangle {
                                       color: "black"
                                       radius: 5
                                   }

                                   contentItem: ColumnLayout {
                                           spacing: 5

                                           // 倍速选项
                                           Repeater {
                                               model: [2.0,1.5,1.25,1.0,0.75,0.5]

                                               Button {
                                                   Layout.fillWidth: true
                                                   Layout.preferredHeight: 40
                                                   text: {
                                                           // 将数字转换为字符串
                                                           let str = modelData.toString();

                                                           // 如果字符串不包含小数点，添加".0"
                                                           if (!str.includes('.')) {
                                                               str += ".0";
                                                           }
                                                           // 如果包含小数点
                                                           else {
                                                               // 移除末尾多余的零
                                                               str = str.replace(/0+$/, '');
                                                               // 如果小数点后没有数字了，添加"0"
                                                               if (str.endsWith('.')) {
                                                                   str += "0";
                                                               }
                                                           }

                                                           return str + "x";
                                                       }
                                                   font.bold: true
                                                   font.pixelSize: 14

                                                   HoverHandler
                                                   {
                                                       cursorShape: Qt.PointingHandCursor
                                                   }

                                                   background: Rectangle {
                                                       color: parent.hovered ? "#3D3D40" : "transparent"
                                                       radius: 3
                                                   }

                                                   contentItem: Text {
                                                       text: parent.text
                                                       font: parent.font
                                                       color: Math.abs(mediaPlayer.playbackRate - modelData) < 0.01 ? "#FF6699" : "white"
                                                       horizontalAlignment: Text.AlignHCenter
                                                       verticalAlignment: Text.AlignVCenter
                                                   }

                                                   onClicked: {
                                                       mediaPlayer.playbackRate = modelData
                                                       multipe_set.close()
                                                   }
                                               }

                                           }
                                   }

                               }

                               Button {
                                               id: set
                                               Layout.preferredWidth: 40
                                               Layout.preferredHeight: 40
                                               Layout.alignment: Qt.AlignVCenter
                                               Layout.bottomMargin: 6
                                               Layout.leftMargin: 15

                                               // 根据播放状态显示不同图标
                                               text: "设置"
                                               font.pixelSize:15

                                               HoverHandler {
                                                   cursorShape: Qt.PointingHandCursor
                                               }

                                               background:Rectangle
                                               {
                                                   color:"transparent"
                                               }

                                               contentItem: Text {
                                                   text: set.text
                                                   font: set.font
                                                   color: "white"
                                                   horizontalAlignment: Text.AlignHCenter
                                                   verticalAlignment: Text.AlignVCenter
                                               }

                                               onClicked: {

                                               }

                               } //设置

                               Button {
                                               id: volumn
                                               Layout.preferredWidth: 40
                                               Layout.preferredHeight: 40
                                               Layout.alignment: Qt.AlignVCenter
                                               Layout.bottomMargin: 6
                                               Layout.leftMargin: 15

                                               // 根据播放状态显示不同图标
                                               text: "音量"
                                               font.pixelSize:15

                                               HoverHandler {
                                                   cursorShape: Qt.PointingHandCursor
                                               }

                                               background:Rectangle
                                               {
                                                   color:"transparent"
                                               }

                                               contentItem: Text {
                                                   text: volumn.text
                                                   font: volumn.font
                                                   color: "white"
                                                   horizontalAlignment: Text.AlignHCenter
                                                   verticalAlignment: Text.AlignVCenter
                                               }

                                               onClicked: {
                                                   if(volume_set.opened)
                                                        volume_set.close()
                                                   else
                                                       volume_set.open()
                                               }

                               } //音量设置

                               Popup
                               {
                                   id:volume_set
                                   x:volumn.x + volumn.width/2 - width/2
                                   y:volumn.y - height -10
                                   width: 50
                                   height: 135
                                   padding: 1
                                   closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent

                                   onOpened:
                                   {
                                       forceControlBarVisible = true
                                   }

                                   onClosed:
                                   {
                                       forceControlBarVisible = false
                                       if (!videoHoverHandler.hovered) {
                                                   controlBar.opacity = 0.0
                                               }
                                   }

                                   // 弹出动画
                                   enter: Transition {
                                       NumberAnimation { property: "opacity"; from: 0.0; to: 0.9; duration: 150 }
                                       NumberAnimation { property: "scale"; from: 0.5; to: 1.0; duration: 100 }
                                   }

                                   exit: Transition {
                                       NumberAnimation { property: "opacity"; from: 0.9; to: 0.0; duration: 100 }
                                       NumberAnimation { property: "scale"; from: 1.0; to: 0.5; duration: 150 }
                                   }

                                   background: Rectangle {
                                       color: "black"
                                       radius: 5
                                   }

                                   contentItem: ColumnLayout {
                                       anchors.fill: parent
                                       anchors.margins: 10
                                       spacing: 10

                                       // 添加一个容器包裹文本和滑块
                                       ColumnLayout {
                                           Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                           spacing: 10

                                           // 音量值显示 - 居中
                                           Text {
                                               id: volumeValue
                                               text: Math.round(volumn_slider.value * 100)
                                               color: "white"
                                               font.bold: true
                                               font.pixelSize: 13
                                               Layout.alignment: Qt.AlignHCenter
                                           }

                                           // 垂直滑块
                                           Slider {
                                               id: volumn_slider
                                               Layout.fillHeight: true
                                               Layout.preferredWidth: 30 // 设置固定宽度使滑块更窄
                                               orientation: Qt.Vertical
                                               from: 0.0
                                               to: 1.0
                                               value: mediaPlayer.audioOutput.volume

                                               WheelHandler {
                                                       id: wheelHandler
                                                       acceptedDevices: PointerDevice.Mouse
                                                       orientation: Qt.Vertical
                                                       onWheel: function(event) {
                                                           // 计算步长 (每次滚轮滚动改变5%音量)
                                                           var step = 0.1;
                                                           // 根据滚轮方向调整音量
                                                           if (event.angleDelta.y > 0) {
                                                               // 向上滚动增加音量
                                                               volumn_slider.value = Math.min(1.0, volumn_slider.value + step);
                                                           } else {
                                                               // 向下滚动减小音量
                                                               volumn_slider.value = Math.max(0.0, volumn_slider.value - step);
                                                           }
                                                           event.accepted = true;
                                                       }
                                                   }

                                               HoverHandler {
                                                   cursorShape: Qt.PointingHandCursor
                                               }

                                               background: Rectangle {
                                                   x: parent.leftPadding + (parent.availableWidth - width) / 2
                                                   y: parent.topPadding
                                                   width: 6
                                                   height: parent.availableHeight
                                                   radius: 3
                                                   color: "white" // 未拖动部分为白色

                                                   // 已拖动部分（粉色）
                                                   Rectangle {
                                                       width: parent.width
                                                       height: volumn_slider.value * parent.height
                                                       color: "#FF6699" // 粉色
                                                       radius: 3
                                                       anchors.bottom: parent.bottom // 从底部开始填充
                                                   }
                                               }

                                               handle: Rectangle {
                                                   x: volumn_slider.leftPadding + volumn_slider.availableWidth / 2 - width / 2
                                                   y: parent.topPadding + volumn_slider.visualPosition * (parent.availableHeight - height)
                                                   width: 15
                                                   height: 15
                                                   radius: width / 2
                                                   color: "#FF6699"
                                                   z:3
                                               }
                                           }
                                       }
                                   }
                               }

                               Button {
                                               id: qp
                                               Layout.preferredWidth: 40
                                               Layout.preferredHeight: 40
                                               Layout.alignment: Qt.AlignVCenter
                                               Layout.bottomMargin: 6
                                               Layout.rightMargin: 10
                                               Layout.leftMargin: 15

                                               // 根据播放状态显示不同图标
                                               text: "全屏"
                                               font.pixelSize:15

                                               HoverHandler {
                                                   cursorShape: Qt.PointingHandCursor
                                               }

                                               background:Rectangle
                                               {
                                                   color:"transparent"
                                               }

                                               contentItem: Text {
                                                   text: qp.text
                                                   font: qp.font
                                                   color: "white"
                                                   horizontalAlignment: Text.AlignHCenter
                                                   verticalAlignment: Text.AlignVCenter
                                               }

                                               onClicked: {
                                                   if (videoPlayerPage.visibility === Window.FullScreen) {
                                                       videoPlayerPage.visibility = Window.Windowed
                                                   } else {
                                                       videoPlayerPage.visibility = Window.FullScreen
                                                   }
                                               }

                               } //全屏



                           } //下方状态栏

                        }   //ColumnLayout

                    }  //视频控制栏


                }//TODO

                //==================================视频区域====================================//


                //==================================评论简介区域=================================//
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

                                HoverHandler {
                                         cursorShape: Qt.PointingHandCursor
                                     }

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

                                HoverHandler {
                                         cursorShape: Qt.PointingHandCursor
                                     }

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

                                HoverHandler {
                                         cursorShape: Qt.PointingHandCursor
                                     }

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
                                        HoverHandler {
                                                 cursorShape: Qt.PointingHandCursor
                                             }
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
                                        HoverHandler {
                                                 cursorShape: Qt.PointingHandCursor
                                             }
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
                                        HoverHandler {
                                                 cursorShape: Qt.PointingHandCursor
                                             }
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

                                HoverHandler {
                                         cursorShape: Qt.PointingHandCursor
                                     }

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
                                    buttonAnime.start()
                                    videoPlayerPage.attention = !videoPlayerPage.attention;
                                    //操作
                                }

                                SequentialAnimation
                                {
                                    id:buttonAnime
                                    PropertyAnimation
                                    {
                                        target: bButton
                                        property: "scale"
                                        to: 1.1
                                        duration: 300
                                        easing.type: Easing.OutCubic
                                    }

                                    PropertyAnimation
                                    {
                                        target: bButton
                                        property: "scale"
                                        to:1.0
                                        duration: 300
                                        easing.type: Easing.OutBack
                                    }
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
                                HoverHandler {
                                         cursorShape: Qt.PointingHandCursor
                                     }
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
                                                // id: hoverHandler
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

                //==================================评论简介区域=================================//
            }

        }

    }

}


