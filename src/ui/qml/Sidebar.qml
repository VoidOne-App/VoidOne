import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0a0f16"
    clip: true

    property bool compact: false
    property string currentPage: "home"
    signal pageChanged(string page)

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 18
        anchors.bottomMargin: 16
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: compact ? 18 : 20
            Layout.rightMargin: compact ? 18 : 16
            spacing: 10

            Rectangle {
                width: 40
                height: 40
                radius: 12
                color: "#00e5ff12"
                border.color: "#00e5ff38"

                Image {
                    anchors.centerIn: parent
                    width: 27
                    height: 27
                    source: "qrc:/qt/qml/VoidOne.App/assets/branding/voidone-mark.svg"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }

            ColumnLayout {
                visible: !compact
                Layout.fillWidth: true
                spacing: 1
                Text {
                    text: "VOIDONE"
                    color: "#eef5fa"
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 1.4
                }
                Text {
                    text: qsTr("PLAYER PLATFORM")
                    color: "#506477"
                    font.pixelSize: 8
                    font.bold: true
                    font.letterSpacing: 1.2
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            height: 1
            color: "#162432"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            SidebarButton {
                Layout.fillWidth: true
                compact: root.compact
                iconSource: "qrc:/qt/qml/VoidOne.App/assets/ui/icons/home.svg"
                voLabel: qsTr("Home")
                voSelected: root.currentPage === "home"
                onClicked: root.pageChanged("home")
            }

            SidebarButton {
                Layout.fillWidth: true
                compact: root.compact
                iconSource: "qrc:/qt/qml/VoidOne.App/assets/ui/icons/library.svg"
                voLabel: qsTr("Library")
                voSelected: root.currentPage === "library"
                onClicked: root.pageChanged("library")
            }

            SidebarButton {
                Layout.fillWidth: true
                compact: root.compact
                iconSource: "qrc:/qt/qml/VoidOne.App/assets/ui/icons/activity.svg"
                voLabel: qsTr("Activity")
                voSelected: root.currentPage === "activity"
                onClicked: root.pageChanged("activity")
            }
        }

        Item { Layout.fillHeight: true }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            height: 1
            color: "#162432"
        }

        SidebarButton {
            Layout.fillWidth: true
            compact: root.compact
            iconSource: "qrc:/qt/qml/VoidOne.App/assets/ui/icons/settings.svg"
            voLabel: qsTr("Settings")
            voSelected: root.currentPage === "settings"
            onClicked: root.pageChanged("settings")
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            implicitHeight: compact ? 52 : 66
            radius: 13
            color: "#0d151e"
            border.color: "#172635"

            RowLayout {
                anchors.fill: parent
                anchors.margins: compact ? 8 : 11
                spacing: 9

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: "#00e5ff12"
                    Text {
                        anchors.centerIn: parent
                        text: "MK"
                        color: "#00e5ff"
                        font.pixelSize: 9
                        font.bold: true
                    }
                }

                ColumnLayout {
                    visible: !compact
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        text: qsTr("Local player")
                        color: "#d9e4ec"
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Offline mode")
                        color: "#4e6578"
                        font.pixelSize: 9
                    }
                }
            }
        }
    }
}
