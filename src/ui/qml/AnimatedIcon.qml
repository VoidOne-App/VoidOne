import QtQuick

// Reusable SVG icon with a restrained hover response; keeps the source asset crisp.
Item {
    id: root
    property url source
    property color tint: "#00e5ff"
    property real iconOpacity: 0.92
    property bool hovered: false
    implicitWidth: 24
    implicitHeight: 24

    Image {
        id: iconImage
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        source: root.source
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        opacity: root.iconOpacity
        scale: root.hovered ? 1.08 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }
    }
}