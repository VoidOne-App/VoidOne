/****************************************************************************
**  V O I D O N E   -   Free & Source-Available PC Gaming Platform
**  Platform Shell v2
**  Copyright (C) 2026 VoidOne
****************************************************************************/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

Window {
    id: root

    width: Screen.desktopAvailableWidth * 0.86
    height: Screen.desktopAvailableHeight * 0.86
    minimumWidth: 1040
    minimumHeight: 700
    visible: true
    title: qsTr("VoidOne")
    color: theme.background

    property string currentPage: "home"
    property bool sidebarCompact: false

    QtObject {
        id: theme
        property color background: "#070a0f"
        property color sidebar: "#0a0f16"
        property color surface: "#0d141d"
        property color surface2: "#111b26"
        property color surface3: "#152331"
        property color cyan: "#00e5ff"
        property color cyanSoft: "#00e5ff18"
        property color cyanLine: "#00e5ff42"
        property color text: "#eef5fa"
        property color muted: "#74889c"
        property color dim: "#415365"
        property color success: "#38d996"
    }

    function text(key, fallback) {
        if (typeof trManager !== "undefined" && trManager !== null && typeof trManager.getText === "function") {
            var value = trManager.getText(key)
            return value && value.length ? value : fallback
        }
        return fallback
    }

    function showNotification(message, isError) {
        toast.text = message
        toastAccent.color = isError ? "#ff5f70" : theme.cyan
        toastAnimation.restart()
    }

    Rectangle {
        anchors.fill: parent
        color: theme.background

        // Ambient platform lighting
        Rectangle {
            width: 520
            height: 520
            x: parent.width - 310
            y: -290
            radius: 260
            color: "#00e5ff08"
            opacity: 0.9
        }

        Rectangle {
            width: 420
            height: 420
            x: -250
            y: parent.height - 120
            radius: 210
            color: "#2478ff06"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Sidebar {
                id: sidebar
                Layout.fillHeight: true
                Layout.preferredWidth: root.sidebarCompact ? 78 : 218
                compact: root.sidebarCompact
                currentPage: root.currentPage
                onPageChanged: function(page) { root.currentPage = page }
            }

            Rectangle {
                Layout.fillHeight: true
                width: 1
                color: "#182635"
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Command bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 68
                    color: "#080c12cc"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 24
                        anchors.rightMargin: 22
                        spacing: 14

                        ToolButton {
                            text: root.sidebarCompact ? "»" : "«"
                            onClicked: root.sidebarCompact = !root.sidebarCompact
                            background: Rectangle {
                                radius: 9
                                color: parent.hovered ? "#13202c" : "transparent"
                            }
                            contentItem: Text {
                                text: parent.text
                                color: theme.muted
                                font.pixelSize: 17
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 300
                            Layout.preferredHeight: 38
                            radius: 10
                            color: "#0b1118"
                            border.color: searchInput.activeFocus ? theme.cyanLine : "#172533"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 11
                                anchors.rightMargin: 11
                                spacing: 8

                                Text {
                                    text: "⌕"
                                    color: theme.dim
                                    font.pixelSize: 19
                                }

                                TextField {
                                    id: searchInput
                                    Layout.fillWidth: true
                                    placeholderText: qsTr("Search your games...")
                                    color: theme.text
                                    placeholderTextColor: theme.dim
                                    background: Item {}
                                    font.pixelSize: 12
                                    selectByMouse: true
                                    onTextChanged: {
                                        if (typeof gameModel !== "undefined" && gameModel !== null)
                                            gameModel.filter(text)
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 100
                            radius: 10
                            color: "#0c141c"
                            border.color: "#172533"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 7
                                Rectangle {
                                    width: 7
                                    height: 7
                                    radius: 4
                                    color: theme.success
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.25; duration: 900 }
                                        NumberAnimation { to: 1; duration: 900 }
                                    }
                                }
                                Text {
                                    text: qsTr("LOCAL")
                                    color: theme.muted
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                        }

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: theme.cyanSoft
                            border.color: theme.cyanLine
                            Text {
                                anchors.centerIn: parent
                                text: "V"
                                color: theme.cyan
                                font.bold: true
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#14202c"
                }

                StackLayout {
                    id: pages
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: root.currentPage === "home" ? 0 :
                                  root.currentPage === "library" ? 1 :
                                  root.currentPage === "activity" ? 2 : 3

                    // HOME
                    Flickable {
                        contentWidth: width
                        contentHeight: homeColumn.implicitHeight + 48
                        clip: true

                        ColumnLayout {
                            id: homeColumn
                            width: parent.width
                            anchors.top: parent.top
                            anchors.topMargin: 30
                            anchors.leftMargin: 34
                            anchors.rightMargin: 34
                            spacing: 24

                            RowLayout {
                                Layout.fillWidth: true

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    Text {
                                        text: qsTr("Your games. Your hardware. Your rules.")
                                        color: theme.text
                                        font.pixelSize: 29
                                        font.bold: true
                                    }
                                    Text {
                                        text: qsTr("A local-first gaming platform that puts your library back in your hands.")
                                        color: theme.muted
                                        font.pixelSize: 13
                                    }
                                }

                                Button {
                                    implicitWidth: 150
                                    implicitHeight: 44
                                    text: qsTr("＋  Add Game")
                                    onClicked: addGameDialog.open()
                                    background: Rectangle {
                                        radius: 12
                                        color: parent.pressed ? "#00b9cf" : theme.cyan
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#041015"
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            // Hero
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 220
                                radius: 22
                                color: "#0d151e"
                                border.color: "#1b2b3b"
                                clip: true

                                Rectangle {
                                    width: 460
                                    height: 460
                                    x: parent.width - 250
                                    y: -210
                                    radius: 230
                                    color: "#00e5ff0c"
                                }

                                Rectangle {
                                    width: 2
                                    height: parent.height - 48
                                    x: 38
                                    y: 24
                                    color: theme.cyan
                                }

                                ColumnLayout {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 68
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width * 0.58
                                    spacing: 12

                                    Text {
                                        text: qsTr("WELCOME BACK")
                                        color: theme.cyan
                                        font.pixelSize: 10
                                        font.bold: true
                                        font.letterSpacing: 2
                                    }

                                    Text {
                                        text: gameModel && gameModel.count > 0 ? qsTr("Ready to play.") : qsTr("Build your library.")
                                        color: theme.text
                                        font.pixelSize: 31
                                        font.bold: true
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: gameModel && gameModel.count > 0
                                              ? qsTr("Pick a game and launch it directly from VoidOne.")
                                              : qsTr("Scan your PC or point VoidOne at a game's folder or executable.")
                                        color: theme.muted
                                        font.pixelSize: 13
                                        wrapMode: Text.WordWrap
                                    }

                                    RowLayout {
                                        spacing: 10
                                        Button {
                                            text: qsTr("Open Library")
                                            onClicked: root.currentPage = "library"
                                            background: Rectangle {
                                                radius: 9
                                                color: theme.surface3
                                                border.color: "#26394a"
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: theme.text
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                        Text {
                                            text: qsTr("LOCAL • PRIVATE • YOURS")
                                            color: theme.dim
                                            font.pixelSize: 9
                                            font.bold: true
                                        }
                                    }
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 42
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "V"
                                    color: "#00e5ff10"
                                    font.pixelSize: 150
                                    font.bold: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 14

                                StatCard {
                                    Layout.fillWidth: true
                                    label: qsTr("LIBRARY")
                                    value: gameModel ? gameModel.count : 0
                                    detail: qsTr("games ready")
                                }
                                StatCard {
                                    Layout.fillWidth: true
                                    label: qsTr("PLATFORM")
                                    value: "LOCAL"
                                    detail: qsTr("no account required")
                                }
                                StatCard {
                                    Layout.fillWidth: true
                                    label: qsTr("CONTROL")
                                    value: "100%"
                                    detail: qsTr("your library")
                                }
                            }

                            Text {
                                text: qsTr("RECENTLY ADDED")
                                color: theme.muted
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1.8
                            }

                            GridView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.max(190, Math.ceil((gameModel ? gameModel.count : 0) / 3) * 190)
                                interactive: false
                                cellWidth: width / 3
                                cellHeight: 180
                                model: typeof gameModel !== "undefined" ? gameModel : null

                                delegate: GameCard {
                                    width: GridView.view.cellWidth - 10
                                    height: 168
                                    gameId: model.id
                                    gameName: model.name
                                    exePath: model.exePath
                                    iconPath: model.iconPath
                                    platform: model.platform
                                    itemIndex: index
                                    compact: true
                                    onLaunchRequested: function(path) {
                                        gameModel.launchGame(path)
                                        root.showNotification(qsTr("Launching game..."))
                                    }
                                }
                            }
                        }
                    }

                    // LIBRARY
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 32
                            spacing: 18

                            RowLayout {
                                Layout.fillWidth: true
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Text {
                                        text: qsTr("Library")
                                        color: theme.text
                                        font.pixelSize: 28
                                        font.bold: true
                                    }
                                    Text {
                                        text: qsTr("Everything you play, in one place.")
                                        color: theme.muted
                                        font.pixelSize: 12
                                    }
                                }
                                Button {
                                    text: qsTr("＋ Add Game")
                                    onClicked: addGameDialog.open()
                                    background: Rectangle {
                                        radius: 10
                                        color: theme.cyan
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#041015"
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: "#14202c"
                            }

                            GridView {
                                id: gameGrid
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                cellWidth: Math.max(240, Math.floor(width / Math.max(1, Math.floor(width / 285))))
                                cellHeight: 190
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds
                                model: typeof gameModel !== "undefined" ? gameModel : null

                                delegate: GameCard {
                                    width: gameGrid.cellWidth - 12
                                    height: 174
                                    gameId: model.id
                                    gameName: model.name
                                    exePath: model.exePath
                                    iconPath: model.iconPath
                                    platform: model.platform
                                    itemIndex: index
                                    onLaunchRequested: function(path) {
                                        gameModel.launchGame(path)
                                        root.showNotification(qsTr("Launching game..."))
                                    }
                                }

                                footer: Item {
                                    width: gameGrid.width
                                    height: 130
                                }
                            }

                            ColumnLayout {
                                anchors.centerIn: gameGrid
                                visible: gameGrid.count === 0
                                spacing: 10

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "＋"
                                    color: theme.cyan
                                    font.pixelSize: 38
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: qsTr("Your library is empty")
                                    color: theme.text
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: qsTr("Add an executable or choose a game folder.")
                                    color: theme.muted
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }

                    // ACTIVITY
                    Item {
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 10
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: qsTr("Activity")
                                color: theme.text
                                font.pixelSize: 28
                                font.bold: true
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: qsTr("Play history and platform events are coming next.")
                                color: theme.muted
                                font.pixelSize: 12
                            }
                        }
                    }

                    // SETTINGS
                    Item {
                        SaveBackupView {
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: toastBox
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        width: Math.min(420, parent.width - 40)
        height: 48
        radius: 13
        color: "#101a24f5"
        border.color: "#203243"
        opacity: 0
        visible: opacity > 0
        z: 100

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 10
            Rectangle {
                id: toastAccent
                width: 7
                height: 7
                radius: 4
                color: theme.cyan
            }
            Text {
                id: toast
                Layout.fillWidth: true
                color: theme.text
                font.pixelSize: 12
                font.bold: true
                elide: Text.ElideRight
            }
        }

        SequentialAnimation {
            id: toastAnimation
            NumberAnimation { target: toastBox; property: "opacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }
            PauseAnimation { duration: 2600 }
            NumberAnimation { target: toastBox; property: "opacity"; to: 0; duration: 260; easing.type: Easing.InCubic }
        }
    }

    AddGameDialog {
        id: addGameDialog
    }

    Component {
        id: statCardComponent
        StatCard {}
    }

    Component.onCompleted: {
        if (typeof gameModel !== "undefined" && gameModel !== null)
            gameModel.loadGamesFromDatabase()
        showNotification(qsTr("VoidOne is ready."))
    }

    component StatCard: Rectangle {
        implicitHeight: 92
        radius: 15
        color: "#0b1118"
        border.color: "#172533"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 3
            Text {
                text: parent.parent.label
                color: theme.dim
                font.pixelSize: 9
                font.bold: true
                font.letterSpacing: 1.3
            }
            Text {
                text: parent.parent.value
                color: theme.text
                font.pixelSize: 22
                font.bold: true
            }
            Text {
                text: parent.parent.detail
                color: theme.muted
                font.pixelSize: 10
            }
        }

        property string label: ""
        property string value: ""
        property string detail: ""
    }
}
