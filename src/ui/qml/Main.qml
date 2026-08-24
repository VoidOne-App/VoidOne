/****************************************************************************
**  V O I D O N E   E N G I N E   -   B E T A   1
**  Commercial UI Architecture
**  Copyright (C) 2026 VoidOne-App | SPDX-License-Identifier: MIT
****************************************************************************/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls

Window {
    id: root

    width: 1280
    height: 720
    minimumWidth: 960
    minimumHeight: 540
    visible: true
    title: "VoidOne Engine"

    color: theme.background

    // ---------------------------------------------------------
    // 1. Centralized Theme Engine
    // ---------------------------------------------------------
    QtObject {
        id: theme
        property color background: "#0a0d12"
        property color surface: "#12161f"
        property color primary: "#00ffee"
        property color primaryTransparent: "#2000ffee"
        property color textPrimary: "#ffffff"
        property color textSecondary: "#8a95a5"
        property color danger: "#ff3366"
        property int radiusBase: 8
    }

    // Dynamic RTL support (applies mirroring only when an RTL language like Persian or Arabic is active)
    LayoutMirroring.enabled: typeof trManager !== "undefined" && trManager !== null ? (trManager.currentLanguage === "fa" || trManager.currentLanguage === "ar") : false
    LayoutMirroring.childrenInherit: true

    property string currentPage: "library"

    // ---------------------------------------------------------
    // 2. Global Toast Notification System
    // ---------------------------------------------------------
    function showNotification(message, isError = false) {
        toastText.text = message
        toastBg.color = isError ? theme.danger : theme.primary
        toastAnim.restart()
    }

    // Main layout container
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ---------------------------------------------------------
        // 3. Header / Top Bar
        // ---------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: theme.surface
            z: 10

            Rectangle {
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: theme.primaryTransparent
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 20

                TextField {
                    id: searchInput
                    Layout.preferredWidth: 250
                    Layout.preferredHeight: 36
                    placeholderText: qsTr("Search games...")
                    color: theme.textPrimary
                    placeholderTextColor: theme.textSecondary
                    selectByMouse: true
                    
                    background: Rectangle {
                        color: theme.background
                        radius: theme.radiusBase
                        border.color: searchInput.activeFocus ? theme.primary : theme.primaryTransparent
                        border.width: 1
                    }
                    
                    onTextChanged: {
                        if (typeof gameModel !== "undefined" && gameModel !== null && typeof gameModel.filter === "function") {
                            gameModel.filter(text)
                        }
                    }
                }

                Item { Layout.fillWidth: true } // Spacer

                RowLayout {
                    spacing: 12

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: typeof networkManager !== "undefined" && networkManager !== null && networkManager.isOnline ? "#00ff66" : "#ffcc00"

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.3; duration: 1000; easing.type: Easing.InOutQuad }
                            NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
                        }
                    }

                    Text {
                        text: "VoidUser"
                        color: theme.textPrimary
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: theme.primaryTransparent
                        border.color: theme.primary
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "V"
                            color: theme.primary
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }
                }
            }
        }

        // Main content body (Sidebar + View Stack)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Sidebar {
                id: sidebar
                Layout.preferredWidth: 250
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
            // 4. Page Management (StackLayout)
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

                // --- Library View ---
                Item {
                    id: libraryPage
                    
                    GridView {
                        id: gameGrid
                        anchors.fill: parent
                        anchors.margins: 20
                        cellWidth: 300
                        cellHeight: 210
                        clip: true
                        
                        model: typeof gameModel !== "undefined" && gameModel !== null ? gameModel : null

                        delegate: GameCard {
                            gameId: model.id !== undefined ? model.id : 0
                            gameName: model.name !== undefined ? model.name : "Unknown Game"
                            exePath: model.exePath !== undefined ? model.exePath : ""
                            iconPath: model.iconPath !== undefined ? model.iconPath : ""
                            platform: model.platform !== undefined ? model.platform : "Custom"
                            itemIndex: index

                            onLaunchRequested: function(path) {
                                root.showNotification(qsTr("Launching game..."))
                                if (typeof gameManager !== "undefined" && gameManager !== null && typeof gameManager.launchGame === "function") {
                                    gameManager.launchGame(path)
                                }
                            }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Your library is empty.\nScan for games to get started.")
                        color: theme.textSecondary
                        font.pixelSize: 16
                        lineHeight: 1.3
                        horizontalAlignment: Text.AlignHCenter
                        visible: gameGrid.count === 0
                    }
                }

                // --- Marketplace View ---
                Item {
                    id: marketplacePage
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("🛒 Marketplace under construction...")
                        color: theme.primary
                        font.pixelSize: 22
                        font.bold: true
                    }
                }

                // --- Settings View ---
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
    // 5. Global Toast UI Layer
    // ---------------------------------------------------------
    Rectangle {
        id: toastBg
        width: toastText.implicitWidth + 40
        height: 42
        radius: theme.radiusBase
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        
        opacity: 0
        visible: opacity > 0
        z: 99

        Text {
            id: toastText
            anchors.centerIn: parent
            color: "#0a0d12"
            font.bold: true
            font.pixelSize: 14
        }

        SequentialAnimation {
            id: toastAnim
            NumberAnimation { target: toastBg; property: "opacity"; to: 1; duration: 250; easing.type: Easing.OutCubic }
            PauseAnimation { duration: 2800 }
            NumberAnimation { target: toastBg; property: "opacity"; to: 0; duration: 350; easing.type: Easing.InCubic }
        }
    }

    Component.onCompleted: {
        showNotification(qsTr("VoidOne Engine loaded successfully!"))
    }
}
