import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: root
    color: "#0b121a"
    implicitWidth: 640
    implicitHeight: backupColumn.implicitHeight + 40
    radius: 16
    border.color: "#1b2b3a"
    border.width: 1

    property string saveDirPath: saveBackupManager.saveDirPath
    property string backupDestinationPath: saveBackupManager.backupDestinationPath
    property string pendingRestorePath: ""
    property string pendingRestoreTarget: ""
    readonly property bool isPersian: trManager.currentLanguage === "fa"

    function refreshAutoSaveConfiguration() {
        saveBackupManager.configureAutoSave(saveDirPath, backupDestinationPath)
        saveBackupManager.autoSaveIntervalSeconds = intervalSpinBox.value
        saveBackupManager.autoSaveEnabled = autoSaveSwitch.checked
                && saveDirPath.length > 0 && backupDestinationPath.length > 0
    }

    onSaveDirPathChanged: savePathField.text = saveDirPath
    onBackupDestinationPathChanged: backupPathField.text = backupDestinationPath

    FolderDialog {
        id: saveFolderDialog
        title: root.isPersian ? "انتخاب پوشهٔ سیو بازی" : "Choose game save folder"
        onAccepted: {
            root.saveDirPath = selectedFolder.toLocalFile()
            root.refreshAutoSaveConfiguration()
        }
    }

    FolderDialog {
        id: backupFolderDialog
        title: root.isPersian ? "انتخاب مقصد بکاپ" : "Choose backup destination"
        onAccepted: {
            root.backupDestinationPath = selectedFolder.toLocalFile()
            root.refreshAutoSaveConfiguration()
        }
    }

    MessageDialog {
        id: restoreConfirmation
        title: root.isPersian ? "تأیید بازگردانی سیو" : "Confirm save restore"
        text: root.isPersian
              ? "بازگردانی، پوشهٔ سیو فعلی را جایگزین می‌کند. قبل از ادامه مطمئن شو."
              : "Restoring replaces the current save folder. Make sure you want to continue."
        buttons: MessageDialog.Yes | MessageDialog.Cancel
        onAccepted: {
            statusText.text = root.isPersian ? "در حال بازگردانی…" : "Restoring backup…"
            statusText.color = "#00e5ff"
            saveBackupManager.restoreBackup(root.pendingRestorePath, root.pendingRestoreTarget)
        }
    }

    Connections {
        target: saveBackupManager
        function onBackupCompleted(success, message) {
            statusText.text = message
            statusText.color = success ? "#38d996" : "#ff6878"
        }
        function onAutoSaveEnabledChanged(enabled) {
            autoSaveSwitch.checked = enabled
        }
        function onAutoSaveIntervalChanged(seconds) {
            intervalSpinBox.value = seconds
        }
        function onMaxBackupsChanged(count) {
            maxBackupsSpinBox.value = count
        }
        function onPathsChanged() {
            root.saveDirPath = saveBackupManager.saveDirPath
            root.backupDestinationPath = saveBackupManager.backupDestinationPath
        }
    }

    ColumnLayout {
        id: backupColumn
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: 12
                color: "#00e5ff12"
                border.color: "#00e5ff2a"
                Text {
                    anchors.centerIn: parent
                    text: "↻"
                    color: "#00e5ff"
                    font.pixelSize: 23
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Text {
                    text: root.isPersian ? "پشتیبان‌گیری از سیوها" : "Save backups"
                    color: "#edf5fa"
                    font.pixelSize: 17
                    font.bold: true
                }
                Text {
                    text: root.isPersian
                          ? "پوشهٔ سیو و مقصد امن بکاپ را مشخص کن."
                          : "Choose a save folder and a safe backup destination."
                    color: "#8194a7"
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#1b2b3a"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 7

            Text {
                text: root.isPersian ? "پوشهٔ سیو بازی" : "Game save folder"
                color: "#b9c8d5"
                font.pixelSize: 11
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                TextField {
                    id: savePathField
                    Layout.fillWidth: true
                    placeholderText: root.isPersian ? "مسیر پوشهٔ سیو" : "Path to save folder"
                    text: root.saveDirPath
                    color: "#edf5fa"
                    placeholderTextColor: "#5f7387"
                    selectByMouse: true
                    onEditingFinished: {
                        root.saveDirPath = text.trim()
                        root.refreshAutoSaveConfiguration()
                    }
                    background: Rectangle {
                        radius: 9
                        color: "#080e14"
                        border.color: savePathField.activeFocus ? "#00e5ff70" : "#233545"
                    }
                }
                Button {
                    text: "…"
                    implicitWidth: 40
                    implicitHeight: 38
                    onClicked: saveFolderDialog.open()
                    background: Rectangle {
                        radius: 9
                        color: parent.hovered ? "#142533" : "#0d1721"
                        border.color: "#2a3d4e"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#dce8ef"
                        font.pixelSize: 19
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: root.isPersian ? "انتخاب پوشه" : "Browse folder"
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 7

            Text {
                text: root.isPersian ? "مقصد پشتیبان‌گیری" : "Backup destination"
                color: "#b9c8d5"
                font.pixelSize: 11
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                TextField {
                    id: backupPathField
                    Layout.fillWidth: true
                    placeholderText: root.isPersian ? "مسیر ذخیرهٔ بکاپ‌ها" : "Path for backups"
                    text: root.backupDestinationPath
                    color: "#edf5fa"
                    placeholderTextColor: "#5f7387"
                    selectByMouse: true
                    onEditingFinished: {
                        root.backupDestinationPath = text.trim()
                        root.refreshAutoSaveConfiguration()
                    }
                    background: Rectangle {
                        radius: 9
                        color: "#080e14"
                        border.color: backupPathField.activeFocus ? "#00e5ff70" : "#233545"
                    }
                }
                Button {
                    text: "…"
                    implicitWidth: 40
                    implicitHeight: 38
                    onClicked: backupFolderDialog.open()
                    background: Rectangle {
                        radius: 9
                        color: parent.hovered ? "#142533" : "#0d1721"
                        border.color: "#2a3d4e"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#dce8ef"
                        font.pixelSize: 19
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: root.isPersian ? "انتخاب پوشه" : "Browse folder"
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#0a1017"
            border.color: "#1b2b3a"
            implicitHeight: optionsColumn.implicitHeight + 24

            ColumnLayout {
                id: optionsColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text {
                            text: root.isPersian ? "پشتیبان‌گیری خودکار" : "Automatic backups"
                            color: "#e3edf4"
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: root.isPersian
                                  ? "تا وقتی برنامه باز است، طبق بازهٔ تعیین‌شده بکاپ می‌گیرد."
                                  : "Creates backups on the selected interval while VoidOne is running."
                            color: "#75899c"
                            font.pixelSize: 10
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    Switch {
                        id: autoSaveSwitch
                        checked: saveBackupManager.autoSaveEnabled
                        onToggled: {
                            if (checked && (root.saveDirPath.length === 0 || root.backupDestinationPath.length === 0)) {
                                checked = false
                                statusText.text = root.isPersian
                                        ? "ابتدا هر دو مسیر را مشخص کن."
                                        : "Choose both folders before enabling automatic backups."
                                statusText.color = "#f5b84b"
                            }
                            root.refreshAutoSaveConfiguration()
                        }
                        indicator: Rectangle {
                            implicitWidth: 42
                            implicitHeight: 24
                            x: autoSaveSwitch.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: 12
                            color: autoSaveSwitch.checked ? "#00b8ce" : "#17232e"
                            border.color: autoSaveSwitch.checked ? "#00e5ff" : "#3a4b5a"
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                y: 3
                                x: autoSaveSwitch.checked ? parent.width - width - 3 : 3
                                color: autoSaveSwitch.checked ? "#041015" : "#8ca0b1"
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#182735" }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 6
                    columnSpacing: 12

                    Text {
                        text: root.isPersian ? "فاصلهٔ بکاپ (ثانیه)" : "Backup interval (seconds)"
                        color: "#a9bac8"
                        font.pixelSize: 11
                    }
                    SpinBox {
                        id: intervalSpinBox
                        Layout.fillWidth: true
                        from: 5
                        to: 3600
                        value: saveBackupManager.autoSaveIntervalSeconds
                        editable: true
                        onValueModified: root.refreshAutoSaveConfiguration()
                    }

                    Text {
                        text: root.isPersian ? "حداکثر نسخه‌های نگه‌داری‌شده" : "Maximum backups to keep"
                        color: "#a9bac8"
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    SpinBox {
                        id: maxBackupsSpinBox
                        Layout.fillWidth: true
                        from: 1
                        to: 1000
                        value: saveBackupManager.maxBackups
                        editable: true
                        onValueModified: saveBackupManager.maxBackups = value
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: statusText.implicitHeight + 18
            radius: 9
            color: "#080e14"
            border.color: "#1b2b3a"
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                Rectangle {
                    width: 7
                    height: 7
                    radius: 4
                    color: statusText.color
                }
                Text {
                    id: statusText
                    Layout.fillWidth: true
                    text: root.isPersian ? "آمادهٔ پشتیبان‌گیری" : "Ready to create a backup"
                    color: "#8ba0b2"
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Button {
                Layout.fillWidth: true
                implicitHeight: 40
                text: root.isPersian ? "ایجاد بکاپ" : "Create backup"
                onClicked: {
                    root.saveDirPath = savePathField.text.trim()
                    root.backupDestinationPath = backupPathField.text.trim()
                    root.refreshAutoSaveConfiguration()
                    if (!root.saveDirPath.length || !root.backupDestinationPath.length) {
                        statusText.text = root.isPersian
                                ? "مسیر سیو و مقصد بکاپ را مشخص کن."
                                : "Choose both the save folder and backup destination."
                        statusText.color = "#f5b84b"
                        return
                    }
                    saveBackupManager.createBackup(root.saveDirPath, root.backupDestinationPath)
                }
                background: Rectangle {
                    radius: 9
                    color: parent.down ? "#00b8ce" : (parent.hovered ? "#27eaff" : "#00d8ef")
                }
                contentItem: Text {
                    text: parent.text
                    color: "#041015"
                    font.pixelSize: 11
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Button {
                Layout.fillWidth: true
                implicitHeight: 40
                text: root.isPersian ? "بازگردانی آخرین بکاپ" : "Restore latest backup"
                onClicked: {
                    root.saveDirPath = savePathField.text.trim()
                    root.backupDestinationPath = backupPathField.text.trim()
                    root.refreshAutoSaveConfiguration()
                    if (!root.saveDirPath.length || !root.backupDestinationPath.length) {
                        statusText.text = root.isPersian
                                ? "مسیر سیو و مقصد بکاپ را مشخص کن."
                                : "Choose both folders before restoring."
                        statusText.color = "#f5b84b"
                        return
                    }
                    const latest = saveBackupManager.latestBackupPath(root.backupDestinationPath)
                    if (!latest.length) {
                        statusText.text = root.isPersian ? "هیچ بکاپی پیدا نشد." : "No backup was found."
                        statusText.color = "#ff6878"
                        return
                    }
                    root.pendingRestorePath = latest
                    root.pendingRestoreTarget = root.saveDirPath
                    restoreConfirmation.open()
                }
                background: Rectangle {
                    radius: 9
                    color: parent.hovered ? "#142533" : "#0b121a"
                    border.color: "#2a3d4e"
                }
                contentItem: Text {
                    text: parent.text
                    color: "#c4d2dd"
                    font.pixelSize: 11
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
