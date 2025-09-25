import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    spacing: 20
    Repeater {
        model: ["历史记录", "离线缓存", "我的收藏", "稍后再看"]
        delegate: Text {
            text: modelData
            font.pixelSize: 14
            color: index === 0 ? "red" : "gray" // 第一个标签高亮
        }
    }
}
