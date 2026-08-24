import QtQuick
import QtQuick.Layouts

Rectangle {
    width: 220
    height: 45
    color: "#0f141d"
    radius: 8
    border.color: "#1a00f0ff"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 15

        // RAM Usage Icon/Indicator
        ColumnLayout {
            spacing: 2
            Text { text: "RAM USAGE"; color: "#64748b"; font.pixelSize: 9; font.bold: true }
            Text { text: "4.2 GB / 12 GB"; color: "#f8fafc"; font.pixelSize: 11; font.bold: true }
        }

        // CPU Pulse
        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignRight
            Text { text: "CPU LOAD"; color: "#64748b"; font.pixelSize: 9; font.bold: true }
            Text { text: "14%"; color: "#00f0ff"; font.pixelSize: 11; font.bold: true }
        }
    }
}
