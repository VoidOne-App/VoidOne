import QtQuick
import QtQuick.Window

Window {
    id: root

    width: 1280
    height: 720

    minimumWidth: 960
    minimumHeight: 540

    visible: true

    title: "NeonLauncher"

    color: "#10131a"

    Rectangle {
        anchors.fill: parent
        color: "#10131a"

        Column {
            anchors.centerIn: parent
            spacing: 12

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: "NeonLauncher"

                font.pixelSize: 42
                font.bold: true

                color: "white"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: "Launcher is running."

                font.pixelSize: 18

                color: "#9aa4b2"
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter

                width: 180
                height: 48

                radius: 10

                color: "#5865f2"

                Text {
                    anchors.centerIn: parent

                    text: "READY"

                    font.pixelSize: 16
                    font.bold: true

                    color: "white"
                }
            }
        }
    }
}
