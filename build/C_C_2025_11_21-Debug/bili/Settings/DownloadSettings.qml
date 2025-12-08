//下载设置

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Column {
    id: downloadSettings

    spacing: 15

    Text {
        text: "下载设置"
        font.bold: true
        font.pixelSize: 20
        color: "black"
    }

    // 视频离线缓存目录
    Column {
        width: parent.width
        spacing: 5

        Text {
            text: "视频离线缓存目录："
            color: "black"
        }

        Row {
            spacing: 10
            width: parent.width

            TextField {
                id: videoCachePath
                text: "C:\\Users\\Yang\\Videos\\bilibili"
                width: parent.width - 120
                readOnly: true
            }
            Button {
                text: "更改目录"
                width: 100
                onClicked: videoFolderDialog.open()
            }
        }

        Button {
            text: "恢复默认地址"
            onClicked: videoCachePath.text = "C:\\Users\\Yang\\Videos\\bilibili"
        }
    }

    Text {
        text: "同时缓存视频个数 1"
        color: "black"
    }

    // 游戏下载目录
    Column {
        width: parent.width
        spacing: 5

        Text {
            text: "游戏下载目录："
            color: "black"
        }

        Row {
            spacing: 10
            width: parent.width

            TextField {
                id: gameDownloadPath
                text: "D:\\BillGame"
                width: parent.width - 120
                readOnly: true
            }
            Button {
                text: "更改目录"
                width: 100
                onClicked: gameFolderDialog.open()
            }
        }

        Button {
            text: "恢复默认地址"
            onClicked: gameDownloadPath.text = "D:\\BillGame"
        }
    }

    CheckBox {
        text: "启动时自动继续下载"
        width: parent.width
        checked: true
    }
    CheckBox {
        text: "下载时电脑不休眠"
        width: parent.width
        checked: true
    }

    FolderDialog {
        id: videoFolderDialog
        title: "选择视频缓存目录"
        currentFolder: "file:///C:/Users/Yang/Videos"

        onAccepted: {//这几步是因为Windows的路径是“C:\..."
            var path = selectedFolder.toString()
            if (path.startsWith("file:///")) {
                path = path.substring(8) //移除前8个字符："file:///"
                path = path.replace(/\//g, "\\")// 将所有 / 替换为 \
            }
            videoCachePath.text = path
            console.log("视频缓存目录设置为:", path)
        }

        onRejected: {
            console.log("用户取消了目录选择")
        }
    }

    FolderDialog {
        id: gameFolderDialog
        title: "选择游戏下载目录"
        currentFolder: "file:///D:/"

        onAccepted: {
            var path = selectedFolder.toString()
            if (path.startsWith("file:///")) {
                path = path.substring(8)
                path = path.replace(/\//g, "\\")
            }
            gameDownloadPath.text = path
            console.log("游戏下载目录设置为:", path)
        }

        onRejected: {
            console.log("用户取消了目录选择")
        }
    }
}
