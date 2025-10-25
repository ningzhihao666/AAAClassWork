import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: container
    width: 450  // 增加宽度
    height: 800 // 增加高度

    // 登录对话框
    Popup {
        id: loginDialog
        width: 450  // 增加宽度
        height: 800 // 增加高度
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property bool isLoggedIn: false
        property string username: ""
        property string avatarUrl: "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp"

        signal loginSuccess(string username, string avatarUrl)
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
                text: "登录bilibili"
                font.pixelSize: 24  // 增大字体
                font.bold: true
                color: "#FB7299"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "精彩视频等你来看"
                font.pixelSize: 16  // 增大字体
                color: "#999"
            }

            Item {
                Layout.preferredHeight: 10  // 减少间距
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "用户名/手机号"
                    font.pixelSize: 14  // 增大字体
                    color: "#666"
                }

                TextField {
                    id: usernameField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46  // 增加高度
                    placeholderText: "请输入用户名或手机号"
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "#f8f8f8"
                        radius: 8
                        border.color: usernameField.focus ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "密码"
                    font.pixelSize: 14  // 增大字体
                    color: "#666"
                }

                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46  // 增加高度
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
                Layout.preferredHeight: 46  // 增加高度
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
                    if (usernameField.text && passwordField.text) {
                        loginButton.enabled = false
                        loginTimer.start()
                    } else {
                        errorMessage.text = "请输入用户名和密码"
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

            // 注册链接 - 现在在分隔线和第三方登录下面
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
                        font.bold: true
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

        Timer {
            id: loginTimer
            interval: 1500
            onTriggered: {
                var loginUsername = usernameField.text || "B站用户"
                var loginAvatarUrl = "https://i2.hdslb.com/bfs/face/5d35a39f7e8a8b7e17d2e0a0a0a0a0a0a0a0a0.jpg@40w_40h.webp"

                loginDialog.loginSuccess(loginUsername, loginAvatarUrl)

                loginButton.enabled = true
                errorMessage.visible = false

                console.log("登录成功:", loginUsername)
                loginDialog.close()
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

    // 注册对话框 - 也相应增大
    Popup {
        id: registerDialog
        width: 450  // 增加宽度
        height: 650 // 增加高度
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
                font.pixelSize: 24  // 增大字体
                font.bold: true
                color: "#FB7299"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "加入我们，发现更多精彩内容"
                font.pixelSize: 14  // 增大字体
                color: "#999"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "用户名"
                    font.pixelSize: 14  // 增大字体
                    color: "#666"
                }

                TextField {
                    id: registerUsername
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    placeholderText: "请输入用户名"
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "#f8f8f8"
                        radius: 8
                        border.color: registerUsername.focus ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "手机号"
                    font.pixelSize: 14  // 增大字体
                    color: "#666"
                }

                TextField {
                    id: registerPhone
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    placeholderText: "请输入手机号"
                    font.pixelSize: 14
                    inputMethodHints: Qt.ImhDigitsOnly

                    background: Rectangle {
                        color: "#f8f8f8"
                        radius: 8
                        border.color: registerPhone.focus ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "密码"
                    font.pixelSize: 14  // 增大字体
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
                    font.pixelSize: 14  // 增大字体
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
                Layout.preferredHeight: 46  // 增加高度
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
                    if (!registerUsername.text) {
                        registerError.text = "请输入用户名"
                        registerError.visible = true
                        return
                    }
                    if (!registerPhone.text) {
                        registerError.text = "请输入手机号"
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
                    registerTimer.start()
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

        Timer {
            id: registerTimer
            interval: 2000
            onTriggered: {
                console.log("注册成功:", registerUsername.text)
                registerError.text = "注册成功！请登录"
                registerError.color = "#52c41a"
                registerError.visible = true

                // 自动跳转到登录
                backToLoginTimer.start()
            }
        }

        Timer {
            id: backToLoginTimer
            interval: 1000
            onTriggered: {
                registerDialog.close()
                loginDialog.open()
                // 自动填充注册的用户名
                usernameField.text = registerUsername.text
                registerError.visible = false
                registerButton.enabled = true

                // 清空注册表单
                registerUsername.text = ""
                registerPhone.text = ""
                registerPassword.text = ""
                registerConfirmPassword.text = ""
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

    // 忘记密码对话框 - 也相应增大
    Popup {
        id: forgotPasswordDialog
        width: 420  // 增加宽度
        height: 450 // 增加高度
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
                font.pixelSize: 22  // 增大字体
                font.bold: true
                color: "#FB7299"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "请输入注册时使用的手机号或邮箱"
                font.pixelSize: 14  // 增大字体
                color: "#666"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "手机号/邮箱"
                    font.pixelSize: 14  // 增大字体
                    color: "#666"
                }

                TextField {
                    id: recoveryAccount
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    placeholderText: "请输入手机号或邮箱地址"
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "#f8f8f8"
                        radius: 8
                        border.color: recoveryAccount.focus ? "#FB7299" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "验证码"
                    font.pixelSize: 14  // 增大字体
                    color: "#666"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    TextField {
                        id: verificationCode
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        placeholderText: "请输入验证码"
                        font.pixelSize: 14

                        background: Rectangle {
                            color: "#f8f8f8"
                            radius: 8
                            border.color: verificationCode.focus ? "#FB7299" : "#e0e0e0"
                            border.width: 1
                        }
                    }

                    Button {
                        id: sendCodeButton
                        Layout.preferredWidth: 120  // 增加宽度
                        Layout.preferredHeight: 44
                        text: "发送验证码"

                        background: Rectangle {
                            color: sendCodeButton.enabled ? "#FB7299" : "#FFB5C8"
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            if (!recoveryAccount.text) {
                                passwordError.text = "请输入手机号或邮箱"
                                passwordError.visible = true
                                return
                            }

                            // 模拟发送验证码
                            sendCodeButton.enabled = false
                            countdownTimer.start()
                            passwordError.text = "验证码已发送，请注意查收"
                            passwordError.color = "#52c41a"
                            passwordError.visible = true
                        }
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 46  // 增加高度
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
                    if (!recoveryAccount.text || !verificationCode.text) {
                        passwordError.text = "请填写完整信息"
                        passwordError.visible = true
                        return
                    }

                    passwordError.text = "密码重置链接已发送到您的邮箱/手机"
                    passwordError.color = "#52c41a"
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
            id: countdownTimer
            interval: 1000
            repeat: true
            property int count: 60

            onTriggered: {
                count--
                sendCodeButton.text = count + "秒后重发"
                if (count <= 0) {
                    stop()
                    sendCodeButton.text = "发送验证码"
                    sendCodeButton.enabled = true
                    count = 60
                }
            }
        }

        Timer {
            id: resetTimer
            interval: 2000
            onTriggered: {
                passwordError.text = "密码重置成功！请使用新密码登录"
                passwordError.visible = true

                // 自动关闭
                closeTimer.start()
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
                verificationCode.text = ""
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

    // 初始化打开登录对话框
    Component.onCompleted: {
        loginDialog.open()
    }

    // 暴露信号给外部
    signal loginSuccess(string username, string avatarUrl)
    signal logout()

    // 转发内部信号
    Connections {
        target: loginDialog
        onLoginSuccess: container.loginSuccess(username, avatarUrl)
        onLogout: container.logout()
    }
}
