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

    contentItem: Item {
        Image {
            id: navIcon
            x: button.compact ? (parent.width - width) / 2 : 17
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            source: button.iconSource
            opacity: button.voSelected ? 1 : 0.68
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
        }

        Text {
            visible: !button.compact
            anchors.left: navIcon.right
            anchors.leftMargin: 12
            anchors.right: selectedMarker.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: button.voLabel
            color: button.voSelected ? "#eaf8fc" : "#8193a5"
            font.pixelSize: 12
            font.bold: button.voSelected
            elide: Text.ElideRight

            Behavior on color { ColorAnimation { duration: 140 } }
        }

        Rectangle {
            id: selectedMarker
            visible: !button.compact && button.voSelected
            anchors.right: parent.right
            anchors.rightMargin: 13
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: 18
            radius: 2
            color: "#00e5ff"
        }
    }

    ToolTip.visible: compact && hovered
    ToolTip.text: voLabel
    ToolTip.delay: 500
}
