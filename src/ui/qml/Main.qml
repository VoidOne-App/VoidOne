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
    
    // رنگ پس‌زمینه از سیستم تم خوانده می‌شود
    color: theme.background

    // ---------------------------------------------------------
    // ۱. سیستم تمینگ متمرکز (Business Theming Engine)
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

    // راست‌چین شدن هوشمند برنامه
    LayoutMirroring.enabled: typeof trManager !== "undefined" ? trManager.currentLanguage === "fa" : false
    LayoutMirroring.childrenInherit: true

    property string currentPage: "library"

    // ---------------------------------------------------------
    // ۲. سیستم نوتیفیکیشن تجاری (Toast System)
    // ---------------------------------------------------------
    function showNotification(message, isError = false) {
        toastText.text = message
        toastBg.color = isError ? theme.danger : theme.primary
        toastAnim.restart()
    }

    // لایه اصلی چیدمان
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ---------------------------------------------------------
        // ۳. هدر تجاری (Top Bar: Search, Profile, Status)
        // ---------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: theme.surface
            
            // خط جداکننده زیر هدر
            Rectangle {
                width: parent.width; height: 1
                anchors.bottom: parent.bottom
                color: theme.primaryTransparent
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 20

                // نوار جستجوی زنده (Live Search)
                TextField {
                    Layout.preferredWidth: 250
                    Layout.preferredHeight: 35
                    placeholderText: qsTr("جستجوی بازی...")
                    color: theme.textPrimary
                    background: Rectangle {
                        color: theme.background
                        radius: theme.radiusBase
                        border.color: parent.activeFocus ? theme.primary : theme.primaryTransparent
                    }
                    onTextChanged: {
                        if (typeof gameModel !== "undefined") {
                            // فرض بر این است که متد فیلتر در بک‌اند دارید
                            // gameModel.filter(text)
                        }
                    }
                }

                Item { Layout.fillWidth: true } // Spacer

                // پروفایل کاربر و وضعیت شبکه
                RowLayout {
                    spacing: 10
                    
                    Rectangle {
                        width: 10; height: 10; radius: 5
                        color: typeof networkManager !== "undefined" && networkManager.isOnline ? "#00ff00" : "#ffcc00"
                        
                        // انیمیشن پالس برای وضعیت آنلاین
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.4; duration: 1000 }
                            NumberAnimation { to: 1.0; duration: 1000 }
                        }
                    }

                    Text {
                        text: "VoidUser" // در آینده از بک‌اند خوانده می‌شود
                        color: theme.textPrimary
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    // آواتار کاربر
                    Rectangle {
                        width: 35; height: 35; radius: 17.5
                        color: theme.primaryTransparent
                        border.color: theme.primary
                        Text {
                            anchors.centerIn: parent
                            text: "V"
                            color: theme.primary
                            font.bold: true
                        }
                    }
                }
            }
        }

        // بخش پایینی (سایدبار + محتوا)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Sidebar {
                id: sidebar
                Layout.preferredWidth: 250
                Layout.fillHeight: true
                onPageChanged: (page) => { root.currentPage = page }
            }

            Rectangle {
                Layout.fillHeight: true
                width: 1
                color: theme.primaryTransparent
            }

            // ---------------------------------------------------------
            // ۴. سیستم ترانزیشن نرم (Smooth Page Transitions)
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
                
                // رفتار انیمیشنی هنگام تغییر صفحات
                Behavior on currentIndex {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }

                // --- صفحات ---
                Item {
                    id: libraryPage
                    GridView {
                        id: gameGrid
                        anchors.fill: parent
                        anchors.margins: 20
                        cellWidth: 300
                        cellHeight: 210
                        clip: true
                        model: typeof gameModel !== "undefined" ? gameModel : null

                        delegate: GameCard {
                            gameId: model.id || 0
                            gameName: model.name || "Unknown Game"
                            exePath: model.exePath || ""
                            iconPath: model.iconPath || ""
                            platform: model.platform || "Custom"
                            itemIndex: index
                            
                            // اتصال نوتیفیکیشن به اجرای بازی
                            onLaunchRequested: (path) => {
                                root.showNotification(qsTr("در حال اجرای بازی..."))
                                if (typeof gameManager !== "undefined") gameManager.launchGame(path)
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("کتابخانه خالی است.\nبازی‌های خود را اسکن کنید.")
                            color: theme.textSecondary
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            visible: gameGrid.count === 0
                        }
                    }
                }

                Item {
                    id: marketplacePage
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("🛒 فروشگاه در حال ساخت است...")
                        color: theme.primary
                        font.pixelSize: 24
                        font.bold: true
                    }
                }

                Item {
                    id: settingsPage
                    SaveBackupView { anchors.centerIn: parent }
                }
            }
        }
    }

    // ---------------------------------------------------------
    // ۵. لایه نوتیفیکیشن سراسری (Global Toast UI)
    // ---------------------------------------------------------
    Rectangle {
        id: toastBg
        width: toastText.implicitWidth + 40
        height: 40
        radius: theme.radiusBase
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0 // در حالت عادی مخفی است
        
        Text {
            id: toastText
            anchors.centerIn: parent
            color: "#0a0d12" // متن تیره روی پس‌زمینه روشن
            font.bold: true
            font.pixelSize: 14
        }

        SequentialAnimation {
            id: toastAnim
            NumberAnimation { target: toastBg; property: "opacity"; to: 1; duration: 300; easing.type: Easing.OutCubic }
            PauseAnimation { duration: 3000 }
            NumberAnimation { target: toastBg; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InCubic }
        }
    }
    
    // تست نوتیفیکیشن هنگام لود شدن لانچر
    Component.onCompleted: {
        showNotification(qsTr("موتور VoidOne با موفقیت بارگذاری شد!"))
    }
}
