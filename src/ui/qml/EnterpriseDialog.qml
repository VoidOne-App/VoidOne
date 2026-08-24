import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: dialogRoot
    anchors.fill: parent
    color: "#b005070a"
    visible: false
    z: 100

    signal confirmed()
    signal cancelled()

    function openDialog(titleText, descText) {
        titleLabel.text = titleText
        descLabel.text = descText
        dialogRoot.visible = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {} // جلوگیری از کلیک روی لایه‌های زیرین
    }

    Rectangle {
        width: 380
        height: 170
        anchors.centerIn: parent
        color: "#0f141d"
        radius: 12
        border.color: "#00f0ff"
        border.width: 1.5

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            Text {
                id: titleLabel
                text: "Alert"
                color: "#f8fafc"
                font.pixelSize: 15
                font.bold: true
            }

            Text {
                id: descLabel
                Layout.fillWidth: true
                text: "Message..."
                color: "#64748b"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                Button {
                    text: "Cancel"
                    onClicked: {
                        dialogRoot.visible = false
                        dialogRoot.cancelled()
                    }
                }

                Button {
                    text: "Confirm"
                    onClicked: {
                        dialogRoot.visible = false
                        dialogRoot.confirmed()
                    }
                }
            }
        }
    }
}
