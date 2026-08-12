import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "#11151b"
    clip: true
    signal pageChanged(string page)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 90
            color: "#0a0d12"
            border.bottom.color: "#00ffee20"

            Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "🚀 " + trManager.getText("app_title")
                    color: "#00ffee"
                    font.pixelSize: 18
                    font.bold: true
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 6

                SidebarButton {
                    Layout.fillWidth: true
                    icon: "🏠"
                    label: trManager.currentLanguage === "fa" ? "کتابخانه" : "Library"
                    selected: currentPage === "library"
                    onClicked: pageChanged("library")
                }

                SidebarButton {
                    Layout.fillWidth: true
                    icon: "🛒"
                    label: trManager.currentLanguage === "fa" ? "فروشگاه" : "Marketplace"
                    selected: currentPage === "marketplace"
                    onClicked: pageChanged("marketplace")
                }

                SidebarButton {
                    Layout.fillWidth: true
                    icon: "⚙️"
                    label: trManager.getText("settings")
                    selected: currentPage === "settings"
                    onClicked: pageChanged("settings")
                }
            }
        }
    }
}
