/****************************************************************************
**  V O I D O N E   E N G I N E
**  Copyright (C) 2026 VoidOne-App | SPDX-License-Identifier: MIT
****************************************************************************/

import QtQuick
import QtQuick.Window

Window {
    id: root

    width: 1280
    height: 720
    minimumWidth: 960
    minimumHeight: 540
    visible: true

    title: "VoidOne Engine"
    
    // استفاده از رنگ پس‌زمینه هماهنگ با Sidebar
    color: "#0a0d12"

    Rectangle {
        anchors.fill: parent
        color: "#0a0d12"

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "V O I D O N E"
                font.pixelSize: 52
                font.bold: true
                color: "#00ffee" // رنگ اصلی برند شما
                style: Text.Outline
                styleColor: "#0088aa"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Engine is running and ready."
                font.pixelSize: 18
                color: "#9aa4b2"
            }

            // دکمه READY با استایل مدرن‌تر و قابلیت هاور (Hover)
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 200
                height: 50
                radius: 12
                
                // تغییر رنگ با کلیک شدن
                color: readyArea.pressed ? "#00cccc" : "#00ffee"
                border.color: "#00ffee"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "READY"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#0a0d12"
                }

                MouseArea {
                    id: readyArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                }
            }
        }
    }
}
