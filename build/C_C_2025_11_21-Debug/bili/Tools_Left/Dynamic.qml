import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects


ApplicationWindow{
    id: dynamicMindow
    visible: true
    width: 1200
    height: 700
    // title: "动态"
    // modal: true
    // focus: true
    // closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    signal closeRequested()
    // 主背景
    Rectangle {
        anchors.fill: parent
        color: "#f0f2f5"
    }

    // 主布局
    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15
        clip: true


        // 左侧用户列表
        Rectangle {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: "#ffffff"
            radius: 12
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.6
                shadowColor: "#20000000"
                shadowVerticalOffset: 2
                shadowHorizontalOffset: 0
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                // 标题
                Text {
                    text: "关注列表"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#1a1a1a"
                    Layout.bottomMargin: 10
                }

                // 用户列表
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: userList
                        model: userModel
                        delegate: userDelegate
                        highlight: Rectangle {
                            color: "#e3f2fd"
                            radius: 8
                        }
                        highlightMoveDuration: 200
                        highlightMoveVelocity: -1
                    }
                }
            }
        }

        // 右侧内容区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#ffffff"
            radius: 12
            layer.enabled: true

            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.6
                shadowColor: "#20000000"
                shadowVerticalOffset: 2
                shadowHorizontalOffset: 0
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // 当前选中用户信息
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#f8f9fa"
                    radius: 8


                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: selectedUser.color

                            Text {
                                anchors.centerIn: parent
                                text: selectedUser.name.charAt(0)
                                color: "white"
                                font.pixelSize: 18
                                font.bold: true
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            Text {
                                text: selectedUser.name
                                font.pixelSize: 16
                                font.bold: true
                                color: "#1a1a1a"
                            }
                            Text {
                                text: getCurrentVideoCount() + " 个视频"
                                font.pixelSize: 12
                                color: "#666666"
                            }
                        }

                        // 刷新按钮
                        Rectangle {
                            width: 35
                            height: 35
                            radius: 18
                            color: "#f0f0f0"

                            Text {
                                anchors.centerIn: parent
                                text: "🔄"
                                font.pixelSize: 16
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: refreshAllVideos()
                                hoverEnabled: true
                                onEntered: parent.color = "#e0e0e0"
                                onExited: parent.color = "#f0f0f0"
                            }
                        }
                    }
                }

                // 视频列表
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ListView {
                        id: videoList
                        model: getCurrentVideoModel()
                        delegate: videoDelegate
                        spacing: 15
                    }
                }
            }
        }
    }

    // 用户数据模型 - 每个视频都有内置时间戳
    ListModel {

        id: userModel
        ListElement {
            name: "全部动态"
            color: "#4CAF50"
            isAll: true
        }//TODO
        ListElement {
            name: "哔哩哔哩番剧"
            color: "#FF69B4"
            isAll: false
            videos: [
                ListElement {
                    title: "《明明只是暗杀者》预告";
                    description: "高中生织田晶与班上同学一起被召唤到了异世界，在召唤的影响下，他们每个人都获得了强大的能力...";
                    image: "https://via.placeholder.com/300x200/FF69B4/FFFFFF?text=Anime+1";
                    likes: 892;
                    comments: 156;
                    shares: 89;
                    timestamp: 1699200000; // 2023-11-05 20:00:00
                    author: "哔哩哔哩番剧"
                },
                ListElement {
                    title: "新番上线通知";
                    description: "10月新番阵容公布，多部重磅作品即将上线，包括《咒术回战》第二季、《鬼灭之刃》锻刀村篇...";
                    image: "https://via.placeholder.com/300x200/FFB6C1/FFFFFF?text=Anime+2";
                    likes: 445;
                    comments: 78;
                    shares: 34;
                    timestamp: 1699196400; // 2023-11-05 19:00:00
                    author: "哔哩哔哩番剧"
                },
                ListElement {
                    title: "动漫音乐推荐";
                    description: "本周最受欢迎的动漫歌曲TOP10，包括《鬼灭之刃》主题曲《红莲华》...";
                    image: "https://via.placeholder.com/300x200/FFC0CB/FFFFFF?text=Music+1";
                    likes: 678;
                    comments: 92;
                    shares: 56;
                    timestamp: 1699192800; // 2023-11-05 18:00:00
                    author: "哔哩哔哩番剧"
                }
            ]
        }
        ListElement {
            name: "游戏达人"
            color: "#2196F3"
            isAll: false
            videos: [
                ListElement {
                    title: "最新游戏攻略";
                    description: "《原神》4.0版本全攻略，包含所有隐藏任务、宝箱位置、角色培养建议...";
                    image: "https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Game+1";
                    likes: 567;
                    comments: 89;
                    shares: 45;
                    timestamp: 1699199100; // 2023-11-05 19:45:00
                    author: "游戏达人"
                },
                ListElement {
                    title: "游戏实况直播";
                    description: "今晚8点准时开播《塞尔达传说：王国之泪》通关直播，不见不散...";
                    image: "https://via.placeholder.com/300x200/64B5F6/FFFFFF?text=Game+2";
                    likes: 234;
                    comments: 45;
                    shares: 23;
                    timestamp: 1699195500; // 2023-11-05 18:45:00
                    author: "游戏达人"
                },
                ListElement {
                    title: "电竞比赛回顾";
                    description: "英雄联盟全球总决赛精彩瞬间回顾，Uzi传奇操作集锦...";
                    image: "https://via.placeholder.com/300x200/42A5F5/FFFFFF?text=ESports+1";
                    likes: 890;
                    comments: 167;
                    shares: 78;
                    timestamp: 1699191900; // 2023-11-05 17:45:00
                    author: "游戏达人"
                }
            ]
        }
        ListElement {
            name: "科技前沿"
            color: "#9C27B0"
            isAll: false
            videos: [
                ListElement {
                    title: "AI技术新突破";
                    description: "最新人工智能技术进展分享，GPT-5即将发布，性能提升10倍...";
                    image: "https://via.placeholder.com/300x200/9C27B0/FFFFFF?text=Tech+1";
                    likes: 789;
                    comments: 123;
                    shares: 67;
                    timestamp: 1699198200; // 2023-11-05 19:30:00
                    author: "科技前沿"
                },
                ListElement {
                    title: "数码产品评测";
                    description: "最新手机性能对比测试，iPhone 15 Pro Max vs 三星S23 Ultra...";
                    image: "https://via.placeholder.com/300x200/BA68C8/FFFFFF?text=Tech+2";
                    likes: 456;
                    comments: 67;
                    shares: 34;
                    timestamp: 1699194600; // 2023-11-05 18:30:00
                    author: "科技前沿"
                },
                ListElement {
                    title: "量子计算进展";
                    description: "中国量子计算机实现重大突破，计算速度超越传统计算机百万倍...";
                    image: "https://via.placeholder.com/300x200/AB47BC/FFFFFF?text=Quantum+1";
                    likes: 567;
                    comments: 89;
                    shares: 45;
                    timestamp: 1699191000; // 2023-11-05 17:30:00
                    author: "科技前沿"
                }
            ]
        }
        ListElement {
            name: "美食生活"
            color: "#FF9800"
            isAll: false
            videos: [
                ListElement {
                    title: "家常菜教程";
                    description: "10分钟搞定红烧肉，新手也能做出的美味佳肴，详细步骤分享...";
                    image: "https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Food+1";
                    likes: 345;
                    comments: 56;
                    shares: 23;
                    timestamp: 1699197300; // 2023-11-05 19:15:00
                    author: "美食生活"
                },
                ListElement {
                    title: "甜品制作";
                    description: "法式马卡龙制作教程，口感酥脆，内馅丰富，下午茶必备...";
                    image: "https://via.placeholder.com/300x200/FFB74D/FFFFFF?text=Dessert+1";
                    likes: 678;
                    comments: 98;
                    shares: 67;
                    timestamp: 1699193700; // 2023-11-05 18:15:00
                    author: "美食生活"
                }
            ]
        }
    }

    // 全部动态的合并模型
    ListModel {
        id: allVideosModel
    }

    // 当前选中的用户
    property var selectedUser: userModel.get(0)

    // 获取当前视频数量
    function getCurrentVideoCount() {
        if (selectedUser.isAll) {
            return allVideosModel.count
        } else {
            return selectedUser.videos.length
        }
    }

    // 获取当前视频模型
    function getCurrentVideoModel() {
        if (selectedUser.isAll) {
            return allVideosModel
        } else {
            return selectedUser.videos
        }
    }

    // 刷新所有视频（按时间排序）
    function refreshAllVideos() {
        allVideosModel.clear()
        var allVideos = []

        // 收集所有视频
        for (var i = 1; i < userModel.count; i++) {
            var user = userModel.get(i)
            for (var j = 0; j < user.videos.count; j++) {
                var video = user.videos.get(j)
                allVideos.push({
                                   title: video.title,
                                   description: video.description,
                                   image: video.image,
                                   likes: video.likes,
                                   comments: video.comments,
                                   shares: video.shares,
                                   timestamp: video.timestamp,
                                   author: video.author,
                                   originalIndex: j,
                                   originalUserIndex: i
                               })
            }
        }

        // 按时间戳排序（最新的在前）
        allVideos.sort(function(a, b) {
            return b.timestamp - a.timestamp
        })

        // 添加到模型
        for (var k = 0; k < allVideos.length; k++) {
            allVideosModel.append(allVideos[k])
        }
    }

    // 删除动态
    function deleteVideo(index, isAllDynamic) {
        if (isAllDynamic) {
            // 从全部动态中删除
            var video = allVideosModel.get(index)
            // 同时从原始用户的视频列表中删除
            var originalUser = userModel.get(video.originalUserIndex)
            originalUser.videos.remove(video.originalIndex)
            // 从全部动态模型中删除
            allVideosModel.remove(index)
        } else {
            // 从当前用户的视频列表中删除
            selectedUser.videos.remove(index)
        }
    }

    // 格式化时间 - 更详细的时间显示
    function formatTime(timestamp) {
        var date = new Date(timestamp * 1000)
        var now = new Date()
        var diff = (now - date) / 1000 // 秒

        if (diff < 60) return "刚刚"
        if (diff < 3600) return Math.floor(diff / 60) + "分钟前"
        if (diff < 86400) return Math.floor(diff / 3600) + "小时前"
        if (diff < 604800) return Math.floor(diff / 86400) + "天前"

        // 超过一周显示具体日期
        return date.toLocaleDateString() + " " + date.toLocaleTimeString().slice(0, 5)
    }

    // 获取详细时间信息
    function getDetailedTime(timestamp) {
        var date = new Date(timestamp * 1000)
        var options = {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        }
        return date.toLocaleString('zh-CN', options)
    }

    // 初始化时刷新所有视频
    Component.onCompleted: {
        refreshAllVideos()
    }

    // 用户列表项代理
    Component {
        id: userDelegate

        Rectangle {
            width: userList.width
            height: 50
            color: ListView.isCurrentItem ? "#e3f2fd" : "transparent"
            radius: 8

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: model.color

                    Text {
                        anchors.centerIn: parent
                        text: model.name.charAt(0)
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: model.name
                    font.pixelSize: 14
                    color: "#333333"
                    verticalAlignment: Text.AlignVCenter
                }

                // 未读提示
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: "#ff4444"
                    visible: index > 0 && !model.isAll
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    userList.currentIndex = index
                    selectedUser = userModel.get(index)
                    if (model.isAll) {
                        refreshAllVideos()
                    }
                }

                hoverEnabled: true
                onEntered: parent.color = "#f5f5f5"
                onExited: parent.color = ListView.isCurrentItem ? "#e3f2fd" : "transparent"
            }
        }
    }

    // 视频列表项代理
    Component {
        id: videoDelegate

        Rectangle {
            width: videoList.width
            height: 340
            color: "#ffffff"
            radius: 10
            border.color: "#e0e0e0"
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.3
                shadowColor: "#10000000"
                shadowVerticalOffset: 1
            }

            // 删除按钮
            Rectangle {
                id: deleteButton
                anchors.bottom:parent.bottom
                anchors.right: parent.right
                anchors.margins: 10
                width: 32
                height: 32
                radius: 16
                color: deleteMouseArea.containsMouse ? "#ffebe6" : "#fff5f5"
                border.color: "#ffccc7"
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "🗑️"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: deleteMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        deleteVideo(index, selectedUser.isAll)
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                anchors.topMargin: 10
                spacing: 12

                // 视频封面
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    radius: 8
                    color: "#f0f0f0"

                    Image {
                        anchors.fill: parent
                        source: model.image
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                // 视频标题和作者信息
                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: model.title
                        font.pixelSize: 16
                        font.bold: true
                        color: "#1a1a1a"
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    // 显示作者和时间
                    Text {
                        text: {
                            if (selectedUser.isAll) {
                                return model.author + " · " + formatTime(model.timestamp)
                            } else {
                                return formatTime(model.timestamp)
                            }
                        }
                        font.pixelSize: 12
                        color: "#999999"
                    }

                    // 悬停时显示详细时间
                    Text {
                        text: "发布时间: " + getDetailedTime(model.timestamp)
                        font.pixelSize: 11
                        color: "#cccccc"
                        visible: mouseArea.containsMouse
                    }
                }

                // 视频描述
                Text {
                    Layout.fillWidth: true
                    text: model.description
                    font.pixelSize: 13
                    color: "#666666"
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }


                Row {
                    Layout.fillWidth: true
                    spacing: 20
                    Rectangle {
                        id: retweetButton // 给每个按钮一个唯一的ID
                        width: 80
                        height: 32
                        radius: 16
                        border.color: "#e0e0e0"
                        border.width: 1

                        // 每个按钮独立的状态和计数值
                        property bool activated: false
                        property int count: 111

                        // 颜色绑定逻辑保持不变，但引用自身的属性
                        color: activated ? "#e3f2fd" : (maRetweet.containsMouse ? "#f0f0f0" : "#f8f9fa")

                        Row {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                text: "↻" // 硬编码图标
                                font.pixelSize: 14
                            }

                            Text {
                                text: retweetButton.count // 引用自身的计数值
                                font.pixelSize: 12
                                color: "#666666"
                            }
                        }

                        MouseArea {
                            id: maRetweet // 给MouseArea一个唯一ID
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                console.log("Clicked: 转发")

                                // 切换自身的激活状态
                                retweetButton.activated = !retweetButton.activated

                                // 根据新状态更新自身的计数值
                                if (retweetButton.activated) {
                                    retweetButton.count++
                                } else {
                                    retweetButton.count--
                                }
                            }
                        }
                    }

                    //  按钮 2: 评论
                    Rectangle {
                        id: commentButton
                        width: 80
                        height: 32
                        radius: 16
                        border.color: "#e0e0e0"
                        border.width: 1

                        property bool activated: false
                        property int count: 99

                        color: activated ? "#e3f2fd" : (maComment.containsMouse ? "#f0f0f0" : "#f8f9fa")

                        Row {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                text: "💬"
                                font.pixelSize: 14
                            }

                            Text {
                                text: commentButton.count
                                font.pixelSize: 12
                                color: "#666666"
                            }
                        }

                        MouseArea {
                            id: maComment
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                console.log("Clicked: 评论")
                                commentButton.activated = !commentButton.activated
                                if (commentButton.activated) {
                                    commentButton.count++
                                } else {
                                    commentButton.count--
                                }
                            }
                        }
                    }

                    //  按钮 3: 点赞
                    Rectangle {
                        id: likeButton
                        width: 80
                        height: 32
                        radius: 16
                        border.color: "#e0e0e0"
                        border.width: 1

                        property bool activated: false
                        property int count: 666

                        color: activated ? "#e3f2fd" : (maLike.containsMouse ? "#f0f0f0" : "#f8f9fa")

                        Row {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                text: "❤"
                                font.pixelSize: 14
                            }

                            Text {
                                text: likeButton.count
                                font.pixelSize: 12
                                color: "#666666"
                            }
                        }

                        MouseArea {
                            id: maLike
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                console.log("Clicked: 点赞")
                                likeButton.activated = !likeButton.activated
                                if (likeButton.activated) {
                                    likeButton.count++
                                } else {
                                    likeButton.count--
                                }
                            }
                        }
                    }
                }

                // 用于检测鼠标悬停
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton // 只接收悬停事件，不接收点击
                }
            }
        }
    }
    onClosing: {
            console.log("动态窗口关闭")
            closeRequested()  // 发送信号而不是直接销毁
        }

        // ✅ 添加关闭按钮（可选但推荐）
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            width: 40
            height: 40
            color: closeBtn.hovered ? "#f0f0f0" : "transparent"

            Text {
                anchors.centerIn: parent
                text: "×"
                font.pixelSize: 20
            }

            MouseArea {
                id: closeBtn
                anchors.fill: parent
                hoverEnabled: true
                onClicked: closeRequested()  // 点击关闭时发送信号
            }
        }
}
