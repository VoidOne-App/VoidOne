import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#11151b"
    implicitWidth: 600
    implicitHeight: 450
    radius: 12
    border.color: "#00ffee30"
    border.width: 1

    property string saveDirPath: ""
    property string backupDestinationPath: ""

    function refreshAutoSaveConfiguration() {
        saveBackupManager.configureAutoSave(saveDirPath, backupDestinationPath)
        saveBackupManager.autoSaveIntervalSeconds = intervalSpinBox.value
        saveBackupManager.autoSaveEnabled = autoSaveSwitch.checked && saveDirPath.length > 0 && backupDestinationPath.length > 0
    }

    Connections {
        target: saveBackupManager
        function onBackupCompleted(success, message) {
            statusText.text = message
            statusText.color = success ? "#00ffee" : "#ef4444"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Header & Language Switcher
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "💾 " + (trManager.currentLanguage === "fa" ? "پشتیبان‌گیری و ذخیره خودکار سیو" : "Save Backup & Auto-Save")
                color: "#00ffee"
                font.pixelSize: 18
                font.bold: true
                renderType: Text.NativeRendering
            }

            Item { Layout.fillWidth: true }

            // Language Toggle Button
            Button {
                text: trManager.currentLanguage === "en" ? "FA / فارسی" : "EN / English"
                background: Rectangle {
                    color: "#00ffee20"
                    border.color: "#00ffee"
                    border.width: 1
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: "#00ffee"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
                onClicked: {
                    trManager.currentLanguage = (trManager.currentLanguage === "en") ? "fa" : "en"
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#00ffee20"
        }

        // Settings Form Layout
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            rowSpacing: 15
            columnSpacing: 15

            // Auto Save Switch Label
            Text {
                text: trManager.currentLanguage === "fa" ? "فعال‌سازی ذخیره خودکار لحظه‌ای:" : "Enable Real-Time Auto-Save:"
                color: "#00ffee80"
                font.pixelSize: 14
            }

            // Custom Switch
            Switch {
                id: autoSaveSwitch
                checked: false
                onCheckedChanged: {
                    root.refreshAutoSaveConfiguration()
                    statusText.color = "#00ffee"
                    statusText.text = checked
                        ? (trManager.currentLanguage === "fa" ? "وضعیت: ذخیره خودکار فعال شد" : "Status: Auto-save enabled")
                        : (trManager.currentLanguage === "fa" ? "وضعیت: ذخیره خودکار غیرفعال شد" : "Status: Auto-save disabled")
                }
                indicator: Rectangle {
                    implicitWidth: 48
                    implicitHeight: 24
                    x: autoSaveSwitch.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: 12
                    color: autoSaveSwitch.checked ? "#00ffee" : "#1a222d"
                    border.color: "#00ffee"
                    border.width: 1

                    Rectangle {
                        x: autoSaveSwitch.checked ? parent.width - width - 2 : 2
                        y: 2
                        width: 20
                        height: 20
                        radius: 10
                        color: autoSaveSwitch.checked ? "#11151b" : "#00ffee80"
                    }
                }
            }

            // Interval Label
            Text {
                text: trManager.currentLanguage === "fa" ? "بازه زمانی (ثانیه):" : "Interval (Seconds):"
                color: "#00ffee80"
                font.pixelSize: 14
            }

            // Interval SpinBox
            SpinBox {
                id: intervalSpinBox
                from: 5
                to: 3600
                value: 30
                editable: true
                Layout.preferredWidth: 120
                onValueModified: root.refreshAutoSaveConfiguration()
            }

            Text {
                text: trManager.currentLanguage === "fa" ? "مسیر سیو بازی:" : "Save Folder:"
                color: "#00ffee80"
                font.pixelSize: 14
            }

            TextField {
                Layout.fillWidth: true
                placeholderText: trManager.currentLanguage === "fa" ? "مثال: /home/user/Game/Saves" : "Example: /home/user/Game/Saves"
                text: root.saveDirPath
                color: "#f8fafc"
                placeholderTextColor: "#64748b"
                onEditingFinished: {
                    root.saveDirPath = text.trim()
                    root.refreshAutoSaveConfiguration()
                }
            }

            Text {
                text: trManager.currentLanguage === "fa" ? "مقصد بکاپ:" : "Backup Destination:"
                color: "#00ffee80"
                font.pixelSize: 14
            }

            TextField {
                Layout.fillWidth: true
                placeholderText: trManager.currentLanguage === "fa" ? "مثال: /home/user/VoidOneBackups" : "Example: /home/user/VoidOneBackups"
                text: root.backupDestinationPath
                color: "#f8fafc"
                placeholderTextColor: "#64748b"
                onEditingFinished: {
                    root.backupDestinationPath = text.trim()
                    root.refreshAutoSaveConfiguration()
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Action Status / Message Box
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#0a0d12"
            border.color: "#00ffee30"
            radius: 8

            Text {
                id: statusText
                anchors.centerIn: parent
                text: trManager.currentLanguage === "fa" ? "وضعیت: آماده برای پایش و پشتیبان‌گیری..." : "Status: Ready for backup monitoring..."
                color: "#00ffee"
                font.pixelSize: 12
            }
        }

        // Manual Backup Action Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Button {
                Layout.fillWidth: true
                height: 40
                background: Rectangle {
                    color: parent.pressed ? "#00cccc" : "#00ffee20"
                    border.color: "#00ffee"
                    radius: 8
                }
                contentItem: Text {
                    text: trManager.currentLanguage === "fa" ? "ایجاد بکاپ الان" : "Create Backup Now"
                    color: "#00ffee"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
                onClicked: {
                    root.saveDirPath = root.saveDirPath.trim()
                    root.backupDestinationPath = root.backupDestinationPath.trim()

                    if (root.saveDirPath.length === 0 || root.backupDestinationPath.length === 0) {
                        statusText.color = "#f59e0b"
                        statusText.text = trManager.currentLanguage === "fa"
                            ? "وضعیت: مسیر سیو و مقصد بکاپ را وارد کنید"
                            : "Status: Enter both save and backup paths"
                        return
                    }

                    saveBackupManager.createBackup(root.saveDirPath, root.backupDestinationPath)
                }
            }

            Button {
                Layout.fillWidth: true
                height: 40
                background: Rectangle {
                    color: "transparent"
                    border.color: "#00ffee50"
                    radius: 8
                }
                contentItem: Text {
                    text: trManager.currentLanguage === "fa" ? "بازگردانی بکاپ" : "Restore Backup"
                    color: "#00ffee80"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    root.saveDirPath = root.saveDirPath.trim()
                    root.backupDestinationPath = root.backupDestinationPath.trim()

                    if (root.saveDirPath.length === 0 || root.backupDestinationPath.length === 0) {
                        statusText.color = "#f59e0b"
                        statusText.text = trManager.currentLanguage === "fa"
                            ? "وضعیت: مسیر سیو و مقصد بکاپ را وارد کنید"
                            : "Status: Enter both save and backup paths"
                        return
                    }

                    statusText.text = trManager.currentLanguage === "fa" ? "وضعیت: در حال بازگردانی بکاپ..." : "Status: Restoring backup..."
                    statusText.color = "#00ffee"
                    saveBackupManager.restoreBackup(root.backupDestinationPath, root.saveDirPath)
                }
            }
        }
    }
}
