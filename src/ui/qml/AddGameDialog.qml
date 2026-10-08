import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

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

    function reset() {
        selectedFolder = ""
        selectedExecutable = ""
        selectedName = ""
        candidates = []
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
                    source: "qrc:/qt/qml/VoidOne.App/assets/icons/add.svg"
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

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ActionButton {
                Layout.fillWidth: true
                title: qsTr("Select .exe")
                subtitle: qsTr("Add one game directly")
                iconSource: "qrc:/qt/qml/VoidOne.App/assets/icons/file.svg"
                onClicked: exeDialog.open()
            }

            ActionButton {
                Layout.fillWidth: true
                title: qsTr("Select folder")
                subtitle: qsTr("Let VoidOne find executables")
                iconSource: "qrc:/qt/qml/VoidOne.App/assets/icons/folder.svg"
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

        ListView {
            visible: candidates.length > 0
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
                onClicked: dialog.close()
            }

            Button {
                enabled: selectedExecutable.length > 0 && nameField.text.trim().length > 0
                text: qsTr("Add to Library")
                onClicked: {
                    if (gameModel.addNewGame(nameField.text.trim(), selectedExecutable, "")) {
                        dialog.close()
                        root.showNotification(qsTr("Game added to your library."))
                    } else {
                        root.showNotification(qsTr("VoidOne could not add that game."), true)
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

    FileDialog {
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

    FolderDialog {
        id: folderDialog
        title: qsTr("Choose the game's installation folder")

        onAccepted: {
            selectedFolder = folderDialog.selectedFolder.toLocalFile()
            candidates = gameModel.suggestExecutables(selectedFolder)
            if (candidates.length === 1) {
                selectedExecutable = candidates[0]
                selectedName = candidates[0].split("/").pop().split("\\").pop().replace(/\.exe$/i, "")
                nameField.text = selectedName
            }
        }
    }

    Component {
        id: actionButtonComponent
    }

    Component.onCompleted: reset()
}
