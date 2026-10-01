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

        ColumnLayout {
            spacing: 2
            Text {
                text: qsTr("RAM USAGE")
                color: "#64748b"
                font.pixelSize: 9
                font.bold: true
            }
            Text {
                text: qsTr("Telemetry unavailable")
                color: "#f8fafc"
                font.pixelSize: 11
                font.bold: true
            }
        }

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignRight
            Text {
                text: qsTr("CPU LOAD")
                color: "#64748b"
                font.pixelSize: 9
                font.bold: true
            }
            Text {
                text: qsTr("Telemetry unavailable")
                color: "#00f0ff"
                font.pixelSize: 11
                font.bold: true
            }
        }
    }
}
