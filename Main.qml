import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import VideoApp
import UserApp
// import QtGraphicalEffects
import "./component"
import "qml/Video_Playback"
import "qml/Login"
import "qml/Send_Videos"
import "qml/Settings"
import "qml/User_HomePage"
import "qml/Tools_Left"

FrameLessWindow {
    id: root
    width: 1100
    height: 800

    property string globalAvatarUrl: "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"
    property bool isLoggedIn: false
    property string username: ""
    property string userAccount: ""
    property string currentLeftMenuItem: ""
    property string currentTopNavItem: "推荐"
    property bool showPersonInfo: false
    property string apiBaseUrl: "http://localhost:3000"       //服务器基网址
    property bool isSearching: false
    property bool showSearchResults: false
    property bool coverUrlStatue:false
    property alias videoLoad: videoLoaders
    property string currentVideoId: ""
    property bool showVideo: false



    // VideoController
    // {
    //     id:videoController
    // }

    Connections {
        target: userController

        function onFavoriteAdded(videoId) {
            console.log("收藏添加:", videoId)
            // 刷新视频列表或更新特定视频的显示状态
        }

        function onFavoriteRemoved(videoId) {
            console.log("收藏移除:", videoId)
            // 刷新视频列表或更新特定视频的显示状态
        }

        function onFavoritesChanged() {
            console.log("收藏列表变化")
            // 如果需要，可以在这里刷新UI
        }


        function onVideoLiked(videoId) {
            console.log("点赞视频:", videoId)
            // 更新视频点赞状态
        }

        function onVideoUnliked(videoId) {
            console.log("取消点赞视频:", videoId)
            // 更新视频点赞状态
        }

    }

    // 视频数据模型
    ListModel {
        id: videoModel
    }

    // 网络管理器
    NetworkManager {               //左侧的红色符号不用管，这个是正常能加载的
        id: networkManager
        baseUrl: apiBaseUrl
    }

    // 加载视频列表
    function loadVideos() {
        loadingIndicator.visible = true;
        emptyText.visible = false;

        networkManager.get("/api/videos", function(success, response) {
            loadingIndicator.visible = false;

            if (success) {
                if (response.code === 0) {
                    videoModel.clear();

                    // 添加视频到模型
                    for (var i = 0; i < response.data.length; i++) {
                        var video = response.data[i];
                        videoModel.append(video);
                    }

                    // 如果没有视频，显示空状态
                    emptyText.visible = videoModel.count === 0;
                } else {
                    console.error("API返回错误:", response.message);
                    showError("加载失败: " + response.message);

                }
            } else {
                console.error("网络请求失败");
                // showError("网络连接失败，请检查服务器状态");
            }
        });
    }

    Component.onCompleted: {
        console.log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        videoController.loadVideoFromDatabase();
        videoController.loadVideos()
         console.log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    }
    function openVideoFromFavorite(videoId) {
        console.log("🎬 收藏页直接播放视频:", videoId)

        // 如果已有播放器，先销毁
        if (videoLoaders.item) {
            videoLoaders.sourceComponent = undefined
        }

        // 拿到完整视频数据（和首页一样）
        var videoData = videoController.getVideo(videoId)

        videoLoaders.setSource(
            "qml/Video_Playback/Video.qml",
            {
                videoId: videoId,
                videoData: videoData,
                videoManager: videoController
            }
        )
    }





    // 顶部刷新按钮
    Button {
        id: refreshButton
        anchors {
            bottom: parent.bottom;     bottomMargin: 10
            right:parent.right;        rightMargin: 10;
        }
        width: 100;      height: 36;     z:100
        text: "刷新";       font.pixelSize: 14

        background: Rectangle {
            color: refreshButton.down ? "#e6f7ff" :
            refreshButton.enabled ? "#00aeec" : "#cccccc"
            border.color: refreshButton.enabled ? "#00aeec" : "#cccccc"
            border.width: 1
            radius: 4
        }

        contentItem: Text {
            text: refreshButton.text
            color: refreshButton.enabled ? "white" : "#999999"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font: refreshButton.font
        }

        onClicked: {
            console.log("手动刷新视频列表");
            videoController.loadVideoFromDatabase();
            videoController.loadVideos()
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 36
        width:300
        z:100
        color: "pink"
        radius: 4
        border.color: "#E5E9EF"

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom;
            bottomMargin: 10
            // leftMargin: 10
        }

        Text {
            text: "加载更多..."
            anchors.centerIn: parent
            color: "#FB7299"
            font.pixelSize: 14
        }

        TapHandler {
            onTapped:
            {
                console.log("加载更多视频")
                videoController.loadMoreVideos(5)
                videoController.loadVideos()
            }
        }
    }

    // 加载指示器
    Rectangle {
        id: loadingIndicator
        anchors.centerIn: parent
        width: 100
        height: 100
        color: "#ccffffff"
        radius: 8
        visible: false
        z: 2

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: true
                width: 40
                height: 40
            }

            Text {
                text: "加载中..."
                font.pixelSize: 14
                color: "#666666"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // 空状态提示
    Text {
        id: emptyText
        anchors.centerIn: parent
        text: "暂无视频内容\n点击刷新按钮加载视频"
        font.pixelSize: 16
        color: "#999999"
        horizontalAlignment: Text.AlignHCenter
        visible: false
    }

    LoginPage {
            id: loginPage
            visible: false
            onLoginSuccess: function(username, avatarUrl, userAccount) {
                root.isLoggedIn = true
                root.username = username
                root.userAccount = userAccount
                root.globalAvatarUrl = avatarUrl
                loginPage.close()
            }
        }

    function openLoginDialog() {
        loginPage.open()
    }


    // 头像路径处理函数
    function processAvatarUrl(url) {
        if (!url || url === "") { return "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp" }

        console.log("原始头像URL:", url)

        if (url.startsWith("file:///")) {
            console.log("已经是file:///格式，直接使用")
            return url
        }

        if (url.startsWith("http://") || url.startsWith("https://")) {
            console.log("网络URL，直接使用")
            return url
        }

        var processedUrl = "file:///" + url
        console.log("本地路径处理后URL:", processedUrl)
        return processedUrl
    }

    // 当全局头像URL改变时，强制更新侧边栏头像


    // 左侧边栏
    Rectangle {
        id: leftSideBar
        width: 200
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        color: "#f0f0f0"
        z: 100



        ColumnLayout {
            spacing: 10
            anchors.fill: parent

            Button {
                id: backButton
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "← 返回"
                flat: true
                font.pixelSize: 14
                background: Rectangle {
                    color: backButton.hovered ? "#e0e0e0" : "transparent"
                }
                onClicked: {
                    console.log("点击返回按钮")
                    root.showPersonInfo = false
                    root.currentLeftMenuItem = ""
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                spacing: 5

                Text {
                    text: "常用功能"
                    font.pixelSize: 12
                    color: "#999"
                    Layout.leftMargin: 15
                    Layout.topMargin: 10
                }

                Repeater {
                    model: [
                        {text: "首页", icon: "🏠"},
                        {text: "精选", icon: "⭐"},
                        {text: "动态", icon: "📱"},
                        {text: "我的", icon: "👤"}
                    ]

                    delegate: Rectangle {
                        id: menuItem
                        width: leftSideBar.width
                        height: 50
                        Layout.preferredHeight: 50
                        color: getBackgroundColor()

                        function getBackgroundColor() {
                            if (root.currentLeftMenuItem === modelData.text) {
                                return "#e0e0e0"
                            }
                            else
                            {
                                return "transparent"
                            }
                        }

                        Row {
                            anchors.fill: parent
                            spacing: 10
                            leftPadding: 15

                            Text {
                                text: modelData.icon
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.text
                                color: root.currentLeftMenuItem === modelData.text ? "#FB7299" : "#333"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Button {
                            anchors.fill: parent
                            background: Rectangle {
                                color: "transparent"
                            }

                            onClicked: {
                                console.log("点击菜单项:", modelData.text)
                                root.currentLeftMenuItem = modelData.text
                                if (modelData.text === "我的") {//TODO
                                    // myPagePopup.open()
                                    if (!root.isLoggedIn) {
                                        console.log("用户未登录，打开登录对话框")
                                        root.openLoginDialog()  // 调用登录函数
                                    } else {
                                        root.showPersonInfo = true
                                    }
                                }
                                if(modelData.text === "首页"){
                                    root.showPersonInfo = false
                                    root.currentLeftMenuItem = ""
                                }
                                if(modelData.text==="动态") dynamicUploadPopup.open()

                                if(modelData.text === "精选")
                                {
                                    videoController.createVideo("这是标题",
                                                                "这是作者",
                                                                "这是描述",
                                                                "http://vjs.zencdn.net/v/oceans.mp4",      //视频url
                                                                "https://picsum.photos/320/180",           //封面url
                                                                "https://picsum.photos/100/100"         //头像url
                                                                )

                                    videoController.loadVideos()
                                }
                            }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#d0d0d0"
                Layout.topMargin: 10
                Layout.bottomMargin: 10
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                spacing: 5

                Rectangle {
                    id: userInfoArea
                    width: leftSideBar.width
                    height: 80
                    Layout.preferredHeight: 80
                    color: "transparent"

                    Row {
                        anchors.fill: parent
                        spacing: 10
                        leftPadding: 15

                        Rectangle {
                            width: 50
                            height: 50
                            radius: 25
                            color: "transparent"
                            anchors.verticalCenter: parent.verticalCenter
                            clip: true

                            Image {
                                id: avatarImage
                                anchors.fill: parent

                                source: userController.avatarUrl
                                        ? userController.avatarUrl + "?t=" + userController.avatarTimestamp
                                        : "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"

                                fillMode: Image.PreserveAspectCrop
                                cache: false
                            }





                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                id: usernameText
                                text: root.isLoggedIn ? root.username : "点击登录"  // 修改这里
                                font.pixelSize: 14
                                font.bold: true
                                color: root.isLoggedIn ? "#333" : "#FB7299"  // 未登录时显示粉色
                            }

                            Text {
                                text: root.isLoggedIn ? "查看个人主页" : "立即登录享受更多功能"  // 修改这里 //TODO
                                font.pixelSize: 12
                                color: "#666"
                            }
                        }
                    }

                    TapHandler {
                        onTapped: {
                            if (!root.isLoggedIn) {
                                console.log("用户未登录，打开登录对话框")
                                root.openLoginDialog()  // 调用登录函数
                            } else {
                                console.log("点击用户信息")
                                root.currentLeftMenuItem = "用户信息"
                                root.showPersonInfo = true
                            }
                        }
                    }
                }

                Repeater {
                    model: [
                        {text: "朋友圈", icon: "📝"},
                        {text: "上传视频", icon: "📹"},
                        {text: "消息", icon: "✉️"},
                        {text: "夜间模式", icon: "🌙"},
                        {text: "设置", icon: "⚙️"}
                    ]

                    delegate: Rectangle {
                        id: bottomMenuItem
                        width: leftSideBar.width
                        height: 50
                        Layout.preferredHeight: 50
                        color: getBackgroundColor()

                        function getBackgroundColor() {
                            if (root.currentLeftMenuItem === modelData.text) {
                                return "#e0e0e0"
                            }
                            return "transparent"
                        }

                        Row {
                            anchors.fill: parent
                            spacing: 10
                            leftPadding: 15

                            Text {
                                text: modelData.icon
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.text
                                color: root.currentLeftMenuItem === modelData.text ? "#FB7299" : "#333"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Button{
                            anchors.fill:parent
                            background: Rectangle{ color:"transparent" }
                            onClicked: {
                                if(modelData.text==="上传视频") videoUploadPopup.open()
                                if(modelData.text==="消息") messagePopup.open()

                                if(modelData.text==="设置"){
                                    root.showPersonInfo = false
                                    root.currentLeftMenuItem = "设置"
                                    settingsLoader.active = true
                                }

                                // root.currentLeftMenuItem = modelData.text
                                root.showPersonInfo = false
                            }
                        }


                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

    // 我的页面弹窗
    Popup {
        id: myPagePopup
        width: 1000
        height: 700
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#ffffff"  // 先使用固定颜色，确保能显示
            radius: 8
            border.color: "#e0e0e0"
            border.width: 1
        }

        // 标题栏
        Rectangle {
            id: popupHeader
            width: parent.width
            height: 50
            color: "transparent"

            Text {
                text: "个人中心"
                font.pixelSize: 18
                font.bold: true
                color: "#333333"
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
            }

            // 关闭按钮
            Button {
                id:closeBtn
                width: 30
                height: 30
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                background: Rectangle {
                    color: closeBtn.hovered ? "#f0f0f0" : "transparent"
                    radius: 4
                }
                contentItem: Text {
                    text: "×"
                    font.pixelSize: 20
                    color: "#333333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    console.log("关闭我的页面弹窗")
                    myPagePopup.close()
                }
            }

            // 分隔线
            Rectangle {
                width: parent.width
                height: 1
                color: "#e0e0e0"
                anchors.bottom: parent.bottom
            }
        }

        // 内容区域
        Loader {
            id: myContentLoader
            anchors {
                top: popupHeader.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            source: "Tools_Left/My.qml"

            onLoaded: {
                console.log("我的页面内容加载完成")
                // 设置主窗口引用
                if (myContentLoader.item && myContentLoader.item.setMainWindow) {
                    myContentLoader.item.setMainWindow(root)
                }
            }
        }
    }

    // 视频上传弹窗
    FrameLessWindow {
       id: videoUploadPopup
       width: 900
       height: 800
       visible: false
       flags: Qt.Dialog
       title: "视频上传页面"

       // 加载视频上传页面
       Loader {
           id: videoLoader
           anchors.fill: parent
           source: "qml/Send_Videos/VideoLode.qml"

           onLoaded: {
               // 连接关闭信号
               if (item && item.closeRequested) {
                   item.closeRequested.connect(function() {
                       videoUploadPopup.close()
                   })
               }
           }
       }

       // 打开时居中显示
       function open() {
           videoUploadPopup.show()
           videoUploadPopup.x = (Screen.width - width) / 2
           videoUploadPopup.y = (Screen.height - height) / 2
       }
    }

    // 消息弹窗
    FrameLessWindow {
        id: messagePopup
        width: 1200
        height: 800
        visible: false
        flags: Qt.Dialog
        title: "消息中心"

        // 加载消息页面
        Loader {
            id: messageLoader
            anchors.fill: parent
            source: "qml/Tools_Left/Message_Page.qml"

            onLoaded: {
                // 连接关闭信号
                if (item && item.closeRequested) {
                    item.closeRequested.connect(function() {
                        messagePopup.close()
                    })
                }
            }
        }

        // 打开时居中显示
        function open() {
            messagePopup.show()
            messagePopup.x = (Screen.width - width) / 2
            messagePopup.y = (Screen.height - height) / 2
        }
    }

    Loader {
        id: dynamicUploadPopup
        anchors.fill: parent
        source: "qml/Tools_Left/Dynamic.qml"
        active: false  // 初始为false

        onLoaded: {
            if (item && item.closeRequested) {
                item.closeRequested.connect(function() {
                    // ✅ 正确关闭方式：重置Loader状态
                    dynamicUploadPopup.active = false
                })
            }
        }

        // 添加open方法
        function open() {
            active = true  // 激活加载
        }
    }


    // 顶部区域
    Rectangle {
        id: topBar
        width: parent.width - leftSideBar.width
        height: 60
        color: "white"

        anchors {
            top: parent.top
            left: leftSideBar.right
        }

        RowLayout {
            anchors.fill: parent
            anchors.topMargin: 20
            anchors.rightMargin: 10
            spacing: 10

            Label{
                id: bili_icon
                // anchors.left: parent.left
                anchors.leftMargin: 10
                text: "bilibili"
                color: "pink"
                font.pixelSize: 14
                width: 30
                height: 30
            }

            Row {
                id: funcRegion
                spacing: 10
                Layout.fillWidth: true
                opacity: (!root.showPersonInfo && root.currentLeftMenuItem !== "设置") ? 1.0 : 0.0
                enabled: opacity > 0.5
                property real itemWidth: (width - (navRepeater.count - 1) * spacing) / navRepeater.count

                Repeater {
                    id: navRepeater
                    model: ["推荐", "热门", "追番", "影视", "漫画", "赛事", "直播"]

                    delegate: Rectangle {
                        id: navItem
                        width: funcRegion.itemWidth
                        height: 40
                        radius: 4
                        color: getBackgroundColor()

                        function getBackgroundColor() {
                            if (root.currentTopNavItem === modelData) {
                                return "#FB7299"
                            } else if (navTapHandler.pressed) {
                                return "#f5f5f5"
                            }
                            return "white"
                        }

                        Text {
                            text: modelData
                            anchors.centerIn: parent
                            color: root.currentTopNavItem === modelData ? "white" : "black"
                            font.pixelSize: 13
                        }

                        TapHandler {
                            id: navTapHandler
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.Touch
                            gesturePolicy: TapHandler.ReleaseWithinBounds

                            onTapped: {
                                console.log("点击顶部导航项:", modelData)
                                root.currentTopNavItem = modelData
                            }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                }
            }

            // 新增：搜索结果模型
            ListModel {
                id: searchResultModel
            }

            TextField {
                id: search
                Layout.preferredWidth: 250
                Layout.preferredHeight: 40
                visible: true

                placeholderText: "搜索你感兴趣的视频  🔍"
                placeholderTextColor: "gray"
                background: Rectangle {
                    color: "#F0F0F0"
                    border.color: search.focus ? "#00BFFF" : "transparent"
                    radius: 4
                }

                // 添加防抖定时器
                property var searchTimer: null

                onTextChanged: {
                    // 清除之前的定时器
                    if (searchTimer) {
                        searchTimer.stop();
                    }

                    if (text.length > 0) {
                        // 延迟500ms执行搜索
                        searchTimer = Qt.createQmlObject("import QtQml 2.15; Timer { interval: 500; onTriggered: searchVideos(search.text) }", search);
                        searchTimer.start();
                    } else {
                        // 如果搜索框为空，显示正常视频列表
                        showSearchResults = false;
                        searchResultModel.clear();
                    }
                }

                Button{
                    id: clearButton
                    background: Rectangle {
                        color: clearButton.hovered ? "lightgray" : "#F0F0F0"
                    }
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text: "×"
                    onClicked: {
                        search.text = ""
                        showSearchResults = false;
                        searchResultModel.clear();
                    }
                    opacity: search.focus ? 1 : 0
                }
            }

            Rectangle {
                id: line
                Layout.preferredWidth: 20
                Layout.preferredHeight: 40
                visible: true
                Text {
                    anchors.centerIn: parent
                    text: "|"
                    font.pixelSize: 20
                    color: "lightgray"
                }
            }

            RowLayout {
                id: controls
                spacing: 10
                visible: true

                Button {
                    id: minimizeButton
                    text: "—"
                    flat: true
                    width: 40
                    height: 40
                    background: Rectangle {
                        color: minimizeButton.hovered ? "#E5E9EF" : "transparent"
                        radius: 4
                    }
                    onClicked: root.showMinimized()
                }

                Button {
                    id: maximizeButton
                    text: root.visibility === Window.Maximized ? "❐" : "□"
                    flat: true
                    width: 40
                    height: 40
                    background: Rectangle {
                        color: maximizeButton.hovered ? "#E5E9EF" : "transparent"
                        radius: 4
                    }
                    onClicked: {
                        if (root.visibility === Window.Maximized)
                            root.showNormal()
                        else
                            root.showMaximized()
                    }
                }

                Button {
                    id: closeButton
                    text: "×"
                    flat: true
                    width: 40
                    height: 40
                    background: Rectangle {
                        color: closeButton.hovered ? "#FF4D4F" : "transparent"
                        radius: 4
                    }
                    onClicked: Qt.quit()
                }
            }
        }
    }
    //-----------------------------------------------------------------------------------------------------------------------
    //--------------------------------------------------------内容区域--------------------------------------------------------
    //-----------------------------------------------------------------------------------------------------------------------
    Item {
        id: contentContainer
        anchors {
            top: topBar.bottom
            left: leftSideBar.right
            right: parent.right
            bottom: parent.bottom
        }

        property var videoManager: videoController ? videoController : null

        // 正常视频列表
        ScrollView {
            id: contentScrollView
            anchors.fill: parent
            visible: !root.showSearchResults && !root.showPersonInfo && root.currentLeftMenuItem !== "设置"
            contentWidth: availableWidth
            clip: true
            padding: 20

            ColumnLayout {
                width: root.width - leftSideBar.width - 15
                spacing: 20

                GridView {
                    id: videoGrid
                    Layout.fillWidth: true
                    Layout.margins: 20

                    height: 1200
                    cellWidth: (width - 30) / 4
                    cellHeight: 220
                    model: contentContainer.videoManager ? contentContainer.videoManager.videos : []
                    delegate: videoDelegate // 使用下面的组件
                }
            }
        }

        // 搜索结果视图
        ScrollView {
            id: searchScrollView
            anchors.fill: parent
            visible: root.showSearchResults && !root.showPersonInfo && root.currentLeftMenuItem !== "设置"
            contentWidth: availableWidth
            clip: true
            padding: 20

            ColumnLayout {
                width: root.width - leftSideBar.width - 15
                spacing: 20

                // 搜索标题
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "搜索结果"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333"
                    }

                    Text {
                        text: "(" + searchResultModel.count + "个视频)"
                        font.pixelSize: 14
                        color: "#666"
                    }

                    Button {
                        text: "返回首页"
                        font.pixelSize: 12
                        background: Rectangle {
                            color: parent.hovered ? "#f0f0f0" : "transparent"
                            radius: 4
                        }
                        onClicked: {
                            showSearchResults = false;
                            search.text = "";
                            searchResultModel.clear();
                        }
                    }
                }

                // 搜索结果列表
                GridView {
                    id: searchResultGrid
                    Layout.fillWidth: true
                    cellWidth: (width - 30) / 4
                    cellHeight: 220
                    model: searchResultModel
                    delegate: videoDelegate2

                    // 关键
                    implicitHeight: contentHeight
                }

            }
        }

        // 搜索加载状态
        Rectangle {
            anchors.centerIn: searchScrollView
            width: 200
            height: 100
            color: "#ccffffff"
            radius: 8
            visible: root.isSearching
            z: 10

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    running: true
                    width: 30
                    height: 30
                }

                Text {
                    text: "搜索中..."
                    font.pixelSize: 14
                    color: "#666666"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        Loader {
            id: videoLoaders
            // 初始状态为空，不加载任何组件
            sourceComponent: undefined

            // 可选：设置异步加载避免界面卡顿
            asynchronous: true

            // 组件加载完成后的处理
            onLoaded: {
                if (item) {
                    console.log("视频播放器加载完成")
                    // 显示视频播放窗口
                    item.show()

                    // 连接关闭信号，当播放器关闭时清理Loader
                    item.closing.connect(function() {
                        console.log("视频播放器关闭，清理资源")
                        videoLoaders.sourceComponent = undefined
                    })
                }
            }

            onStatusChanged: {
                if (status === Loader.Error) {
                    console.error("加载视频播放器失败:", sourceComponent.errorString())
                }
            }
        }

        Loader {
            id: personInfoLoader
            anchors.fill: parent
            visible: root.showPersonInfo && root.currentLeftMenuItem !== "设置"
            source: root.showPersonInfo ? "qml/Tools_Left/PersonInfo.qml" : ""
            active: root.showPersonInfo

            onLoaded: {
                console.log("个人信息界面加载完成")
                // 直接设置头像URL，确保同步
                 personInfoLoader.item.mainWindow = root
                personInfoLoader.item.setMainAvatarUrl(root.globalAvatarUrl)
            }
        }

        Loader {
            id: settingsLoader
            anchors.fill: parent
            visible: root.currentLeftMenuItem === "设置"
            source: "qml/Settings/SettingsPage.qml"
            // active: false
            active: root.currentLeftMenuItem === "设置"
        }
    }
    // 修改后的搜索函数
    function searchVideos(keyword) {
        console.log("🔍 开始搜索关键词:", keyword);

        // 显示搜索状态
        isSearching = true;
        showSearchResults = true;

        // 清空之前的搜索结果
        searchResultModel.clear();

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:3000/api/videos/search?keyword=" + encodeURIComponent(keyword));
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                // 搜索完成，隐藏加载状态
                isSearching = false;

                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        console.log("📋 搜索响应:", JSON.stringify(response));

                        if (response.code === 0) {
                            if (response.data && response.data.length > 0) {
                                console.log("✅ 搜索成功，找到 " + response.data.length + " 个视频");

                                // 将搜索结果添加到模型中
                                for (var i = 0; i < response.data.length; i++) {
                                    var video = response.data[i];
                                    searchResultModel.append(video);
                                }
                            } else {
                                console.log("⚠️ 未找到匹配的视频");
                            }
                        } else {
                            console.log("❌ 搜索失败:", response.message);
                            showError("搜索失败: " + response.message);
                        }
                    } catch (e) {
                        console.log("❌ 解析响应失败:", e);
                        console.log("❌ 原始响应:", xhr.responseText);
                        showError("数据解析失败");
                    }
                } else {
                    console.log("❌ 请求失败，状态码:", xhr.status);
                    console.log("❌ 响应内容:", xhr.responseText);
                    showError("网络请求失败");
                }
            }
        };

        xhr.onerror = function() {
            isSearching = false;
            console.log("❌ 网络请求错误");
            showError("网络连接失败");
        };

        xhr.send();
    }

    // 可复用的视频组件
    Component {
        id: videoDelegate

        Rectangle {
            id: videoCard
            width: GridView.view.cellWidth - 10
            height: GridView.view.cellHeight - 10
            color: "white"
            radius: 4

            // 鼠标悬停效果
            property real hoverScale: 1.0
            property real borderWidth: 1
            property color borderColor: "#E5E9EF"
            property bool isSelected: false

            // 平滑动画
            Behavior on hoverScale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on borderWidth {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on borderColor {
                ColorAnimation {
                    duration: 300
                }
            }

            // 应用变换
            scale: hoverScale

            // 边框
            border.width: borderWidth
            border.color: borderColor

            // 鼠标悬停
            HoverHandler {
                cursorShape: Qt.PointingHandCursor

                onHoveredChanged: {
                    if (hovered) {
                        // 鼠标移入：轻微放大，边框变粉色
                        videoCard.hoverScale = 1.05
                        videoCard.borderWidth = 3
                        videoCard.borderColor = "#FF6699"  // 粉色
                    } else {
                        // 鼠标移出：恢复
                        videoCard.hoverScale = 1.0
                        videoCard.borderWidth = 1
                        videoCard.borderColor = "#E5E9EF"  // 灰色
                    }
                }
            }

            // 点击
            TapHandler {
                onTapped: {
                    console.log("点击视频:", modelData.id, modelData.title, modelData.videoUrl, modelData.viewCount)

                    // 设置选中状态
                    videoCard.isSelected = true
                    videoCard.borderWidth = 3
                    videoCard.borderColor = "#FF6699"  // 粉色

                    // 如果已有视频在播放，先停止并清理
                    if (videoLoaders.item) {
                        console.log("停止当前播放的视频")
                        videoLoaders.sourceComponent = undefined
                    }

                    userController.addWatchHistory(modelData.id)

                    var videoData = videoController.getVideo(modelData.id)

                    videoLoaders.setSource("qml/Video_Playback/Video.qml", {
                        videoId: modelData.id,
                        videoData: videoData,
                        videoManager: videoController,
                        index: index
                    })
                    videoController.loadVideos()
                }
            }

            // 内容区域
            Column {
                anchors {
                    fill: parent
                    margins: 10
                }
                spacing: 8

                Rectangle {
                    width: parent.width
                    height: 120
                    color: "lightgray"
                    radius: 4

                    Image {
                        id: coverImage
                        anchors.fill: parent
                        source: {
                            if(modelData.coverUrl) {
                                root.coverUrlStatue = true;
                                return modelData.coverUrl
                            } else {
                                root.coverUrlStatue = false;
                                return ""
                            }
                        }
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true

                        // 加载中显示
                        BusyIndicator {
                            anchors.centerIn: parent
                            running: coverImage.status === Image.Loading
                            width: 30
                            height: 30
                        }

                        // 加载失败显示
                        Text {
                            anchors.centerIn: parent
                            text: "封面加载失败"
                            font.pixelSize: 12
                            color: "#999999"
                            visible: !root.coverUrlStatue
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: modelData.title
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    spacing: 8

                    Image {
                        id: headImage
                        source: modelData.headUrl
                        width: 24
                        height: 24
                    }

                    Text {
                        text: modelData.author
                        font.pixelSize: 12
                        color: "#999"
                    }

                    Text {
                        font.pixelSize: 12
                        color: "#999"
                        text: "▶ " + modelData.viewCount
                    }
                }
            }

            // 选中时的动画
            SequentialAnimation {
                id: selectAnimation
                running: false

                // 放大
                PropertyAnimation {
                    target: videoCard
                    property: "scale"
                    to: 1.02
                    duration: 150
                }

                // 恢复
                PropertyAnimation {
                    target: videoCard
                    property: "scale"
                    to: 1.0
                    duration: 150
                }
            }

            // 当点击时触发选中动画
            onIsSelectedChanged: {
                if (isSelected) {
                    selectAnimation.start()
                }
            }
        }
    }

    // 可复用的视频组件
    Component {
        id: videoDelegate2

        Rectangle {
            id: videoCard
            width: GridView.view.cellWidth - 10
            height: GridView.view.cellHeight - 10
            color: "white"
            radius: 4

            // 鼠标悬停效果
            property real hoverScale: 1.0
            property real borderWidth: 1
            property color borderColor: "#E5E9EF"
            property bool isSelected: false

            // 平滑动画
            Behavior on hoverScale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on borderWidth {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on borderColor {
                ColorAnimation {
                    duration: 300
                }
            }

            // 应用变换
            scale: hoverScale

            // 边框
            border.width: borderWidth
            border.color: borderColor

            // 鼠标悬停
            HoverHandler {
                cursorShape: Qt.PointingHandCursor

                onHoveredChanged: {
                    if (hovered) {
                        // 鼠标移入：轻微放大，边框变粉色
                        videoCard.hoverScale = 1.05
                        videoCard.borderWidth = 3
                        videoCard.borderColor = "#FF6699"  // 粉色
                    } else {
                        // 鼠标移出：恢复
                        videoCard.hoverScale = 1.0
                        videoCard.borderWidth = 1
                        videoCard.borderColor = "#E5E9EF"  // 灰色
                    }
                }
            }

            // 点击
            TapHandler {
                onTapped: {
                    console.log("点击视频:", model.id, model.title, model.videoUrl, model.viewCount)

                    // 设置选中状态
                    videoCard.isSelected = true
                    videoCard.borderWidth = 3
                    videoCard.borderColor = "#FF6699"  // 粉色

                    // 如果已有视频在播放，先停止并清理
                    if (videoLoaders.item) {
                        console.log("停止当前播放的视频")
                        videoLoaders.sourceComponent = undefined
                    }

                    userController.addWatchHistory(model.id)

                    var videoData = videoController.getVideo(model.id)

                    videoLoaders.setSource("qml/Video_Playback/Video.qml", {
                        videoId: model.id,
                        videoData: videoData,
                        videoManager: videoController,
                        index: index
                    })
                    videoController.loadVideos()
                }
            }

            // 内容区域
            Column {
                anchors {
                    fill: parent
                    margins: 10
                }
                spacing: 8

                Rectangle {
                    width: parent.width
                    height: 120
                    color: "lightgray"
                    radius: 4

                    Image {
                        id: coverImage
                        anchors.fill: parent
                        source: {
                            if(model.cover_url) {
                                root.coverUrlStatue = true;
                                return model.cover_url
                            } else {
                                root.coverUrlStatue = false;
                                return ""
                            }
                        }
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true

                        // 加载中显示
                        BusyIndicator {
                            anchors.centerIn: parent
                            running: coverImage.status === Image.Loading
                            width: 30
                            height: 30
                        }

                        // 加载失败显示
                        Text {
                            anchors.centerIn: parent
                            text: "封面加载失败"
                            font.pixelSize: 12
                            color: "#999999"
                            visible: !root.coverUrlStatue
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: model.title
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    spacing: 8

                    Image {
                        id: headImage
                        source: model.head_url
                        width: 24
                        height: 24
                    }

                    Text {
                        text: model.author
                        font.pixelSize: 12
                        color: "#999"
                    }

                    Text {
                        font.pixelSize: 12
                        color: "#999"
                        text: "▶ " + model.view_count
                    }
                }
            }

            // 选中时的动画
            SequentialAnimation {
                id: selectAnimation
                running: false

                // 放大
                PropertyAnimation {
                    target: videoCard
                    property: "scale"
                    to: 1.02
                    duration: 150
                }

                // 恢复
                PropertyAnimation {
                    target: videoCard
                    property: "scale"
                    to: 1.0
                    duration: 150
                }
            }

            // 当点击时触发选中动画
            onIsSelectedChanged: {
                if (isSelected) {
                    selectAnimation.start()
                }
            }
        }
    }

    // 空搜索结果组件
    Component {
        id: emptySearchComponent

        Column {
            spacing: 20
            anchors.centerIn: parent

            Text {
                text: "🔍"
                font.pixelSize: 48
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "没有找到相关视频"
                font.pixelSize: 16
                color: "#666666"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "试试其他关键词"
                font.pixelSize: 14
                color: "#999999"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
