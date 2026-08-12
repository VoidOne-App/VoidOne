import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: button
    property string icon: ""
    property string label: ""
    property bool selected: false
    property string badge: ""
    property bool compact: false

    implicitHeight: compact ? 38 : 46
    implicitWidth: parent ? parent.width : 200

    background: Rectangle {
        color: selected ? "#00ffee20" : (button.hovered ? "#00ffee10" : "transparent")
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
            text: icon
            font.pixelSize: compact ? 14 : 18
        }

        Text {
            Layout.fillWidth: true
            text: label
            color: selected ? "#00ffee" : "#00ffee80"
            font.pixelSize: 13
            font.bold: selected
            elide: Text.ElideRight
        }
    }
}
