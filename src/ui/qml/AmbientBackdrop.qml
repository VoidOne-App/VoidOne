import QtQuick

// Lightweight ambient treatment: no timers, particles, shaders, or per-frame work
// when the window is hidden. Motion stays subtle so the launcher remains responsive.
Item {
    id: root
    anchors.fill: parent
    clip: true

    Rectangle {
        id: cyanBloom
        width: Math.min(root.width * 0.62, 720)
        height: width
        radius: width / 2
        x: root.width - width * 0.56
        y: -height * 0.62
        color: "#00e5ff"
        opacity: 0.025

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.045; duration: 4200; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.025; duration: 4200; easing.type: Easing.InOutSine }
        }
    }

    Rectangle {
        width: Math.min(root.width * 0.44, 520)
        height: width
        radius: width / 2
        x: -width * 0.55
        y: root.height - height * 0.45
        color: "#2478ff"
        opacity: 0.018
    }

    // Thin, low-contrast technical lines add depth without competing with content.
    Repeater {
        model: Math.ceil(root.width / 72)
        Rectangle {
            required property int index
            x: index * 72
            y: 0
            width: 1
            height: root.height
            color: "#193042"
            opacity: 0.12
        }
    }

    Repeater {
        model: Math.ceil(root.height / 72)
        Rectangle {
            required property int index
            x: 0
            y: index * 72
            width: root.width
            height: 1
            color: "#193042"
            opacity: 0.09
        }
    }
}