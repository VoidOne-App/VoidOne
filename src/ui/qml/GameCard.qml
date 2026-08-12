import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: cardRoot
    required property int gameId
    required property string gameName
    required property string exePath
    required property string iconPath
    required property string platform
    required property int itemIndex

    width: 280
    height: 190
    radius: 16
    color: "#111827"
    border.color: hoverArea.containsMouse ? "#00ffee" : "#00ffee40"
    border.width: hoverArea.containsMouse ? 2 : 1

    Behavior on border.color { ColorAnimation { duration: 150 } }

    layer.enabled: hoverArea.containsMouse
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#00ffee"
        shadowBlur: 0.4
        shadowScale: 1.02
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: scaleAnim.to = 1.02
        onExited: scaleAnim.to = 1.0
    }

    NumberAnimation on scale {
        id: scaleAnim
        duration: 120
        easing.type: Easing.OutQuad
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Rectangle {
                width: 32
                height: 32
                radius: 8
                color: "#00ffee20"
                Text {
                    anchors.centerIn: parent
                    text: platform === "Steam" ? "🎮" : "⚙️"
                    font.pixelSize: 16
                }
            }

            Text {
                Layout.fillWidth: true
                text: gameName
                color: "#00ffee"
                font.pixelSize: 16
                font.bold: true
                elide: Text.ElideRight
            }

            // دکمه حذف بازی
            Button {
                implicitWidth: 28
                implicitHeight: 28
                background: Rectangle { color: "transparent" }
                contentItem: Text { text: "🗑️"; font.pixelSize: 12 }
                onClicked: gameModel.deleteGame(gameId, itemIndex)
            }
        }

        Item { Layout.fillHeight: true }

        // دکمه اجرای بازی
        Button {
            Layout.fillWidth: true
            height: 38
            background: Rectangle {
                color: parent.pressed ? "#00cccc" : "#00ffee"
                radius: 8
            }
            contentItem: RowLayout {
                spacing: 8
                Item { Layout.fillWidth: true }
                Text { text: "▶"; color: "#111827"; font.bold: true }
                Text {
                    text: trManager.getText("launch")
                    color: "#111827"
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
            }
            onClicked: gameModel.launchGame(exePath)
        }
    }
}
