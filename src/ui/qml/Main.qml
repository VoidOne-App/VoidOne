import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1600
    height: 900
    title: trManager.getText("app_title")
    color: "#090c10"
    flags: Qt.Window

    property string currentPage: "library"
    property string searchQuery: ""

    // دریافت سیگنال اتمام اسکن استیم از backend
    Connections {
        target: steamScanner
        function onScanCompleted(foundCount) {
            showNotification(trManager.currentLanguage === "fa" 
                ? "اسکن کامل شد! " + foundCount + " بازی پیدا شد." 
                : "Scan complete! Found " + foundCount + " games.")
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Sidebar {
            id: sidebar
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            onPageChanged: (page) => currentPage = page
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: {
                switch(currentPage) {
                    case "library": return 0
                    case "marketplace": return 1
                    case "settings": return 2
                    default: return 0
                }
            }

            // صفحه کتابخانه بازی‌ها
            Rectangle {
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    // نوار جستجو و اسکن
                    Rectangle {
                        Layout.fillWidth: true
                        height: 50
                        color: "#111827"
                        radius: 12
                        border.color: "#00ffee"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            Text {
                                text: "🔍"
                                font.pixelSize: 18
                            }

                            TextField {
                                id: searchField
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                placeholderText: trManager.currentLanguage === "fa" ? "جستجوی بازی‌ها..." : "Search games..."
                                background: Rectangle { color: "transparent" }
                                color: "#00ffee"
                                placeholderTextColor: "#00ffee80"
                                font.pixelSize: 14
                                onTextChanged: searchQuery = text
                            }

                            // دکمه اسکن استیم
                            Button {
                                text: "🔄 " + trManager.getText("scan_steam")
                                implicitHeight: 36
                                background: Rectangle {
                                    color: parent.hovered ? "#00ffee40" : "#00ffee20"
                                    border.color: "#00ffee"
                                    radius: 8
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#00ffee"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    steamScanner.startAsyncScan()
                                    showNotification(trManager.currentLanguage === "fa" ? "در حال اسکن کتابخانه استیم..." : "Scanning Steam library...")
                                }
                            }
                        }
                    }

                    // نوار فیلتر و آمار
                    RowLayout {
                        Layout.fillWidth: true
                        height: 40
                        spacing: 10

                        ComboBox {
                            model: [trManager.currentLanguage === "fa" ? "همه بازی‌ها" : "All Games", "Favorites", "Recent"]
                            background: Rectangle {
                                color: "#111827"
                                radius: 8
                                border.color: "#00ffee"
                                border.width: 1
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: gamesGrid.count + (trManager.currentLanguage === "fa" ? " بازی موجود" : " games available")
                            color: "#00ffee"
                            font.pixelSize: 13
                        }
                    }

                    // شبکه نمایش بازی‌ها
                    GridView {
                        id: gamesGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        cellWidth: 300
                        cellHeight: 220
                        cacheBuffer: 600
                        model: gameModel

                        delegate: GameCard {
                            gameId: model.id
                            gameName: model.name
                            exePath: model.exePath
                            iconPath: model.iconPath
                            platform: model.platform
                            itemIndex: index
                        }

                        BusyIndicator {
                            anchors.centerIn: parent
                            running: gamesGrid.count === 0
                            visible: running
                        }

                        flickDeceleration: 3000
                        maximumFlickVelocity: 4000
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    }
                }
            }

            // Marketplace
            Rectangle {
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: trManager.currentLanguage === "fa" ? "فروشگاه به زودی..." : "Marketplace Coming Soon"
                    color: "#00ffee"
                    font.pixelSize: 24
                }
            }

            // تنظیمات
            SettingsPage {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    // پنل اعلانات (Toast Notification)
    Rectangle {
        id: notificationPanel
        x: parent.width - 340
        y: 20
        width: 320
        height: 70
        color: "#111827"
        radius: 12
        border.color: "#00ffee"
        border.width: 1.5
        visible: false
        z: 1000

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text { text: "🔔"; font.pixelSize: 20 }
            Text {
                id: notificationText
                Layout.fillWidth: true
                color: "#00ffee"
                wrapMode: Text.WordWrap
                font.pixelSize: 13
            }
        }

        Timer {
            id: notificationTimer
            interval: 3500
            onTriggered: notificationPanel.visible = false
        }
    }

    function showNotification(message) {
        notificationText.text = message
        notificationPanel.visible = true
        notificationTimer.restart()
    }
}
