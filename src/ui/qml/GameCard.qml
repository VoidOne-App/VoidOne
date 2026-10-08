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
    property bool compact: false
    property bool favorite: false
    property int playCount: 0
    property string source: ""
    signal detailsRequested()

    signal launchRequested(string path)

    radius: 16
    color: hoverArea.containsMouse ? "#111d29" : "#0c131b"
    border.color: hoverArea.containsMouse ? "#00e5ff66" : "#172533"
    border.width: 1

    scale: hoverArea.containsMouse ? 1.018 : 1.0
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    layer.enabled: hoverArea.containsMouse
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#00e5ff"
        shadowBlur: 0.22
        shadowOpacity: 0.25
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 2
        radius: 1
        color: hoverArea.containsMouse ? "#00e5ff" : "#00e5ff20"
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onDoubleClicked: cardRoot.launchRequested(cardRoot.exePath)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: compact ? 13 : 16
        spacing: compact ? 8 : 11

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: compact ? 34 : 40
                height: width
                radius: compact ? 9 : 11
                color: "#00e5ff10"
                border.color: "#00e5ff22"

                Image {
                    anchors.centerIn: parent
                    width: parent.width * 0.48
                    height: width
                    source: "qrc:/qt/qml/VoidOne.App/assets/branding/voidone-mark.svg"
                    fillMode: Image.PreserveAspectFit
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: gameName
                    color: "#eaf2f7"
                    font.pixelSize: compact ? 13 : 15
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    text: platform
                    color: "#506477"
                    font.pixelSize: 9
                    font.bold: true
                }
            }

            Text { visible: cardRoot.favorite; text: "★"; color: "#00e5ff"; font.pixelSize: 13 }

            ToolButton {
                implicitWidth: 26
                implicitHeight: 26
                text: "⋯"
                onClicked: cardRoot.detailsRequested()
                background: Rectangle {
                    radius: 8
                    color: parent.hovered ? "#ff5f7018" : "transparent"
                }
                contentItem: Text {
                    text: parent.text
                    color: "#53697c"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Item { Layout.fillHeight: true }

        Text {
            visible: !compact
            Layout.fillWidth: true
            text: exePath
            color: "#405467"
            font.pixelSize: 9
            elide: Text.ElideMiddle
        }

        Button {
            Layout.fillWidth: true
            implicitHeight: compact ? 34 : 38
            text: qsTr("Play")
            onClicked: cardRoot.launchRequested(cardRoot.exePath)

            background: Rectangle {
                radius: 9
                color: parent.pressed ? "#00b8ce" : (parent.hovered ? "#19eaff" : "#00d8ef")
            }

            contentItem: RowLayout {
                spacing: 7
                Item { Layout.fillWidth: true }
                Text {
                    text: "▶"
                    color: "#041015"
                    font.pixelSize: 10
                    font.bold: true
                }
                Text {
                    text: qsTr("Play")
                    color: "#041015"
                    font.pixelSize: 11
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
            }
        }
    }
}
