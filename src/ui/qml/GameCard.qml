import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
    property double lastPlayed: 0
    property string source: ""

    signal detailsRequested()
    signal launchRequested(string path)

    function iconUrl(path) {
        if (!path || path.length === 0)
            return "qrc:/qt/qml/VoidOne/App/assets/branding/voidone-mark.svg"
        if (path.startsWith("qrc:/") || path.startsWith("file:/") || path.startsWith("http://") || path.startsWith("https://"))
            return path
        if (path.startsWith(":/"))
            return "qrc" + path
        if (path.startsWith("/"))
            return "file://" + path
        return "file:///" + path.replace(/\\/g, "/")
    }

    implicitHeight: compact ? 164 : 190
    radius: 14
    color: cardHover.hovered ? "#111e2a" : "#0c141d"
    border.color: cardHover.hovered ? "#00e5ff65" : "#1a2a39"
    border.width: 1
    clip: true

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    HoverHandler {
        id: cardHover
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 2
        color: cardHover.hovered ? "#00e5ff" : "#00e5ff20"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: compact ? 12 : 15
        spacing: compact ? 9 : 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 11

            Rectangle {
                Layout.preferredWidth: compact ? 48 : 58
                Layout.preferredHeight: compact ? 48 : 58
                radius: 13
                color: "#071019"
                border.color: "#243746"
                clip: true

                Image {
                    id: gameIcon
                    anchors.centerIn: parent
                    width: parent.width * 0.78
                    height: width
                    source: cardRoot.iconUrl(cardRoot.iconPath)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    visible: status === Image.Ready
                }

                Image {
                    anchors.centerIn: parent
                    width: parent.width * 0.62
                    height: width
                    source: "qrc:/qt/qml/VoidOne/App/assets/branding/voidone-mark.svg"
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    visible: gameIcon.status !== Image.Ready
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: cardRoot.gameName
                    color: "#edf5fa"
                    font.pixelSize: compact ? 13 : 14
                    font.bold: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    Layout.fillWidth: true
                    text: (cardRoot.platform || qsTr("Local")) + (cardRoot.source.length ? "  ·  " + cardRoot.source : "")
                    color: "#70869a"
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: cardRoot.playCount > 0
                          ? qsTr("%1 launches").arg(cardRoot.playCount)
                          : qsTr("Not launched yet")
                    color: "#4f667a"
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }

                Text {
                    visible: !cardRoot.compact && cardRoot.lastPlayed > 0
                    Layout.fillWidth: true
                    text: qsTr("Last played · %1").arg(Qt.formatDateTime(new Date(cardRoot.lastPlayed * 1000), "MMM d, h:mm AP"))
                    color: "#5d7488"
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }
            }

            ToolButton {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                text: cardRoot.favorite ? "★" : "☆"
                onClicked: {
                    if (typeof gameModel !== "undefined" && gameModel !== null)
                        gameModel.setFavorite(cardRoot.gameId, !cardRoot.favorite)
                }
                ToolTip.visible: hovered
                ToolTip.text: cardRoot.favorite ? qsTr("Remove from favorites") : qsTr("Add to favorites")
                background: Rectangle {
                    radius: 8
                    color: parent.hovered ? "#00e5ff14" : "transparent"
                }
                contentItem: Text {
                    text: parent.text
                    color: cardRoot.favorite ? "#00e5ff" : "#6f8395"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                Layout.fillWidth: true
                implicitHeight: 36
                text: qsTr("Play")
                onClicked: cardRoot.launchRequested(cardRoot.exePath)
                background: Rectangle {
                    radius: 9
                    color: parent.down ? "#00b8ce" : (parent.hovered ? "#20eaff" : "#00d8ef")
                }
                contentItem: RowLayout {
                    spacing: 7
                    Item { Layout.fillWidth: true }
                    Text { text: "▶"; color: "#041015"; font.pixelSize: 9; font.bold: true }
                    Text { text: parent.parent.text; color: "#041015"; font.pixelSize: 11; font.bold: true }
                    Item { Layout.fillWidth: true }
                }
            }

            Button {
                implicitWidth: 40
                implicitHeight: 36
                text: "···"
                onClicked: cardRoot.detailsRequested()
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Game details")
                background: Rectangle {
                    radius: 9
                    color: parent.hovered ? "#152635" : "#0a1118"
                    border.color: "#263a4b"
                }
                contentItem: Text {
                    text: parent.text
                    color: "#a5b7c6"
                    font.pixelSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
