import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

Rectangle {
    id: personInfoPage
    color: "#f4f4f4"

    // 接收全局头像URL属性
    property alias globalAvatarUrl: personInfoPage.avatarUrl
    property string avatarUrl: "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"

    // 状态管理
    property int selectedHistoryIndex: -1//历史记录index
    property bool isHistoryEmpty: false
    property int currentTabIndex: 0//当前个人的历史记录，离线换存的index

    // 新增：关注和粉丝列表显示状态
    property bool showFollowingList: false
    property bool showFollowerList : false

    // 收藏夹相关属性
    property bool showCollectionList: false
    property string currentCollectionGroup: "默认收藏夹"
    property var collectionGroups: ["默认收藏夹", "学习资料", "娱乐视频", "音乐收藏"]
    property var selectedCollectionItems: ({})

    // 加载模拟关注数据
    function loadMockFollowingData() {
        followingListModel.clear()

        // 添加模拟关注用户
        followingListModel.append({
            account: "user001",
            nickname: "科技小王子",
            sign: "分享最新科技资讯和产品评测",
            headportrait: ""
        })

        followingListModel.append({
            account: "user002",
            nickname: "美食探险家",
            sign: "走遍大街小巷寻找美味",
            headportrait: ""
        })

        followingListModel.append({
            account: "user003",
            nickname: "游戏达人",
            sign: "专业游戏攻略和直播",
            headportrait: ""
        })

        followingListModel.append({
            account: "user004",
            nickname: "旅行摄影师",
            sign: "用镜头记录世界的美好",
            headportrait: ""
        })

        console.log("加载模拟关注数据完成，数量:", followingListModel.count)
    }

    // 加载模拟粉丝数据
    function loadMockFollowerData() {
        followerListModel.clear()

        // 添加模拟粉丝用户
        followerListModel.append({
            account: "fans001",
            nickname: "学习小助手",
            sign: "每天分享学习技巧和心得",
            headportrait: ""
        })

        followerListModel.append({
            account: "fans002",
            nickname: "音乐爱好者",
            sign: "好听的音乐都在这里",
            headportrait: ""
        })

        followerListModel.append({
            account: "fans003",
            nickname: "电影迷",
            sign: "最新电影资讯和影评",
            headportrait: ""
        })

        console.log("加载模拟粉丝数据完成，数量:", followerListModel.count)
    }

    // 模拟关注用户
    function mockFollowUser(targetAccount) {
        console.log("模拟关注用户:", targetAccount)
        // 这里只是UI效果，不实际调用数据库
    }

    // 模拟取消关注
    function mockUnfollowUser(targetAccount) {
        console.log("模拟取消关注用户:", targetAccount)
        // 这里只是UI效果，不实际调用数据库
    }

    // 设置主窗口头像URL的函数
    function setMainAvatarUrl(url) {
        console.log("个人信息页面设置主窗口头像URL:", url)
        avatarUrl = url
        // 直接更新主窗口的globalAvatarUrl
        root.globalAvatarUrl = url
    }

    // 获取搜索提示文本
    function getSearchPlaceholder() {
        switch(currentTabIndex) {
            case 0: return "搜索你的历史记录";
            case 1: return "搜索你的离线缓存";
            case 2: return "搜索你的收藏";
            case 3: return "搜索你的稍后再看";
            default: return "搜索";
        }
    }

    // 获取清空按钮文本
    function getClearButtonText() {
        switch(currentTabIndex) {
            case 0: return "清空记录";
            case 1: return "清空缓存";
            case 2: return "清空收藏";
            case 3: return "清空列表";
            default: return "清空";
        }
    }

    // 加载关注列表
    function loadFollowingList() {
        console.log("=== 开始加载关注列表 ===");
        console.log("当前用户账号:", root.currentUserAccount);
        console.log("是否已登录:", root.isLoggedIn);

        // 检查登录状态
        if (!root.isLoggedIn) {
            console.log("❌ 用户未登录，无法加载关注列表");
            followingList.model.clear();
            return;
        }

        if (!root.currentUserAccount) {
            console.log("❌ 用户账号未设置");
            return;
        }

        // 调用数据库接口
        var followingArray = databaseUser.getFollowingList(root.currentUserAccount);
        console.log("数据库返回的关注数据:", followingArray);

        followingList.model.clear();

        if (followingArray && followingArray.length > 0) {
            console.log("找到", followingArray.length, "个关注用户");
            for (var i = 0; i < followingArray.length; i++) {
                var user = followingArray[i];
                console.log("添加关注用户:", user.nickname, user.account);
                followingList.model.append({
                    account: user.account,
                    nickname: user.nickname,
                    sign: user.sign || "这个用户很懒，什么都没有写",
                    headportrait: user.headportrait || ""
                });
            }
        } else {
            console.log("关注列表为空，显示空状态");
        }

        console.log("=== 关注列表加载完成 ===");
    }

    // 加载粉丝列表
    function loadFollowerList() {
        console.log("=== 开始加载粉丝列表 ===");
        console.log("当前用户账号:", root.currentUserAccount);
        console.log("是否已登录:", root.isLoggedIn);

        if (!root.isLoggedIn) {
            console.log("❌ 用户未登录，无法加载粉丝列表");
            followerList.model.clear();
            return;
        }

        if (!root.currentUserAccount) {
            console.log("❌ 用户账号未设置");
            return;
        }

        var followerArray = databaseUser.getFollowerList(root.currentUserAccount);
        console.log("数据库返回的粉丝数据:", followerArray);

        followerList.model.clear();

        if (followerArray && followerArray.length > 0) {
            console.log("找到", followerArray.length, "个粉丝");
            for (var i = 0; i < followerArray.length; i++) {
                var user = followerArray[i];
                console.log("添加粉丝用户:", user.nickname, user.account);
                followerList.model.append({
                    account: user.account,
                    nickname: user.nickname,
                    sign: user.sign || "这个用户很懒，什么都没有写",
                    headportrait: user.headportrait || ""
                });
            }
        } else {
            console.log("粉丝列表为空，显示空状态");
        }

        console.log("=== 粉丝列表加载完成 ===");
    }

    // 取消关注
    function unfollowUser(targetAccount) {
        var success = databaseUser.unfollowUser(root.currentUserAccount, targetAccount);
        if (success) {
            // 从列表中移除
            for (var i = 0; i < followingList.model.count; i++) {
                if (followingList.model.get(i).account === targetAccount) {
                    followingList.model.remove(i);
                    break;
                }
            }
        }
    }

    // 关闭所有列表
    function closeAllLists() {
        showFollowingList = false;
        showFollowerList = false;
    }

    // 收藏夹相关函数
    function hasSelectedItems() {
        for (var i = 0; i < collectionModel.count; i++) {
            if (collectionModel.get(i).selected && collectionModel.get(i).group === currentCollectionGroup) {
                return true
            }
        }
        return false
    }

    function getSelectedCount() {
        var count = 0
        for (var i = 0; i < collectionModel.count; i++) {
            if (collectionModel.get(i).selected && collectionModel.get(i).group === currentCollectionGroup) {
                count++
            }
        }
        return count
    }

    function selectAllItems() {
        for (var i = 0; i < collectionModel.count; i++) {
            if (collectionModel.get(i).group === currentCollectionGroup) {
                collectionModel.setProperty(i, "selected", true)
            }
        }
        updateSelectionCount()
    }

    function clearAllSelection() {
        for (var i = 0; i < collectionModel.count; i++) {
            collectionModel.setProperty(i, "selected", false)
        }
        updateSelectionCount()
    }

    function updateSelectionCount() {
        // 更新全选复选框状态
        var allSelected = true
        for (var i = 0; i < collectionModel.count; i++) {
            if (collectionModel.get(i).group === currentCollectionGroup && !collectionModel.get(i).selected) {
                allSelected = false
                break
            }
        }
        selectAllCheckBox.checked = allSelected
    }

    function showDeleteConfirmDialog() {
        deleteConfirmPopup.isBatchDelete = true
        deleteConfirmPopup.open()
    }

    function showSingleDeleteConfirm(index) {
        deleteConfirmPopup.isBatchDelete = false
        deleteConfirmPopup.deleteIndex = index
        deleteConfirmPopup.open()
    }

    function deleteSelectedItems() {
        for (var i = collectionModel.count - 1; i >= 0; i--) {
            if (collectionModel.get(i).selected && collectionModel.get(i).group === currentCollectionGroup) {
                collectionModel.remove(i)
            }
        }
        clearAllSelection()
        updateGroupVideoCount()
    }

    // 显示删除收藏夹确认对话框
    function showDeleteGroupConfirm() {
        var currentGroup = collectionGroupModel.get(groupComboBox.currentIndex).groupName
        if (currentGroup === "默认收藏夹") {
            console.log("默认收藏夹不能删除")
            return
        }
        deleteGroupPopup.groupToDelete = currentGroup
        deleteGroupPopup.open()
    }

    // 删除收藏夹
    function deleteCollectionGroup(groupName) {
        console.log("删除收藏夹:", groupName)

        // 从收藏分组模型中移除
        for (var i = 0; i < collectionGroupModel.count; i++) {
            if (collectionGroupModel.get(i).groupName === groupName) {
                collectionGroupModel.remove(i)
                break
            }
        }

        // 从收藏数据模型中移除该分组的所有视频
        for (var j = collectionModel.count - 1; j >= 0; j--) {
            if (collectionModel.get(j).group === groupName) {
                collectionModel.remove(j)
            }
        }

        // 如果删除的是当前选中的收藏夹，切换到默认收藏夹
        if (currentCollectionGroup === groupName) {
            currentCollectionGroup = "默认收藏夹"
            groupComboBox.currentIndex = 0
        }

        updateGroupVideoCount()
        console.log("收藏夹删除完成")
    }

    // 获取当前收藏夹的视频数量
    function getFilteredCount() {
        var count = 0
        for (var i = 0; i < collectionModel.count; i++) {
            if (collectionModel.get(i).group === currentCollectionGroup) {
                count++
            }
        }
        return count
    }

    // 更新收藏分组模型的视频数量
    function updateGroupVideoCount() {
        for (var i = 0; i < collectionGroupModel.count; i++) {
            var groupName = collectionGroupModel.get(i).groupName
            var count = 0
            for (var j = 0; j < collectionModel.count; j++) {
                if (collectionModel.get(j).group === groupName) {
                    count++
                }
            }
            collectionGroupModel.setProperty(i, "videoCount", count)
        }
    }

    // 创建新收藏夹
    function createNewCollectionGroup(groupName) {
        if (groupName.trim() !== "") {
            collectionGroupModel.append({
                "groupName": groupName,
                "videoCount": 0
            })
            console.log("创建新收藏夹:", groupName)
        }
    }

    // 文件选择对话框
    FileDialog {
        id: fileDialog
        title: "选择头像图片"
        nameFilters: ["图片文件 (*.png *.jpg *.jpeg)"]
        onAccepted: {
            console.log("选择的文件: " + selectedFile)
            // 更新头像URL
            setMainAvatarUrl(selectedFile)
        }
    }

    // 头像大图弹窗
    Popup {
        id: largeImagePopup
        width: Math.min(parent.width * 0.9, 500)
        height: Math.min(parent.height * 0.9, 500)
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        contentItem: Image {
            id: largeImage
            source: avatarUrl
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: false

            // 点击关闭
            TapHandler {
                onTapped: largeImagePopup.close()
            }
        }

        // 关闭按钮
        Button {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            width: 30
            height: 30
            padding: 0
            background:null

            contentItem: Text {
                text: "×"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                anchors.centerIn: parent
            }

            onClicked: largeImagePopup.close()
        }
    }

    // 用户信息弹窗
    Popup {
        id: userInfoPopup
        width: 320
        height: 320
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 15

        background: Rectangle {
            color: "white"
            radius: 12
            border.color: "#e0e0e0"
            border.width: 1
        }

        contentItem: Column {
            width: parent.width
            spacing: 20

            // 顶部标题栏和关闭按钮
            Item {
                width: parent.width
                height: 30

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "📷 用户信息"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#333"
                }

                Button {
                    id: closeButton
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 24
                    padding: 0
                    background: null

                    contentItem: Text {
                        text: "×"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#666"
                        anchors.centerIn: parent
                    }

                    onClicked: userInfoPopup.close()
                }
            }

            // 用户头像显示区域
            Column {
                width: parent.width
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 80
                    height: 80
                    radius: 40
                    clip: true
                    opacity: isHistoryEmpty ? 0.6 : 1.0
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        id: avatarImage
                        anchors.fill: parent
                        source: avatarUrl
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Text {
                    text: "用户名"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: 60
                    height: 20
                    color: "#FB7299"
                    radius: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "大会员"
                        color: "white"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }

            // 功能按钮区域
            Column {
                width: parent.width
                spacing: 12

                Button {
                    width: parent.width
                    height: 40
                    text: "查看大图"

                    background: Rectangle {
                        color: parent.hovered ? "#f8f8f8" : "white"
                        radius: 8
                        border.color: parent.down ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#333"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("查看头像大图")
                        largeImagePopup.open()
                    }
                }

                Button {
                    width: parent.width
                    height: 40
                    text: "更换头像"

                    background: Rectangle {
                        color: parent.hovered ? "#f8f8f8" : "white"
                        radius: 8
                        border.color: parent.down ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#333"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("更换头像")
                        fileDialog.open()
                    }
                }
            }
        }
    }

    // 历史记录数据模型
    ListModel {
        id: historyModel
        ListElement {
            title: "孙吧学生会"
            author: "沈井彬-擒史皇"
            duration: "00:20/02:43"
            time: "16:04"
            up: "夏日枯竭中 豆花ono"
            badge: ""
        }
        ListElement {
            title: "50年后的魔怔XX玩家"
            author: "愚昧的羊群 -去看流星雨-"
            duration: "00:10/02:28"
            time: "16:01"
            badge: ""
        }
        ListElement {
            title: "-去看流星雨-"
            author: ""
            duration: "00:06/00:39"
            time: "16:02"
            badge: ""
        }
        ListElement {
            title: "-去看流星雨-"
            author: ""
            duration: "00:11/00:18"
            time: "16:02"
            badge: ""
        }
        ListElement {
            title: "《难绷TV》丁亮他爸当年那一下可不得了"
            author: "抽象TV频道"
            duration: "00:30/02:03"
            time: "16:04"
            badge: "已看完"
        }
    }

    // 关注列表模型
    ListModel {
        id: followingListModel
    }

    // 粉丝列表模型
    ListModel {
        id: followerListModel
    }

    // 收藏数据模型 - 修复：确保默认收藏夹有视频
    ListModel {
        id: collectionModel
        ListElement {
            title: "Python编程入门教程"
            author: "编程小王子"
            duration: "15:30"
            group: "默认收藏夹"
            selected: false
        }
        ListElement {
            title: "经典老歌合集"
            author: "音乐达人"
            duration: "45:20"
            group: "默认收藏夹"
            selected: false
        }
        ListElement {
            title: "搞笑动物视频"
            author: "欢乐时刻"
            duration: "03:15"
            group: "默认收藏夹"
            selected: false
        }
        ListElement {
            title: "机器学习实战"
            author: "AI探索者"
            duration: "28:45"
            group: "学习资料"
            selected: false
        }
        ListElement {
            title: "数据结构与算法"
            author: "算法大师"
            duration: "35:20"
            group: "学习资料"
            selected: false
        }
        ListElement {
            title: "搞笑猫咪合集"
            author: "萌宠世界"
            duration: "08:45"
            group: "娱乐视频"
            selected: false
        }
        ListElement {
            title: "游戏搞笑时刻"
            author: "游戏达人"
            duration: "12:30"
            group: "娱乐视频"
            selected: false
        }
        ListElement {
            title: "周杰伦经典歌曲"
            author: "音乐收藏家"
            duration: "60:15"
            group: "音乐收藏"
            selected: false
        }
        ListElement {
            title: "钢琴演奏合集"
            author: "音乐大师"
            duration: "42:30"
            group: "音乐收藏"
            selected: false
        }
    }

    // 收藏分组模型
    ListModel {
        id: collectionGroupModel
        ListElement {
            groupName: "默认收藏夹"
            videoCount: 3
        }
        ListElement {
            groupName: "学习资料"
            videoCount: 2
        }
        ListElement {
            groupName: "娱乐视频"
            videoCount: 2
        }
        ListElement {
            groupName: "音乐收藏"
            videoCount: 2
        }
    }

    // 创建新收藏夹的弹窗
    Popup {
        id: createGroupPopup
        width: 400
        height: 200
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true

        background: Rectangle {
            color: "white"
            radius: 8
            border.color: "#e0e0e0"
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: "新建收藏夹"
                font.pixelSize: 18
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: newGroupName
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                placeholderText: "请输入收藏夹名称"
                background: Rectangle {
                    color: "#f5f5f5"
                    radius: 4
                    border.color: parent.focus ? "#FB7299" : "#e0e0e0"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "取消"
                    background: Rectangle {
                        color: parent.down ? "#f0f0f0" : "#f5f5f5"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#666"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: createGroupPopup.close()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "创建"
                    background: Rectangle {
                        color: parent.down ? "#e05571" : "#FB7299"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (newGroupName.text.trim() !== "") {
                            createNewCollectionGroup(newGroupName.text)
                            newGroupName.text = ""
                            createGroupPopup.close()
                        }
                    }
                }
            }
        }
    }

    // 删除确认对话框
    Popup {
        id: deleteConfirmPopup
        width: 350
        height: 180
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true

        property bool isBatchDelete: true
        property int deleteIndex: -1

        background: Rectangle {
            color: "white"
            radius: 8
            border.color: "#e0e0e0"
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: "确认删除"
                font.pixelSize: 18
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: deleteConfirmPopup.isBatchDelete ?
                      "确定要删除选中的 " + getSelectedCount() + " 个收藏吗？" :
                      "确定要删除这个收藏吗？"
                font.pixelSize: 14
                color: "#666"
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "取消"
                    background: Rectangle {
                        color: parent.down ? "#f0f0f0" : "#f5f5f5"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#666"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: deleteConfirmPopup.close()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "确定删除"
                    background: Rectangle {
                        color: parent.down ? "#d32f2f" : "#f44336"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (deleteConfirmPopup.isBatchDelete) {
                            deleteSelectedItems()
                        } else {
                            collectionModel.remove(deleteConfirmPopup.deleteIndex)
                            updateGroupVideoCount()
                        }
                        deleteConfirmPopup.close()
                    }
                }
            }
        }
    }

    // 删除收藏夹确认对话框
    Popup {
        id: deleteGroupPopup
        width: 350
        height: 180
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true

        property string groupToDelete: ""

        background: Rectangle {
            color: "white"
            radius: 8
            border.color: "#e0e0e0"
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: "删除收藏夹"
                font.pixelSize: 18
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "确定要删除收藏夹 \"" + deleteGroupPopup.groupToDelete + "\" 吗？\n删除后无法恢复！"
                font.pixelSize: 14
                color: "#666"
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "取消"
                    background: Rectangle {
                        color: parent.down ? "#f0f0f0" : "#f5f5f5"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#666"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: deleteGroupPopup.close()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "确定删除"
                    background: Rectangle {
                        color: parent.down ? "#d32f2f" : "#f44336"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        deleteCollectionGroup(deleteGroupPopup.groupToDelete)
                        deleteGroupPopup.close()
                    }
                }
            }
        }
    }

    // 清空历史记录函数
    function clearHistory() {
        historyModel.clear()
        selectedHistoryIndex = -1
        isHistoryEmpty = true
    }

    // 主要内容区域
    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 0

            // 用户信息卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: "#f5f5f5"

                Item {
                    anchors.fill: parent
                    anchors.margins: 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        Column {
                            spacing: 10
                            Layout.alignment: Qt.AlignTop

                            Rectangle {
                                id: userAvatar
                                width: 80
                                height: 80
                                radius: 40
                                clip: true
                                opacity: isHistoryEmpty ? 0.6 : 1.0

                                Image {
                                    id: mainAvatarImage
                                    anchors.fill: parent
                                    source: avatarUrl
                                    fillMode: Image.PreserveAspectCrop
                                }

                                TapHandler {
                                    onTapped: {
                                        console.log("头像被点击，打开用户信息弹窗")
                                        userInfoPopup.open()
                                    }
                                }
                            }

                            Column {
                                width: 80
                                spacing: 5

                                Text {
                                    width: parent.width
                                    text: "用户名"
                                    font.pixelSize: 14
                                    font.bold: true
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 20
                                    color: "#FB7299"
                                    radius: 4

                                    Text {
                                        anchors.centerIn: parent
                                        text: "大会员"
                                        color: "white"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 30

                                Column {
                                    Layout.alignment: Qt.AlignCenter
                                    Text {
                                        text: "15"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#FB7299"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "动态"
                                        font.pixelSize: 12
                                        color: "#999"
                                    }
                                }

                                // 关注 - 可点击
                                Column {
                                    Layout.alignment: Qt.AlignCenter
                                    spacing: 2

                                    Text {
                                        text: "1260"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#FB7299"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: "关注"
                                        font.pixelSize: 12
                                        color: "#999"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showFollowingList = !showFollowingList;
                                            showFollowerList = false;
                                            // 不需要调用数据库，直接显示已有模拟数据
                                        }
                                    }
                                }

                                // 粉丝 - 可点击
                                Column {
                                    Layout.alignment: Qt.AlignCenter
                                    spacing: 2

                                    Text {
                                        text: "16"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#FB7299"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: "粉丝"
                                        font.pixelSize: 12
                                        color: "#999"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showFollowerList = !showFollowerList;
                                            showFollowingList = false;
                                            // 不需要调用数据库，直接显示已有模拟数据
                                        }
                                    }
                                }
                                Column {
                                    Layout.alignment: Qt.AlignCenter
                                    Text {
                                        text: "794"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#FFB11B"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "硬币"
                                        font.pixelSize: 12
                                        color: "#999"
                                    }
                                }

                                Column {
                                    Layout.alignment: Qt.AlignCenter
                                    Text {
                                        text: "0"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#00A1D6"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "B币"
                                        font.pixelSize: 12
                                        color: "#999"
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 1
                                    Layout.preferredHeight: 40
                                    color: "#e0e0e0"
                                }

                                Button {
                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 36
                                    text: "成为大会员"
                                    background: Rectangle {
                                        color: "#FB7299"
                                        radius: 18
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        font.pixelSize: 12
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }
                }
            }

            // 功能标签区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "white"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    spacing: 30

                    Repeater {
                        model: ["历史记录", "离线缓存", "我的收藏", "稍后再看"]

                        delegate: Rectangle {
                            id: tabItem
                            width: 80
                            height: parent.height
                            color: "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 14
                                color: currentTabIndex === index ? "#FB7299" : "#666"
                                font.bold: currentTabIndex === index
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 2
                                color: "#FB7299"
                                visible: currentTabIndex === index
                            }

                            TapHandler {
                                onTapped: {
                                    currentTabIndex = index
                                    console.log("点击标签:", modelData)
                                    // 关闭关注/粉丝列表
                                    closeAllLists();
                                }
                            }
                        }
                    }
                }
            }

            // 搜索和清空区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "white"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    TextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        placeholderText: getSearchPlaceholder()
                        placeholderTextColor: "#999"
                        background: Rectangle {
                            color: "#f4f4f4"
                            radius: 4
                            border.color: parent.focus ? "#FB7299" : "transparent"
                        }
                    }

                    Button {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 36
                        text: getClearButtonText()
                        background: Rectangle {
                            color: "#f4f4f4"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#666"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            if (currentTabIndex === 0) {
                                clearHistory()
                            } else {
                                console.log("清空操作:", getClearButtonText())
                            }
                        }
                    }
                }
            }

            // 收藏夹管理页面
            Rectangle {
                id: collectionContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: currentTabIndex === 2 && !showFollowingList && !showFollowerList
                color: "#f4f4f4"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 收藏夹头部
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: "white"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15

                            // 收藏夹选择
                            ComboBox {
                                id: groupComboBox
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 40
                                model: collectionGroupModel
                                textRole: "groupName"
                                background: Rectangle {
                                    color: "#f5f5f5"
                                    radius: 4
                                    border.color: parent.focus ? "#FB7299" : "#e0e0e0"
                                }
                                onCurrentIndexChanged: {
                                    currentCollectionGroup = currentText
                                    // 更新收藏分组模型的视频数量
                                    updateGroupVideoCount()
                                }
                            }

                            Text {
                                text: "共 " + getFilteredCount() + " 个视频"
                                font.pixelSize: 14
                                color: "#666"
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            // 操作按钮
                            Button {
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 36
                                text: "新建收藏夹"
                                background: Rectangle {
                                    color: parent.down ? "#e05571" : "#FB7299"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: createGroupPopup.open()
                            }

                            Button {
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 36
                                text: "删除收藏夹"
                                visible: groupComboBox.currentIndex > 0 // 默认收藏夹不能删除
                                background: Rectangle {
                                    color: parent.down ? "#d32f2f" : "#f44336"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    showDeleteGroupConfirm()
                                }
                            }

                            Button {
                                id: batchDeleteBtn
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 36
                                text: "批量删除"
                                visible: hasSelectedItems()
                                background: Rectangle {
                                    color: parent.down ? "#d32f2f" : "#f44336"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: showDeleteConfirmDialog()
                            }
                        }
                    }

                    // 收藏视频列表
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        ScrollView {
                            anchors.fill: parent
                            clip: true

                            ColumnLayout {
                                width: parent.width
                                spacing: 1

                                // 全选操作栏
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 50
                                    color: "white"
                                    visible: getFilteredCount() > 0

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 15
                                        spacing: 15

                                        CheckBox {
                                            id: selectAllCheckBox
                                            Layout.preferredWidth: 20
                                            Layout.preferredHeight: 20
                                            checked: false
                                            onCheckedChanged: {
                                                if (checked) {
                                                    selectAllItems()
                                                } else {
                                                    clearAllSelection()
                                                }
                                            }
                                        }

                                        Text {
                                            text: "全选"
                                            font.pixelSize: 14
                                            color: "#333"
                                        }

                                        Text {
                                            text: "已选择 " + getSelectedCount() + " 个项目"
                                            font.pixelSize: 14
                                            color: "#FB7299"
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }
                                    }
                                }

                                // 收藏视频列表 - 使用 Repeater 并筛选显示
                                Repeater {
                                    model: collectionModel

                                    delegate: Rectangle {
                                        id: collectionItem
                                        width: collectionListView.width
                                        height: model.group === currentCollectionGroup ? 100 : 0
                                        visible: model.group === currentCollectionGroup
                                        color: model.selected ? "#fff0f0" : "white"

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 15
                                            spacing: 15

                                            // 选择框
                                            CheckBox {
                                                id: itemCheckBox
                                                Layout.preferredWidth: 20
                                                Layout.preferredHeight: 20
                                                checked: model.selected
                                                onCheckedChanged: {
                                                    model.selected = checked
                                                    updateSelectionCount()
                                                }
                                            }

                                            // 视频缩略图
                                            Rectangle {
                                                Layout.preferredWidth: 120
                                                Layout.preferredHeight: 70
                                                color: "#e0e0e0"
                                                radius: 4

                                                Rectangle {
                                                    anchors.bottom: parent.bottom
                                                    width: parent.width
                                                    height: 3
                                                    color: "#e0e0e0"

                                                    Rectangle {
                                                        width: parent.width * 0.6
                                                        height: parent.height
                                                        color: "#FB7299"
                                                    }
                                                }

                                                Text {
                                                    anchors {
                                                        right: parent.right
                                                        bottom: parent.bottom
                                                        margins: 5
                                                    }
                                                    text: model.duration
                                                    color: "white"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }
                                            }

                                            // 视频信息
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                spacing: 5

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: model.title
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                    color: "#333"
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: "UP: " + model.author
                                                    font.pixelSize: 14
                                                    color: "#666"
                                                }

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 10

                                                    Text {
                                                        text: "时长: " + model.duration
                                                        font.pixelSize: 12
                                                        color: "#999"
                                                    }

                                                    Text {
                                                        text: "收藏夹: " + model.group
                                                        font.pixelSize: 12
                                                        color: "#FB7299"
                                                    }

                                                    Item {
                                                        Layout.fillWidth: true
                                                    }
                                                }
                                            }

                                            // 操作按钮
                                            Button {
                                                Layout.preferredWidth: 80
                                                Layout.preferredHeight: 30
                                                text: "移除"
                                                background: Rectangle {
                                                    color: parent.down ? "#d32f2f" : "#f44336"
                                                    radius: 4
                                                }
                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "white"
                                                    font.pixelSize: 12
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                onClicked: {
                                                    showSingleDeleteConfirm(index)
                                                }
                                            }
                                        }

                                        // 分隔线
                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            width: parent.width
                                            height: 1
                                            color: "#f0f0f0"
                                            visible: model.group === currentCollectionGroup
                                        }
                                    }
                                }

                                // 空状态
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 300
                                    color: "transparent"
                                    visible: getFilteredCount() === 0

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 20
                                        opacity: 0.6

                                        Text {
                                            text: "❤️"
                                            font.pixelSize: 48
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Text {
                                            text: "收藏夹空空如也"
                                            font.pixelSize: 16
                                            color: "#666"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Text {
                                            text: "快去发现精彩内容收藏起来吧～"
                                            font.pixelSize: 14
                                            color: "#999"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 历史记录和离线缓存区域
            Rectangle {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: (currentTabIndex === 0 || currentTabIndex === 1 || currentTabIndex === 3) ? "transparent" : "#f4f4f4"

                // 历史记录区域
                ColumnLayout {
                    width: parent.width
                    spacing: 0
                    visible: currentTabIndex === 0 && !showFollowingList && !showFollowerList

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        color: "transparent"
                        visible: isHistoryEmpty

                        Column {
                            anchors.centerIn: parent
                            spacing: 20
                            opacity: 0.5

                            Text {
                                text: "📺"
                                font.pixelSize: 40
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "还没有观看记录哦"
                                font.pixelSize: 16
                                color: "#999"
                            }

                            Text {
                                text: "快去发现精彩内容吧～"
                                font.pixelSize: 12
                                color: "#999"
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 0
                        visible: !isHistoryEmpty

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: "#fafafa"

                            Text {
                                anchors {
                                    left: parent.left
                                    leftMargin: 20
                                    verticalCenter: parent.verticalCenter
                                }
                                text: "今天"
                                font.pixelSize: 14
                                color: "#666"
                            }
                        }

                        ListView {
                            id: historyListView
                            Layout.fillWidth: true
                            Layout.preferredHeight: childrenRect.height
                            clip: true
                            model: historyModel
                            interactive: false

                            delegate: Rectangle {
                                id: historyItem
                                width: historyListView.width
                                height: 80
                                color: selectedHistoryIndex === index ? "#fff0f0" : "white"

                                Rectangle {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        bottom: parent.bottom
                                        margins: 0
                                    }
                                    height: 1
                                    color: "#f0f0f0"
                                    visible: index !== historyModel.count - 1
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 15

                                    Rectangle {
                                        Layout.preferredWidth: 120
                                        Layout.preferredHeight: 70
                                        color: "#e0e0e0"
                                        radius: 4

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            width: parent.width
                                            height: 3
                                            color: "#e0e0e0"

                                            Rectangle {
                                                width: parent.width * 0.3
                                                height: parent.height
                                                color: "#FB7299"
                                            }
                                        }

                                        Rectangle {
                                            anchors {
                                                right: parent.right
                                                bottom: parent.bottom
                                                margins: 5
                                            }
                                            width: durationText.width + 8
                                            height: durationText.height + 4
                                            color: "#99000000"
                                            radius: 2

                                            Text {
                                                id: durationText
                                                anchors.centerIn: parent
                                                text: duration.split("/")[1]
                                                color: "white"
                                                font.pixelSize: 10
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 5

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 10

                                            Text {
                                                Layout.fillWidth: true
                                                text: title
                                                font.pixelSize: 14
                                                elide: Text.ElideRight
                                                color: selectedHistoryIndex === index ? "#FB7299" : "#333"
                                            }

                                            Text {
                                                text: time
                                                font.pixelSize: 12
                                                color: "#999"
                                            }
                                        }

                                        Text {
                                            text: author || up || "UP主"
                                            font.pixelSize: 12
                                            color: "#666"
                                            visible: text !== ""
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 15

                                            Text {
                                                text: duration
                                                font.pixelSize: 12
                                                color: "#999"
                                            }

                                            Rectangle {
                                                visible: badge
                                                width: badgeText.width + 8
                                                height: badgeText.height + 4
                                                color: "#f0f0f0"
                                                radius: 2

                                                Text {
                                                    id: badgeText
                                                    anchors.centerIn: parent
                                                    text: badge || ""
                                                    font.pixelSize: 10
                                                    color: "#999"
                                                }
                                            }

                                            Item { Layout.fillWidth: true }
                                        }
                                    }
                                }

                                TapHandler {
                                    onTapped: {
                                        selectedHistoryIndex = index
                                        console.log("点击历史记录:", title)
                                    }
                                }
                            }
                        }
                    }
                }

                // 离线缓存、稍后再看区域
                ColumnLayout {
                    width: parent.width
                    spacing: 0
                    visible: (currentTabIndex === 1 || currentTabIndex === 3) && !showFollowingList && !showFollowerList

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        color: "transparent"

                        Column {
                            anchors.centerIn: parent
                            spacing: 15
                            opacity: 0.6

                            Text {
                                text: {
                                    switch(currentTabIndex) {
                                    case 1: return "📥";
                                    case 3: return "⏱️";
                                    default: return "📺";
                                    }
                                }
                                font.pixelSize: 40
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: {
                                    switch(currentTabIndex) {
                                    case 1: return "离线缓存功能";
                                    case 3: return "稍后再看功能";
                                    default: return "功能区域";
                                    }
                                }
                                font.pixelSize: 16
                                color: "#666"
                            }

                            Text {
                                text: {
                                    switch(currentTabIndex) {
                                    case 1: return "此功能暂未实现";
                                    case 3: return "此功能暂未实现";
                                    default: return "请选择其他功能";
                                    }
                                }
                                font.pixelSize: 12
                                color: "#999"
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
            }
        }
    }

    // 关注列表 - 覆盖整个右侧区域
    Rectangle {
        id: followingListContainer
        anchors.fill: parent
        visible: showFollowingList
        color: "#FFFFFF"
        z: 10

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 列表头部
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#F8F9FA"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 15

                    Button {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 36
                        text: "← 返回"
                        background: Rectangle {
                            color: parent.down ? "#e0e0e0" : "transparent"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#333333"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            closeAllLists();
                        }
                    }

                    Text {
                        text: "关注列表"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333333"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "共 " + followingList.count + " 人"
                        font.pixelSize: 14
                        color: "#666666"
                    }
                }
            }

            // 列表内容
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: followingList
                    anchors.fill: parent
                    model: followingListModel
                    spacing: 1

                    delegate: Rectangle {
                        width: followingList.width
                        height: 80
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15

                            // 用户头像
                            Rectangle {
                                width: 50
                                height: 50
                                radius: 25
                                color: "#FF6699"

                                Text {
                                    anchors.centerIn: parent
                                    text: model.nickname ? model.nickname.charAt(0).toUpperCase() : "?"
                                    color: "white"
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                            }

                            // 用户信息
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5

                                Text {
                                    text: model.nickname || "未知用户"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333333"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: model.sign || "这个用户很懒，什么都没有写"
                                    font.pixelSize: 14
                                    color: "#666666"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            // 取消关注按钮
                            Button {
                                text: "取消关注"
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 36

                                background: Rectangle {
                                    color: parent.down ? "#CCCCCC" : "#E0E0E0"
                                    radius: 18
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "#666666"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    // 模拟取消关注效果
                                    mockUnfollowUser(model.account);
                                    // 直接从列表中移除该项
                                    followingList.model.remove(index);
                                }
                            }


                        }

                        // 分隔线
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: "#F0F0F0"
                        }
                    }

                    // 空状态
                    Rectangle {
                        width: followingList.width
                        height: 200
                        visible: followingList.count === 0
                        color: "transparent"

                        Column {
                            anchors.centerIn: parent
                            spacing: 15

                            Text {
                                text: "👥"
                                font.pixelSize: 48
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "还没有关注任何人"
                                font.pixelSize: 16
                                color: "#999999"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "去发现有趣的内容和UP主吧"
                                font.pixelSize: 14
                                color: "#CCCCCC"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
        }
    }

    // 粉丝列表 - 覆盖整个右侧区域
    Rectangle {
        id: followerListContainer
        anchors.fill: parent
        visible: showFollowerList
        color: "#FFFFFF"
        z: 10

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 列表头部
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#F8F9FA"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 15

                    Button {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 36
                        text: "← 返回"
                        background: Rectangle {
                            color: parent.down ? "#e0e0e0" : "transparent"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#333333"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            closeAllLists();
                        }
                    }

                    Text {
                        text: "粉丝列表"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333333"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "共 " + followerList.count + " 人"
                        font.pixelSize: 14
                        color: "#666666"
                    }
                }
            }

            // 列表内容
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: followerList
                    anchors.fill: parent
                    model: followerListModel
                    spacing: 1

                    delegate: Rectangle {
                        width: followerList.width
                        height: 80
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15

                            // 用户头像
                            Rectangle {
                                width: 50
                                height: 50
                                radius: 25
                                color: "#2196F3"

                                Text {
                                    anchors.centerIn: parent
                                    text: model.nickname ? model.nickname.charAt(0).toUpperCase() : "?"
                                    color: "white"
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                            }

                            // 用户信息
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5

                                Text {
                                    text: model.nickname || "未知用户"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333333"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: model.sign || "这个用户很懒，什么都没有写"
                                    font.pixelSize: 14
                                    color: "#666666"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            // 关注/回关按钮
                            Button {
                                id: followBackBtn
                                property bool isFollowing: false

                                text: isFollowing ? "已关注" : "回关"
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 36

                                background: Rectangle {
                                    color: followBackBtn.isFollowing ?
                                           (parent.down ? "#CCCCCC" : "#E0E0E0") :
                                           (parent.down ? "#FF5252" : "#FF6699")
                                    radius: 18
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: followBackBtn.isFollowing ? "#666666" : "white"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    if (isFollowing) {
                                        // 模拟取消关注
                                        mockUnfollowUser(model.account);
                                        isFollowing = false;
                                    } else {
                                        // 模拟关注
                                        mockFollowUser(model.account);
                                        isFollowing = true;
                                    }
                                }
                            }
                        }

                        // 分隔线
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: "#F0F0F0"
                        }
                    }

                    // 空状态
                    Rectangle {
                        width: followerList.width
                        height: 200
                        visible: followerList.count === 0
                        color: "transparent"

                        Column {
                            anchors.centerIn: parent
                            spacing: 15

                            Text {
                                text: "👥"
                                font.pixelSize: 48
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "还没有粉丝"
                                font.pixelSize: 16
                                color: "#999999"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "发布优质内容来吸引粉丝吧"
                                font.pixelSize: 14
                                color: "#CCCCCC"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
        }
    }

    // 组件初始化
    Component.onCompleted: {
        console.log("个人信息页面初始化完成")
        console.log("当前头像URL:", avatarUrl)
        console.log("全局头像URL:", root.globalAvatarUrl)

        // 初始化历史记录状态
        isHistoryEmpty = historyModel.count === 0
        // 加载模拟数据
        loadMockFollowingData()
        loadMockFollowerData()
        // 初始化收藏夹视频数量
        updateGroupVideoCount()
    }

    // 监听全局头像URL变化
    Connections {
        target: root
        function onGlobalAvatarUrlChanged() {
            console.log("全局头像URL变化:", root.globalAvatarUrl)
            avatarUrl = root.globalAvatarUrl
        }
    }

    // 监听登录状态变化
    Connections {
        target: root
        function onIsLoggedInChanged() {
            console.log("登录状态变化:", root.isLoggedIn)
            if (!root.isLoggedIn) {
                // 用户登出时关闭关注/粉丝列表
                closeAllLists()
            }
        }
    }
}
