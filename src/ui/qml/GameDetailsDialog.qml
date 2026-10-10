import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: dialog
    modal: true
    anchors.centerIn: Overlay.overlay
    width: Math.min(760, Overlay.overlay ? Overlay.overlay.width - 40 : 760)
    height: Math.min(620, Overlay.overlay ? Overlay.overlay.height - 40 : 620)
    padding: 0

    property int gameId: -1
    property string gameName: ""
    property string exePath: ""
    property string iconPath: ""
    property string platform: ""
    property string source: ""
    property string workingDir: ""
    property string launchArgs: ""
    property int playCount: 0
    property bool favorite: false
    signal notificationRequested(string message, bool isError)

    function iconUrl(path) {
        if (!path || path.length === 0)
            return "qrc:/qt/qml/VoidOne.App/assets/branding/voidone-mark.svg"
        if (path.startsWith("qrc:/") || path.startsWith("file:/"))
            return path
        if (path.startsWith(":/"))
            return "qrc" + path
        if (path.startsWith("/"))
            return "file://" + path
        return "file:///" + path.replace(/\\/g, "/")
    }

    function openFor(id, name, exe, icon, plat, src, dir, args, count, fav) {
        gameId=id; gameName=name; exePath=exe; iconPath=icon; platform=plat; source=src; workingDir=dir
        launchArgs=args; playCount=count; favorite=fav
        argsField.text=args
        dirField.text=dir
        dialog.open()
    }

    background: Rectangle {
        radius: 22
        color: "#0b1118"
        border.color: "#233143"
        border.width: 1
        Rectangle {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: 3; radius: 2; color: "#00e5ff"
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: "#0d1721"
            radius: 22
            clip: true

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                width: 300; height: 300; radius: 150
                color: "#00e5ff08"
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                Rectangle {
                    width: 70; height: 70; radius: 17
                    color: "#00e5ff10"; border.color: "#00e5ff32"
                    Image {
                        id: detailsGameIcon
                        anchors.centerIn: parent
                        width: 48
                        height: 48
                        source: dialog.iconUrl(dialog.iconPath)
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        smooth: true
                        visible: status === Image.Ready
                    }
                    Image {
                        anchors.centerIn: parent
                        width: 40
                        height: 40
                        source: "qrc:/qt/qml/VoidOne.App/assets/branding/voidone-mark.svg"
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        visible: detailsGameIcon.status !== Image.Ready
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    Text { text: gameName; color: "#f0f6fa"; font.pixelSize: 25; font.bold: true; elide: Text.ElideRight }
                    Text { Layout.fillWidth: true; text: platform + "  •  " + source; color: "#71869a"; font.pixelSize: 11; elide: Text.ElideRight }
                    Text { text: playCount + " " + qsTr("launches"); color: "#4e6579"; font.pixelSize: 10 }
                }

                Button {
                    text: favorite ? "★" : "☆"
                    onClicked: {
                        favorite = !favorite
                        gameModel.setFavorite(gameId, favorite)
                    }
                    background: Rectangle { radius: 10; color: parent.hovered ? "#00e5ff14" : "#0a1118"; border.color: "#1d3040" }
                    contentItem: Text { text: parent.text; color: favorite ? "#00e5ff" : "#62788c"; font.pixelSize: 23; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }

                ToolButton {
                    text: "×"; onClicked: dialog.close()
                    contentItem: Text { text: parent.text; color: "#74899c"; font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }
        }

        TabBar {
            id: tabs
            Layout.fillWidth: true
            Layout.topMargin: 12
            TabButton { text: qsTr("Overview") }
            TabButton { text: qsTr("Launch Options") }
            TabButton { text: qsTr("Files") }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabs.currentIndex

            Item {
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 24; spacing: 14
                    Text { text: qsTr("GAME"); color: "#4d6377"; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.4 }
                    InfoRow { label: qsTr("Executable"); value: exePath }
                    InfoRow { label: qsTr("Install folder"); value: workingDir }
                    InfoRow { label: qsTr("Source"); value: source }
                    Item { Layout.fillHeight: true }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 10
                        Button {
                            text: qsTr("▶  Play")
                            Layout.preferredWidth: 130; implicitHeight: 40
                            onClicked: {
                                if (gameModel.launchGame(exePath)) {
                                    dialog.close()
                                    notificationRequested(qsTr("Launch request sent."), false)
                                } else {
                                    notificationRequested(qsTr("Could not start game. Check the executable path."), true)
                                }
                            }
                            background: Rectangle { radius: 10; color: "#00d8ef" }
                            contentItem: Text { text: parent.text; color: "#041015"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                        Button {
                            text: qsTr("Open Folder")
                            implicitHeight: 40
                            onClicked: Qt.openUrlExternally("file:///" + workingDir.replace(/\\/g, "/"))
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: qsTr("Hide")
                            implicitHeight: 40
                            onClicked: { gameModel.hideGame(gameId, true); dialog.close() }
                        }
                    }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 24; spacing: 14
                    Text { text: qsTr("COMMAND"); color: "#4d6377"; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.4 }
                    Text { text: qsTr("Arguments"); color: "#71869a"; font.pixelSize: 11 }
                    TextField { id: argsField; Layout.fillWidth: true; placeholderText: qsTr("e.g. -windowed -novid"); selectByMouse: true }
                    Text { text: qsTr("Working directory"); color: "#71869a"; font.pixelSize: 11 }
                    TextField { id: dirField; Layout.fillWidth: true; selectByMouse: true }
                    Text { Layout.fillWidth: true; text: qsTr("Use this for games that need a custom working directory or startup arguments."); color: "#4e6579"; font.pixelSize: 10; wrapMode: Text.WordWrap }
                    Item { Layout.fillHeight: true }
                    Button {
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("Save Options")
                        onClicked: { gameModel.updateLaunchOptions(gameId, argsField.text, dirField.text); dialog.close() }
                    }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 24; spacing: 14
                    Text { text: qsTr("GAME FILES"); color: "#4d6377"; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.4 }
                    InfoRow { label: qsTr("Path"); value: exePath }
                    InfoRow { label: qsTr("Working directory"); value: workingDir }
                    Text { Layout.fillWidth: true; text: qsTr("VoidOne does not move or modify your game files when managing a local game."); color: "#53697c"; font.pixelSize: 10; wrapMode: Text.WordWrap }
                    Item { Layout.fillHeight: true }
                    Button {
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("Open Folder")
                        onClicked: Qt.openUrlExternally("file:///" + workingDir.replace(/\\/g, "/"))
                    }
                }
            }
        }
    }

    component InfoRow: RowLayout {
        property string label: ""
        property string value: ""
        Layout.fillWidth: true
        implicitHeight: 52
        Text { Layout.preferredWidth: 120; text: label; color: "#62788c"; font.pixelSize: 10 }
        Rectangle {
            Layout.fillWidth: true; implicitHeight: 44; radius: 9
            color: "#080d13"; border.color: "#172635"
            Text { anchors.fill: parent; anchors.margins: 11; text: value; color: "#b9c8d5"; font.pixelSize: 10; elide: Text.ElideMiddle; verticalAlignment: Text.AlignVCenter }
        }
    }
}
