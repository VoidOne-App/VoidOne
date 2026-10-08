import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: control
    property string title: ""
    property string subtitle: ""
    property url iconSource: ""

    implicitHeight: 76

    background: Rectangle {
        radius: 14
        color: control.pressed ? "#101d29" : (control.hovered ? "#0f1923" : "#0a1018")
        border.color: control.hovered ? "#00e5ff66" : "#182635"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 140 } }
        Behavior on border.color { ColorAnimation { duration: 140 } }
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.margins: 13
        spacing: 12

        Rectangle {
            width: 40
            height: 40
            radius: 11
            color: "#00e5ff10"

            Image {
                anchors.centerIn: parent
                width: 20
                height: 20
                source: control.iconSource
                fillMode: Image.PreserveAspectFit
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text: control.title
                color: "#e9f2f8"
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                text: control.subtitle
                color: "#60748a"
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }

        Text {
            text: "›"
            color: control.hovered ? "#00e5ff" : "#405365"
            font.pixelSize: 20
        }
    }
}
