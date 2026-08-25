/****************************************************************************
**  V O I D O N E   E N G I N E   -   QUANTUM ENTERPRISE CORE
**  Ultra-High Performance Commercial QML & C++ Game Launcher Architecture
**  Copyright (C) 2026 VoidOne-App | SPDX-License-Identifier: MIT
****************************************************************************/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls

Window {
    id: root

    // Responsive automatic screen sizing based on 85% of available display area
    width: Screen.desktopAvailableWidth * 0.85
    height: Screen.desktopAvailableHeight * 0.85
    minimumWidth: 1024
    minimumHeight: 680

    visible: true
    title: qsTr("VoidOne Engine // Enterprise Quantum Launcher [v0.0.1-PRO]")

    color: theme.background

    // ---------------------------------------------------------
    // 1. Quantum Enterprise Design System & Palette
    // ---------------------------------------------------------
    QtObject {
        id: theme
        property color background: "#05070a"
        property color surface: "#0a0f18"
        property color surfaceElevated: "#111826"
        property color surfaceGlass: "#800a0f18"

        property color primary: "#00f0ff"
        property color primaryGlow: "#33f3ff"
        property color primaryTransparent: "#1a00f0ff"

        property color accentPurple: "#9d4edd"
        property color textPrimary: "#f8fafc"
        property color textSecondary: "#64748b"

        property color success: "#10b981"
        property color warning: "#f59e0b"
        property color danger: "#ef4444"

        property int radiusBase: 12
        property int radiusLarge: 16
    }

    // Dynamic RTL/LTR Smart Detection Engine
    LayoutMirroring.enabled: typeof trManager !== "undefined" && trManager !== null ? (trManager.currentLanguage === "fa" || trManager.currentLanguage === "ar") : false
    LayoutMirroring.childrenInherit: true

    property string currentPage: "library"
    property bool systemSecured: true

    // ---------------------------------------------------------
    // 2. Advanced Enterprise Toast Telemetry Popup Engine
    // ---------------------------------------------------------
    function showNotification(message, isError = false, isWarning = false) {
        toastText.text = message
        if (isError) {
            toastBg.color = theme.danger
            toastIndicator.color = "#ffffff"
        } else if (isWarning) {
            toastBg.color = theme.warning
            toastIndicator.color = "#000000"
        } else {
            toastBg.color = theme.surfaceElevated
            toastIndicator.color = theme.primary
        }
        toastAnim.restart()
    }

    // Master Layout Frame
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ---------------------------------------------------------
        // 3. Telemetry & Enterprise Command Top Bar
        // ---------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: theme.surface
            z: 10

            // High-tech Neon Bottom Line
            Rectangle {
                width: parent.width
                height: 1.5
                anchors.bottom: parent.bottom
                color: theme.primaryTransparent
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                spacing: 20

                // Enterprise Global Search Matrix
                RowLayout {
                    spacing: 12

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: theme.primaryTransparent
                        border.color: theme.primary
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "🔍"
                            font.pixelSize: 12
                        }
                    }

                    TextField {
                        id: searchInput
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 40
                        placeholderText: qsTr("Search database nodes...")
                        color: theme.textPrimary
                        placeholderTextColor: theme.textSecondary
                        font.pixelSize: 13
                        selectByMouse: true

                        background: Rectangle {
                            color: theme.background
                            radius: theme.radiusBase
                            border.color: searchInput.activeFocus ? theme.primary : theme.primaryTransparent
                            border.width: searchInput.activeFocus ? 2 : 1

                            Behavior on border.color { ColorAnimation { duration: 200 } }
                        }

                        onTextChanged: {
                            if (typeof gameModel !== "undefined" && gameModel !== null && typeof gameModel.filter === "function") {
                                gameModel.filter(text)
                            }
                        }
                    }
                }

                // --- Live System Monitoring Widget (CPU & RAM) ---
                Rectangle {
                    Layout.preferredWidth: 190
                    Layout.preferredHeight: 40
                    color: theme.background
                    radius: 8
                    border.color: theme.primaryTransparent
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        ColumnLayout {
                            spacing: 1
                            Text { text: "RAM USAGE"; color: theme.textSecondary; font.pixelSize: 8; font.bold: true }
                            Text { text: "4.2 GB / 12 GB"; color: theme.textPrimary; font.pixelSize: 10; font.bold: true }
                        }

                        Item { Layout.fillWidth: true }

                        ColumnLayout {
                            spacing: 1
                            Layout.alignment: Qt.AlignRight
                            Text { text: "CPU LOAD"; color: theme.textSecondary; font.pixelSize: 8; font.bold: true }
                            Text { text: "14%"; color: theme.primary; font.pixelSize: 10; font.bold: true }
                        }
                    }
                }

                // --- Background Soundtrack Controller ---
                Rectangle {
                    id: musicWidget
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 40
                    color: theme.background
                    radius: 20
                    border.color: theme.primary
                    border.width: 1

                    property bool isPlaying: false

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 8
                        spacing: 6

                        Button {
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            background: Rectangle {
                                color: theme.primaryTransparent
                                radius: 13
                            }
                            contentItem: Text {
                                text: musicWidget.isPlaying ? "⏸" : "▶"
                                color: theme.primary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignCenter
                                font.pixelSize: 10
                            }
                            onClicked: {
                                musicWidget.isPlaying = !musicWidget.isPlaying
                                root.showNotification(musicWidget.isPlaying ? qsTr("Playing: MZ — The Lost") : qsTr("Music Paused"))
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: musicWidget.isPlaying ? "MZ — The Lost" : "Paused"
                            color: theme.textPrimary
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }
                }

                Item { Layout.fillWidth: true } // Quantum Layout Spacer

                // Security & System Core Telemetry Widgets
                RowLayout {
                    spacing: 16

                    RowLayout {
                        spacing: 8

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: theme.success

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.1; duration: 800; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                            }
                        }

                        Text {
                            text: qsTr("SECURE LINK")
                            color: theme.textSecondary
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    Rectangle {
                        width: 1
                        height: 24
                        color: theme.primaryTransparent
                    }

                    // User Identity Badge
                    RowLayout {
                        spacing: 10

                        ColumnLayout {
                            spacing: 1
                            Layout.alignment: Qt.AlignRight

                            Text {
                                Layout.alignment: Qt.AlignRight
                                text: "COMMANDER"
                                color: theme.textPrimary
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignRight
                                text: "Level 14 (IR)"
                                color: theme.primary
                                font.pixelSize: 9
                            }
                        }

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: theme.primaryTransparent
                            border.color: theme.primary
                            border.width: 1.5

                            Text {
                                anchors.centerIn: parent
                                text: "MZ"
                                color: theme.primary
                                font.pixelSize: 13
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }

        // Main Architecture Body (Sidebar + Core Viewport)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Sidebar {
                id: sidebar
                Layout.preferredWidth: 270
                Layout.fillHeight: true
                onPageChanged: function(page) { 
                    root.currentPage = page 
                }
            }

            Rectangle {
                Layout.fillHeight: true
                width: 1
                color: theme.primaryTransparent
            }

            // ---------------------------------------------------------
            // 4. Multi-Dimensional Stack Viewport Core
            // ---------------------------------------------------------
            StackLayout {
                id: contentStack
                Layout.fillWidth: true
                Layout.fillHeight: true

                currentIndex: {
                    switch (root.currentPage) {
                        case "library": return 0
                        case "marketplace": return 1
                        case "settings": return 2
                        default: return 0
                    }
                }

                // --- Library Viewport ---
                Item {
                    id: libraryPage

                    GridView {
                        id: gameGrid
                        anchors.fill: parent
                        anchors.margins: 28
                        cellWidth: 320
                        cellHeight: 230
                        clip: true

                        flickDeceleration: 1800
                        boundsBehavior: Flickable.StopAtBounds

                        model: typeof gameModel !== "undefined" && gameModel !== null ? gameModel : null

                        delegate: GameCard {
                            gameId: model.id !== undefined ? model.id : 0
                            gameName: model.name !== undefined ? model.name : "Unknown Asset"
                            exePath: model.exePath !== undefined ? model.exePath : ""
                            iconPath: model.iconPath !== undefined ? model.iconPath : ""
                            platform: model.platform !== undefined ? model.platform : "Native"
                            itemIndex: index

                            onLaunchRequested: function(path) {
                                root.showNotification(qsTr("Spawning secure isolated process container..."))
                                if (typeof gameManager !== "undefined" && gameManager !== null && typeof gameManager.launchGame === "function") {
                                    gameManager.launchGame(path)
                                }
                            }
                        }
                    }

                    // Quantum Empty State Matrix
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 16
                        visible: gameGrid.count === 0

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 70
                            height: 70
                            radius: 35
                            color: theme.primaryTransparent
                            border.color: theme.primary
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "⚡"
                                font.pixelSize: 28
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("No Game Assets Detected in Local Database")
                            color: theme.textPrimary
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Initialize a Steam sync or mount directories to load nodes.")
                            color: theme.textSecondary
                            font.pixelSize: 13
                        }
                    }
                }

                // --- Marketplace Viewport ---
                Item {
                    id: marketplacePage

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("🌐 Quantum Store Infrastructure")
                            color: theme.primary
                            font.pixelSize: 26
                            font.bold: true
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Encrypted distribution network initializing...")
                            color: theme.textSecondary
                            font.pixelSize: 14
                        }
                    }
                }

                // --- Settings Viewport ---
                Item {
                    id: settingsPage
                    SaveBackupView { 
                        anchors.centerIn: parent 
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------
    // 5. Global Enterprise Toast Alert System
    // ---------------------------------------------------------
    Rectangle {
        id: toastBg
        width: Math.max(320, toastText.implicitWidth + 60)
        height: 50
        radius: theme.radiusBase
        color: theme.surfaceElevated

        border.color: theme.primary
        border.width: 1.5

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter

        opacity: 0
        visible: opacity > 0
        z: 99

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 14

            Rectangle {
                id: toastIndicator
                width: 8
                height: 8
                radius: 4
                color: theme.primary
            }

            Text {
                id: toastText
                Layout.fillWidth: true
                color: theme.textPrimary
                font.bold: true
                font.pixelSize: 13
                elide: Text.ElideRight
            }
        }

        SequentialAnimation {
            id: toastAnim
            NumberAnimation { target: toastBg; property: "opacity"; to: 1; duration: 220; easing.type: Easing.OutCubic }
            PauseAnimation { duration: 3200 }
            NumberAnimation { target: toastBg; property: "opacity"; to: 0; duration: 350; easing.type: Easing.InCubic }
        }
    }

    // ---------------------------------------------------------
    // 6. Global Confirmation Dialog Modal
    // ---------------------------------------------------------
    Rectangle {
        id: globalDialog
        anchors.fill: parent
        color: "#b005070a"
        visible: false
        z: 1000

        property string dialogTitle: "Alert"
        property string dialogDesc: "Message..."
        signal confirmed()

        function openDialog(title, desc) {
            dialogTitle = title
            dialogDesc = desc
            globalDialog.visible = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {} // Intercept interactions with underlying UI elements
        }

        Rectangle {
            width: 400
            height: 180
            anchors.centerIn: parent
            color: theme.surface
            radius: theme.radiusBase
            border.color: theme.primary
            border.width: 1.5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10

                Text {
                    text: globalDialog.dialogTitle
                    color: theme.textPrimary
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: globalDialog.dialogDesc
                    color: theme.textSecondary
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 10

                    Button {
                        text: qsTr("Cancel")
                        onClicked: globalDialog.visible = false
                    }

                    Button {
                        text: qsTr("Confirm")
                        onClicked: {
                            globalDialog.visible = false
                            globalDialog.confirmed()
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        showNotification(qsTr("Quantum Enterprise Architecture fully operational."))
    }
}
