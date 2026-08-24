import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: musicWidget
    width: 170
    height: 38
    color: "#0f141d"
    radius: 19
    border.color: "#00f0ff"
    border.width: 1

    property bool isPlaying: false

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 10
        spacing: 8

        Button {
            id: playBtn
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            background: Rectangle {
                color: "#1a00f0ff"
                radius: 12
            }
            contentItem: Text {
                text: musicWidget.isPlaying ? "⏸" : "▶"
                color: "#00f0ff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignCenter
                font.pixelSize: 10
            }
            onClicked: {
                musicWidget.isPlaying = !musicWidget.isPlaying
            }
        }

        Text {
            Layout.fillWidth: true
            text: musicWidget.isPlaying ? "MZ — The Lost" : "Paused"
            color: "#f8fafc"
            font.pixelSize: 10
            elide: Text.ElideRight
        }
    }
}
