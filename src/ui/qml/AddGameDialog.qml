import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs as NativeDialogs

Dialog {
    id: dialog
    modal: true
    anchors.centerIn: Overlay.overlay
    width: Math.min(680, Overlay.overlay ? Overlay.overlay.width - 48 : 680)
    padding: 0

    property string selectedFolder: ""
    property string selectedExecutable: ""
    property string selectedName: ""
    property var candidates: []
    property bool scanning: false
    signal notificationRequested(string message, bool isError)

    function reset() {
        selectedFolder = ""
        selectedExecutable = ""
        selectedName = ""
        candidates = []
        scanning = false
        nameField.text = ""
    }

    background: Rectangle {
        radius: 22
        color: "#0d121b"
        border.color: "#233143"
        border.width: 1

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 3
            radius: 2
            color: "#00e5ff"
        }
    }

    header: Item {
        implicitHeight: 82
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 28
            anchors.rightMargin: 28
            spacing: 16

            Rectangle {
                width: 44
                height: 44
                radius: 14
                color: "#00e5ff14"
                border.color: "#00e5ff55"

                Image {
                    anchors.centerIn: parent
                    width: 23
                    height: 23
                    source: "qrc:/qt/qml/VoidOne.App/assets/ui/icons/add.svg"
                    fillMode: Image.PreserveAspectFit
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Text {
                    text: qsTr("Add a game")
                    color: "#f4f8fb"
                    font.pixelSize: 22
                    font.bold: true
                }
                Text {
                    text: qsTr("Choose where the game lives. VoidOne handles the rest.")
                    color: "#7f91a6"
                    font.pixelSize: 12
                }
            }

            ToolButton {
                text: "×"
                font.pixelSize: 25
                onClicked: dialog.close()
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 14

        Text {
            text: qsTr("GAME LOCATION")
            color: "#526579"
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 1.4
        }

        DropArea {
            id: gameDropArea
            property bool dragActive: false
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            keys: ["text/uri-list"]
            onEntered: dragActive = true
            onExited: dragActive = false
            onDropped: function(drop) {
                dragActive = false
                if (drop.urls && drop.urls.length > 0) {
                    var path = drop.urls[0].toLocalFile()
                    if (path.toLowerCase().endsWith(".exe")) {
                        selectedExecutable = path
                        selectedName = path.split("/").pop().split("\\").pop().replace(/\.exe$/i, "")
                        nameField.text = selectedName
                    } else {
                        selectedFolder = path
                        scanning = true
                        scanAnimation.restart()
                        scanTimer.restart()
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 13
                color: gameDropArea.dragActive ? "#00e5ff14" : "#080c12"
                border.color: gameDropArea.dragActive ? "#00e5ff88" : "#233545"
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 9
                    Image {
                        width: 18
                        height: 18
                        source: "qrc:/qt/qml/VoidOne.App/assets/ui/icons/folder.svg"
                        fillMode: Image.PreserveAspectFit
                        opacity: 0.8
                    }
                    Text {
                        text: gameDropArea.dragActive
                              ? qsTr("Release to add this game")
                              : qsTr("Drop a game .exe or folder here")
                        color: gameDropArea.dragActive ? "#00e5ff" : "#8296a9"
                        font.pixelSize: 11
                        font.bold: gameDropArea.dragActive
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ActionButton {
                Layout.fillWidth: true
                title: qsTr("Select .exe")
                subtitle: qsTr("Add one game directly")
                iconSource: "qrc:/qt/qml/VoidOne.App/assets/ui/icons/file.svg"
                onClicked: exeDialog.open()
            }

            ActionButton {
                Layout.fillWidth: true
                title: qsTr("Select folder")
                subtitle: qsTr("Let VoidOne find executables")
                iconSource: "qrc:/qt/qml/VoidOne.App/assets/ui/icons/folder.svg"
                onClicked: folderDialog.open()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 72
            radius: 13
            color: "#080c12"
            border.color: selectedExecutable.length > 0 ? "#00e5ff66" : "#1b2735"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Rectangle {
                    width: 40
                    height: 40
                    radius: 11
                    color: "#121c28"
                    Text {
                        anchors.centerIn: parent
                        text: selectedExecutable.length > 0 ? "✓" : "?"
                        color: selectedExecutable.length > 0 ? "#00e5ff" : "#526579"
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        Layout.fillWidth: true
                        text: selectedExecutable.length > 0 ? selectedExecutable.split("/").pop().split("\\").pop() : qsTr("No executable selected")
                        color: "#e7eef5"
                        font.pixelSize: 13
                        font.bold: true
                        elide: Text.ElideMiddle
                    }
                    Text {
                        Layout.fillWidth: true
                        text: selectedExecutable.length > 0 ? selectedExecutable : qsTr("Select an executable or scan a game folder.")
                        color: "#62758a"
                        font.pixelSize: 11
                        elide: Text.ElideMiddle
                    }
                }
            }
        }

        Text {
            visible: candidates.length > 0
            text: qsTr("POSSIBLE GAME EXECUTABLES")
            color: "#526579"
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 1.2
        }

        Rectangle {
            visible: scanning
            Layout.fillWidth: true
            implicitHeight: 48
            radius: 11
            color: "#00e5ff08"
            border.color: "#00e5ff28"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10
                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    color: "transparent"
                    border.color: "#00e5ff55"
                    border.width: 2
                    Rectangle {
                        width: 6; height: 6; radius: 3
                        anchors.centerIn: parent
                        color: "#00e5ff"
                    }
                    RotationAnimation on rotation {
                        id: scanAnimation
                        from: 0; to: 360; duration: 800
                        loops: Animation.Infinite
                        running: scanning
                    }
                }
                Text {
                    text: qsTr("Scanning this folder for likely game executables…")
                    color: "#9fb4c6"
                    font.pixelSize: 11
                    Layout.fillWidth: true
                }
            }
        }

        ListView {
            visible: candidates.length > 0 && !scanning
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(180, candidates.length * 48)
            clip: true
            spacing: 6
            model: candidates

            delegate: Rectangle {
                required property string modelData
                width: ListView.view.width
                height: 42
                radius: 10
                color: selectedExecutable === modelData ? "#00e5ff14" : "#0a0f16"
                border.color: selectedExecutable === modelData ? "#00e5ff55" : "#152130"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedExecutable = modelData
                        selectedName = modelData.split("/").pop().split("\\").pop().replace(/\.exe$/i, "")
                        if (!nameField.text.length)
                            nameField.text = selectedName
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    Text {
                        text: selectedExecutable === modelData ? "●" : "○"
                        color: "#00e5ff"
                        font.pixelSize: 10
                    }
                    Text {
                        Layout.fillWidth: true
                        text: modelData
                        color: "#b8c7d6"
                        font.pixelSize: 11
                        elide: Text.ElideMiddle
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: qsTr("GAME NAME")
                color: "#526579"
                font.pixelSize: 10
                font.bold: true
            }

            TextField {
                id: nameField
                Layout.fillWidth: true
                placeholderText: qsTr("e.g. Cyberpunk 2077")
                selectByMouse: true
                color: "#eaf2f8"
                placeholderTextColor: "#506277"

                background: Rectangle {
                    radius: 11
                    color: "#080c12"
                    border.color: nameField.activeFocus ? "#00e5ff88" : "#1b2735"
                }
            }
        }

        Item { Layout.preferredHeight: 2 }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Cancel")
                implicitHeight: 40
                onClicked: dialog.close()
                background: Rectangle {
                    radius: 10
                    color: parent.hovered ? "#142331" : "#0a1118"
                    border.color: "#263a4b"
                }
                contentItem: Text {
                    text: parent.text
                    color: "#b9c8d5"
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                enabled: selectedExecutable.length > 0 && nameField.text.trim().length > 0
                text: qsTr("Add to Library")
                onClicked: {
                    if (gameModel.addNewGame(nameField.text.trim(), selectedExecutable, "")) {
                        dialog.close()
                        notificationRequested(qsTr("Game added to your library."), false)
                    } else {
                        notificationRequested(qsTr("VoidOne could not add that game."), true)
                    }
                }
                background: Rectangle {
                    radius: 10
                    color: parent.enabled ? "#00e5ff" : "#1c2b38"
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? "#061016" : "#62758a"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    NativeDialogs.FileDialog {
        id: exeDialog
        title: qsTr("Choose a game executable")
        fileMode: FileDialog.OpenFile
        nameFilters: ["Windows executable (*.exe)", "All files (*)"]

        onAccepted: {
            selectedExecutable = selectedFile.toLocalFile()
            selectedName = selectedExecutable.split("/").pop().split("\\").pop().replace(/\.exe$/i, "")
            nameField.text = selectedName
            candidates = []
        }
    }

    NativeDialogs.FolderDialog {
        id: folderDialog
        title: qsTr("Choose the game's installation folder")

        onAccepted: {
            selectedFolder = folderDialog.selectedFolder.toLocalFile()
            scanning = true
            scanAnimation.restart()
            scanTimer.restart()
        }
    }

    Timer {
        id: scanTimer
        interval: 80
        repeat: false
        onTriggered: {
            candidates = gameModel.suggestExecutables(selectedFolder)
            scanning = false
            if (candidates.length === 0)
                notificationRequested(qsTr("No likely game executable was found in that folder."), true)
            else if (candidates.length === 1) {
                selectedExecutable = candidates[0]
                selectedName = candidates[0].split("/").pop().split("\\").pop().replace(/\.exe$/i, "")
                nameField.text = selectedName
            }
        }
    }

    Component.onCompleted: reset()
}
