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
    minimumWidth: 900
    minimumHeight: 600
    visible: true
    title: qsTr("VoidOne")
    color: theme.background

    property string currentPage: "home"
    property bool sidebarCompact: false
    readonly property bool narrowLayout: width < 1100

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
                            Layout.preferredWidth: root.narrowLayout ? 190 : 300
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
                            Image {
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                source: "qrc:/qt/qml/VoidOne.App/assets/branding/voidone-mark.svg"
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                asynchronous: true
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
                            width: Math.max(0, parent.width - 56)
                            anchors.top: parent.top
                            anchors.topMargin: 26
                            anchors.left: parent.left
                            anchors.leftMargin: 28
                            spacing: 22

                            RowLayout {
                                Layout.fillWidth: true

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    Text {
                                        text: qsTr("Your games. Your hardware. Your rules.")
                                        color: theme.text
                                        font.pixelSize: root.narrowLayout ? 23 : 29
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
                                Layout.preferredHeight: root.narrowLayout ? 185 : 220
                                radius: 18
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
                                    anchors.leftMargin: root.narrowLayout ? 28 : 68
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width * (root.narrowLayout ? 0.72 : 0.58)
                                    spacing: 10

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
                                        font.pixelSize: root.narrowLayout ? 25 : 31
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

                                Image {
                                    visible: !root.narrowLayout
                                    anchors.right: parent.right
                                    anchors.rightMargin: 34
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 150
                                    height: 150
                                    source: "qrc:/qt/qml/VoidOne.App/assets/branding/voidone-mark.svg"
                                    fillMode: Image.PreserveAspectFit
                                    opacity: 0.12
                                    asynchronous: true
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
                                    label: qsTr("LAUNCH")
                                    value: qsTr("DIRECT")
                                    detail: qsTr("from your library")
                                }
                            }

                            Text {
                                text: qsTr("YOUR LIBRARY")
                                color: theme.muted
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1.8
                            }

                            GridView {
                                Layout.fillWidth: true
                                property int columns: width < 560 ? 1 : (width < 900 ? 2 : 3)
                                Layout.preferredHeight: Math.max(190, Math.ceil((gameModel ? gameModel.count : 0) / columns) * 190)
                                interactive: false
                                cellWidth: width / columns
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
                                    source: model.source
                                    favorite: model.favorite
                                    playCount: model.playCount
                                    itemIndex: index
                                    compact: true
                                    onLaunchRequested: function(path) {
                                        gameModel.launchGame(path)
                                        root.showNotification(qsTr("Launching game..."))
                                    }
                                    onDetailsRequested: gameDetails.openFor(gameId, gameName, exePath, platform, source, model.workingDir, model.launchArgs, playCount, favorite)
                                }
                            }
                        }
                    }

                    // LIBRARY
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 24
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
                                    text: qsTr("Scan PC")
                                    onClicked: { steamScanner.startAsyncScan(); root.showNotification(qsTr("Scanning installed Steam games...")) }
                                    background: Rectangle { radius: 10; color: "#101a24"; border.color: "#263a4c" }
                                    contentItem: Text { text: parent.text; color: theme.text; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
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
                                    source: model.source
                                    favorite: model.favorite
                                    playCount: model.playCount
                                    itemIndex: index
                                    onLaunchRequested: function(path) {
                                        gameModel.launchGame(path)
                                        root.showNotification(qsTr("Launching game..."))
                                    }
                                    onDetailsRequested: gameDetails.openFor(gameId, gameName, exePath, platform, source, model.workingDir, model.launchArgs, playCount, favorite)
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
                                    text: searchInput.text.length > 0
                                          ? qsTr("Try a different search term.")
                                          : qsTr("Add an executable or choose a game folder.")
                                    color: theme.muted
                                    font.pixelSize: 12
                                }

                                Button {
                                    Layout.alignment: Qt.AlignHCenter
                                    visible: searchInput.text.length === 0
                                    text: qsTr("＋ Add your first game")
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
                    Flickable {
                        id: settingsFlickable
                        clip: true
                        contentWidth: width
                        contentHeight: settingsColumn.implicitHeight + 48
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id: settingsColumn
                            width: Math.max(0, settingsFlickable.width - 48)
                            anchors.top: parent.top
                            anchors.topMargin: 24
                            anchors.left: parent.left
                            anchors.leftMargin: 24
                            spacing: 18

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                Text {
                                    text: qsTr("Settings")
                                    color: theme.text
                                    font.pixelSize: 28
                                    font.bold: true
                                }
                                Text {
                                    text: qsTr("Configure VoidOne's real features and local preferences.")
                                    color: theme.muted
                                    font.pixelSize: 12
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }

                            // Language preferences
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: languageRow.implicitHeight + 28
                                radius: 14
                                color: theme.surface
                                border.color: "#1b2b3a"

                                RowLayout {
                                    id: languageRow
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 14

                                    Rectangle {
                                        Layout.preferredWidth: 40
                                        Layout.preferredHeight: 40
                                        radius: 11
                                        color: theme.cyanSoft
                                        border.color: theme.cyanLine
                                        Text {
                                            anchors.centerIn: parent
                                            text: "文"
                                            color: theme.cyan
                                            font.pixelSize: 18
                                            font.bold: true
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3
                                        Text {
                                            text: qsTr("Backup panel language")
                                            color: theme.text
                                            font.pixelSize: 13
                                            font.bold: true
                                        }
                                        Text {
                                            text: trManager.currentLanguage === "fa"
                                                  ? "فقط برچسب‌های بخش پشتیبان‌گیری به فارسی نمایش داده می‌شوند."
                                                  : "Changes labels in the backup controls only."
                                            color: theme.muted
                                            font.pixelSize: 11
                                        }
                                    }

                                    Button {
                                        text: trManager.currentLanguage === "en" ? "فارسی" : "English"
                                        onClicked: trManager.currentLanguage =
                                                   trManager.currentLanguage === "en" ? "fa" : "en"
                                        background: Rectangle {
                                            radius: 9
                                            color: parent.hovered ? "#142b37" : "#0b1720"
                                            border.color: theme.cyanLine
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: theme.cyan
                                            font.pixelSize: 11
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }

                            // Library tools: real Steam scan action, no pretend preferences.
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: libraryRow.implicitHeight + 28
                                radius: 14
                                color: theme.surface
                                border.color: "#1b2b3a"

                                RowLayout {
                                    id: libraryRow
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 14

                                    Rectangle {
                                        Layout.preferredWidth: 40
                                        Layout.preferredHeight: 40
                                        radius: 11
                                        color: theme.cyanSoft
                                        border.color: theme.cyanLine
                                        Image {
                                            anchors.centerIn: parent
                                            width: 21
                                            height: 21
                                            source: "qrc:/qt/qml/VoidOne.App/assets/ui/icons/library.svg"
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3
                                        Text {
                                            text: qsTr("Game library")
                                            color: theme.text
                                            font.pixelSize: 13
                                            font.bold: true
                                        }
                                        Text {
                                            text: qsTr("Scan detected Steam libraries for installed games.")
                                            color: theme.muted
                                            font.pixelSize: 11
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                        }
                                    }

                                    Button {
                                        text: qsTr("Scan Steam")
                                        onClicked: {
                                            steamScanner.startAsyncScan()
                                            root.showNotification(qsTr("Scanning installed Steam games..."))
                                        }
                                        background: Rectangle {
                                            radius: 9
                                            color: parent.hovered ? "#142b37" : "#0b1720"
                                            border.color: "#2a4051"
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: theme.text
                                            font.pixelSize: 11
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }

                            SaveBackupView {
                                Layout.fillWidth: true
                                Layout.maximumWidth: 900
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: aboutRow.implicitHeight + 28
                                radius: 14
                                color: theme.surface
                                border.color: "#1b2b3a"

                                RowLayout {
                                    id: aboutRow
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 14

                                    Rectangle {
                                        Layout.preferredWidth: 40
                                        Layout.preferredHeight: 40
                                        radius: 11
                                        color: theme.cyanSoft
                                        border.color: theme.cyanLine
                                        Image {
                                            anchors.centerIn: parent
                                            width: 25
                                            height: 25
                                            source: "qrc:/qt/qml/VoidOne.App/assets/branding/voidone-mark.svg"
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3
                                        Text {
                                            text: qsTr("About VoidOne")
                                            color: theme.text
                                            font.pixelSize: 13
                                            font.bold: true
                                        }
                                        Text {
                                            text: qsTr("Local-first. Private by design. Your games stay yours.")
                                            color: theme.muted
                                            font.pixelSize: 11
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                        }
                                    }

                                    Text {
                                        text: "v" + Qt.application.version
                                        color: theme.dim
                                        font.pixelSize: 10
                                    }
                                }
                            }
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

    GameDetailsDialog {
        id: gameDetails
    }

    AddGameDialog {
        id: addGameDialog
        onNotificationRequested: function(message, isError) { root.showNotification(message, isError) }
    }

    Component {
        id: statCardComponent
        StatCard {}
    }

    Connections {
        target: steamScanner
        function onScanCompleted(count) {
            gameModel.loadGamesFromDatabase()
            root.showNotification(qsTr("Steam scan complete: ") + count + qsTr(" games found."))
        }
        function onScanFailed(message) { root.showNotification(message, true) }
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
