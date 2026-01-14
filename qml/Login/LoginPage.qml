import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UserApp 1.0

Item {
    id: container
    width: 450
    height: 800

    // 添加 UserController 属性
    //property var userController

    function open() {
        loginDialog.open()
    }

    function close() {
        loginDialog.close()
    }

    // 登录对话框
    Popup {
        id: loginDialog
        width: 450
        height: 800
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property bool isLoggedIn: false
        property string username: ""
        property string avatarUrl: "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"

        signal loginSuccess(string username, string avatarUrl, string userAccount)
        signal logout()

        background: Rectangle {
            color: "white"
            radius: 12
            border.color: "#e0e0e0"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "登录A站"
                font.pixelSize: 24
                font.bold: true
                color: "#FB7299"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "精彩视频等你来看"
                font.pixelSize: 16
                color: "#999"
            }

            Item {
                Layout.preferredHeight: 10
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "账号"
                    font.pixelSize: 14
                    color: "#666"
                }

                TextField {
                    id: accountField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    placeholderText: "请输入账号"
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "#f8f8f8"
                        radius: 8
                        border.color: accountField.focus ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "密码"
                    font.pixelSize: 14
                    color: "#666"
                }

                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    placeholderText: "请输入密码"
                    echoMode: TextField.Password
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "#f8f8f8"
                        radius: 8
                        border.color: passwordField.focus ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: rememberCheckbox
                    text: "记住密码"
                    font.pixelSize: 12
                    checked: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "忘记密码？"
                    flat: true
                    font.pixelSize: 12
                    contentItem: Text {
                        text: parent.text
                        color: "#00A1D6"
                        font: parent.font
                    }
                    background: Item {}

                    onClicked: {
                        console.log("打开忘记密码对话框")
                        loginDialog.close()
                        forgotPasswordDialog.open()
                    }
                }
            }

            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                text: "登录"

                background: Rectangle {
                    color: loginButton.enabled ? "#FB7299" : "#FFB5C8"
                    radius: 8
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (accountField.text && passwordField.text) {
                        loginButton.enabled = false
                        loginButton.text = "登录中..."

                        // 使用 UserController 登录
                        userController.login(accountField.text, passwordField.text)

                        // 重置按钮状态
                        Qt.callLater(function() {
                            loginButton.enabled = true
                            loginButton.text = "登录"
                        })
                    } else {
                        errorMessage.text = "请输入账号和密码"
                        errorMessage.visible = true
                    }
                }
            }

            Text {
                id: errorMessage
                Layout.alignment: Qt.AlignHCenter
                visible: false
                text: ""
                color: "#ff4757"
                font.pixelSize: 12
            }

            // 分隔线
            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#e0e0e0"
                }

                Text {
                    text: "其他登录方式"
                    font.pixelSize: 12
                    color: "#999"
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#e0e0e0"
                }
            }

            // 第三方登录
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                Button {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    background: Rectangle {
                        color: "transparent"
                        radius: 25

                        Text {
                            anchors.centerIn: parent
                            text: "📱"
                            font.pixelSize: 24
                        }
                    }

                    onClicked: console.log("手机验证码登录")
                }

                Button {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    background: Rectangle {
                        color: "transparent"
                        radius: 25

                        Text {
                            anchors.centerIn: parent
                            text: "💬"
                            font.pixelSize: 24
                        }
                    }

                    onClicked: console.log("扫码登录")
                }

                Button {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    background: Rectangle {
                        color: "transparent"
                        radius: 25

                        Text {
                            anchors.centerIn: parent
                            text: "🐧"
                            font.pixelSize: 24
                        }
                    }

                    onClicked: console.log("QQ登录")
                }
            }

            // 注册链接
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                Text {
                    text: "还没有账号？"
                    font.pixelSize: 12
                    color: "#999"
                }

                Button {
                    text: "立即注册"
                    flat: true
                    font.pixelSize: 12
                    contentItem: Text {
                        text: parent.text
                        color: "#00A1D6"
                        font: parent.font
                    }
                    background: Item {}

                    onClicked: {
                        console.log("打开注册对话框")
                        loginDialog.close()
                        registerDialog.open()
                    }
                }
            }

            // 底部说明文字
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "登录即表示同意《用户协议》和《隐私政策》"
                font.pixelSize: 10
                color: "#999"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Button {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            width: 30
            height: 30
            padding: 0
            background: Rectangle {
                color: parent.hovered ? "#f0f0f0" : "transparent"
                radius: 15
            }

            contentItem: Text {
                text: "×"
                font.pixelSize: 18
                font.bold: true
                color: "#666"
                anchors.centerIn: parent
            }

            onClicked: loginDialog.close()
        }
    }

    // 注册对话框
    Popup {
        id: registerDialog
        width: 450
        height: 650
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "white"
            radius: 12
            border.color: "#e0e0e0"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 15

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "注册bilibili账号"
                font.pixelSize: 24
                font.bold: true
                color: "#FB7299"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "加入我们，发现更多精彩内容"
                font.pixelSize: 14
                color: "#999"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "账号"
                    font.pixelSize: 14
                    color: "#666"
                }

                TextField {
                    id: registerAccount
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    placeholderText: "请输入账号"
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "#f8f8f8"
                        radius: 8
                        border.color: registerAccount.focus ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "昵称"
                    font.pixelSize: 14
                    color: "#666"
                }

                TextField {
                    id: registerNickname
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    placeholderText: "请输入昵称"
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "#f8f8f8"
                        radius: 8
                        border.color: registerNickname.focus ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "密码"
                    font.pixelSize: 14
                    color: "#666"
                }

                TextField {
                    id: registerPassword
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    placeholderText: "请输入密码"
                    echoMode: TextField.Password
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "#f8f8f8"
                        radius: 8
                        border.color: registerPassword.focus ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "确认密码"
                    font.pixelSize: 14
                    color: "#666"
                }

                TextField {
                    id: registerConfirmPassword
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    placeholderText: "请再次输入密码"
                    echoMode: TextField.Password
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "#f8f8f8"
                        radius: 8
                        border.color: registerConfirmPassword.focus ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }

            CheckBox {
                id: agreeTerms
                text: "我已阅读并同意《用户协议》和《隐私政策》"
                font.pixelSize: 12
            }

            Button {
                id: registerButton
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                text: "注册"
                enabled: agreeTerms.checked

                background: Rectangle {
                    color: registerButton.enabled ? "#FB7299" : "#FFB5C8"
                    radius: 8
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (!registerAccount.text) {
                        registerError.text = "请输入账号"
                        registerError.visible = true
                        return
                    }
                    if (!registerNickname.text) {
                        registerError.text = "请输入昵称"
                        registerError.visible = true
                        return
                    }
                    if (!registerPassword.text) {
                        registerError.text = "请输入密码"
                        registerError.visible = true
                        return
                    }
                    if (registerPassword.text !== registerConfirmPassword.text) {
                        registerError.text = "两次输入的密码不一致"
                        registerError.visible = true
                        return
                    }

                    registerButton.enabled = false
                    registerButton.text = "注册中..."

                    // 使用 UserController 注册用户
                    userController.registerUser(
                        registerAccount.text,
                        registerPassword.text,
                        registerNickname.text
                    )

                    // 重置按钮状态
                    Qt.callLater(function() {
                        registerButton.enabled = true
                        registerButton.text = "注册"
                    })
                }
            }

            Text {
                id: registerError
                Layout.alignment: Qt.AlignHCenter
                visible: false
                text: ""
                color: "#ff4757"
                font.pixelSize: 12
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "返回登录"
                background: Rectangle {
                    color: "#f0f0f0"
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: "#666"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    registerDialog.close()
                    loginDialog.open()
                }
            }
        }

        Button {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            width: 30
            height: 30
            padding: 0
            background: Rectangle {
                color: parent.hovered ? "#f0f0f0" : "transparent"
                radius: 15
            }

            contentItem: Text {
                text: "×"
                font.pixelSize: 18
                font.bold: true
                color: "#666"
                anchors.centerIn: parent
            }

            onClicked: registerDialog.close()
        }
    }

    // 忘记密码对话框
    Popup {
        id: forgotPasswordDialog
        width: 420
        height: 450
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "white"
            radius: 12
            border.color: "#e0e0e0"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "找回密码"
                font.pixelSize: 22
                font.bold: true
                color: "#FB7299"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "请输入注册时使用的账号"
                font.pixelSize: 14
                color: "#666"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "账号"
                    font.pixelSize: 14
                    color: "#666"
                }

                TextField {
                    id: recoveryAccount
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    placeholderText: "请输入账号"
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "#f8f8f8"
                        radius: 8
                        border.color: recoveryAccount.focus ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                text: "重置密码"

                background: Rectangle {
                    color: "#FB7299"
                    radius: 8
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (!recoveryAccount.text) {
                        passwordError.text = "请输入账号"
                        passwordError.visible = true
                        return
                    }

                    // TODO: 实现密码重置逻辑
                    passwordError.text = "密码重置功能开发中..."
                    passwordError.color = "#ff4757"
                    passwordError.visible = true

                    // 模拟处理
                    resetTimer.start()
                }
            }

            Text {
                id: passwordError
                Layout.alignment: Qt.AlignHCenter
                visible: false
                text: ""
                color: "#ff4757"
                font.pixelSize: 12
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "返回登录"
                background: Rectangle {
                    color: "#f0f0f0"
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: "#666"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    forgotPasswordDialog.close()
                    loginDialog.open()
                }
            }
        }

        Timer {
            id: resetTimer
            interval: 2000
            onTriggered: {
                passwordError.text = "请通过其他方式联系管理员重置密码"
                passwordError.visible = true
            }
        }

        Timer {
            id: closeTimer
            interval: 1500
            onTriggered: {
                forgotPasswordDialog.close()
                passwordError.visible = false
                // 清空表单
                recoveryAccount.text = ""
            }
        }

        Button {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            width: 30
            height: 30
            padding: 0
            background: Rectangle {
                color: parent.hovered ? "#f0f0f0" : "transparent"
                radius: 15
            }

            contentItem: Text {
                text: "×"
                font.pixelSize: 18
                font.bold: true
                color: "#666"
                anchors.centerIn: parent
            }

            onClicked: forgotPasswordDialog.close()
        }
    }

    // 监听 UserController 的信号
    Connections {
        target: userController

        // 登录成功
        function onLoginSuccess(userId) {
            console.log("✅ 登录成功，用户ID:", userId)

            // 获取用户信息
            var user = userController.currentUser
            if (user && user.id) {
                var username = user.nickname || "用户"
                var avatarUrl = user.avatarUrl || "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"
                var userAccount = user.account || ""

                // 触发登录成功信号
                loginDialog.loginSuccess(username, avatarUrl, userAccount)
                errorMessage.visible = false

                console.log("✅ 用户信息:", username, userAccount)
                loginDialog.close()
            }
        }

        // 注册成功
        function onRegistrationSuccess(userId) {
            console.log("✅ 注册成功，用户ID:", userId)
            registerError.text = "注册成功！请登录"
            registerError.color = "#52c41a"
            registerError.visible = true

            // 1秒后自动返回登录页面
            backToLoginTimer.start()
        }

        // 错误处理
        function onErrorOccurred(message) {
            console.log("❌ 错误:", message)

            if (loginDialog.opened) {
                errorMessage.text = message
                errorMessage.visible = true
            } else if (registerDialog.opened) {
                registerError.text = message
                registerError.visible = true
            }
        }
    }

    Timer {
        id: backToLoginTimer
        interval: 1000
        onTriggered: {
            registerDialog.close()
            loginDialog.open()
            // 清空注册表单
            registerAccount.text = ""
            registerNickname.text = ""
            registerPassword.text = ""
            registerConfirmPassword.text = ""
        }
    }

    // 暴露信号给外部
    signal loginSuccess(string username, string avatarUrl, string userAccount)
    signal logout()

    // 转发内部信号
    Connections {
        target: loginDialog

        function onLoginSuccess(username, avatarUrl, userAccount) {
            container.loginSuccess(username, avatarUrl, userAccount)
        }

        function onLogout() {
            container.logout()
        }
    }
}
