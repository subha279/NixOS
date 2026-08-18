import QtQuick
import QtQuick.Layouts

import Quickshell

import "../core" as Core
import "../services" as Services

// ================================================================
// Brightness (bar module)
// ----------------------------------------------------------------
// Pure view. The brightnessctl process, the poll and the level all
// moved to services/BrightnessService.qml so the OSD can observe
// brightness without the bar module having to be alive.
//
// Behaviour is unchanged: wheel or click steps by 5%.
// ================================================================

Item {
    id: root

    implicitWidth: 58
    implicitHeight: Core.Theme.moduleHeight

    readonly property int level: Services.BrightnessService.level

    Rectangle {
        anchors.fill: parent

        radius: height / 2

        color: mouse.containsMouse ? Core.Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    RowLayout {
        anchors.centerIn: parent

        spacing: 5

        Text {
            // Ramps with the level instead of showing the same sun
            // at 5% and at 100%.
            text: Core.Icons.forBrightness(Services.BrightnessService.fraction)

            font.family: Core.Theme.fontFamily

            font.pixelSize: Core.Theme.iconSize

            color: Core.Theme.accent
        }

        Text {
            text: root.level + "%"

            font.family: Core.Theme.fontFamily

            font.pixelSize: Core.Theme.fontSize

            font.weight: Font.Medium

            color: Core.Theme.foreground

            renderType: Text.QtRendering
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        acceptedButtons: Qt.LeftButton

        onWheel: function (event) {
            if (event.angleDelta.y === 0)
                return;
            Services.BrightnessService.step(event.angleDelta.y > 0);
        }

        onClicked: Services.BrightnessService.step(true)
    }
}
