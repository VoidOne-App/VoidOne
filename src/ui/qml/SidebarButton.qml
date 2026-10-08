import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: button
    property string voIcon: ""
    property string voLabel: ""
    property bool voSelected: false
    property string voBadge: ""
    property bool voCompact: false

    implicitHeight: voCompact ? 38 : 46
    implicitWidth: parent ? parent.width : 200

    background: Rectangle {
        color: voSelected ? "#00ffee20" : (button.hovered ? "#00ffee10" : "transparent")
        radius: 10
        border.color: selected ? "#00ffee" : "transparent"
        border.width: selected ? 1.5 : 0

        Behavior on color { ColorAnimation { duration: 120 } }
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Text {
            text: voIcon
            font.pixelSize: voCompact ? 14 : 18
        }

        Text {
            Layout.fillWidth: true
            text: voLabel
            color: selected ? "#00ffee" : "#00ffee80"
            font.pixelSize: 13
            font.bold: voSelected
            elide: Text.ElideRight
        }
    }
}
