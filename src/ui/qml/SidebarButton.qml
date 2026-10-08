import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: button

    property string voLabel: ""
    property bool voSelected: false
    property bool compact: false
    property url iconSource: ""

    implicitHeight: compact ? 46 : 48
    implicitWidth: parent ? parent.width : 200

    background: Rectangle {
        anchors.fill: parent
        anchors.leftMargin: compact ? 9 : 12
        anchors.rightMargin: compact ? 9 : 12
        radius: 11
        color: button.voSelected ? "#00e5ff12" : (button.hovered ? "#101a24" : "transparent")
        border.color: button.voSelected ? "#00e5ff35" : "transparent"
        border.width: button.voSelected ? 1 : 0

        Behavior on color { ColorAnimation { duration: 140 } }
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: compact ? 17 : 17
        anchors.rightMargin: compact ? 17 : 13
        spacing: 12

        Image {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            source: button.iconSource
            opacity: button.voSelected ? 1 : 0.65
            fillMode: Image.PreserveAspectFit
        }

        Text {
            visible: !compact
            Layout.fillWidth: true
            text: button.voLabel
            color: button.voSelected ? "#eaf8fc" : "#74889c"
            font.pixelSize: 12
            font.bold: button.voSelected
            elide: Text.ElideRight

            Behavior on color { ColorAnimation { duration: 140 } }
        }

        Rectangle {
            visible: !compact && button.voSelected
            width: 4
            height: 18
            radius: 2
            color: "#00e5ff"
        }
    }

    ToolTip.visible: compact && hovered
    ToolTip.text: voLabel
    ToolTip.delay: 500
}
