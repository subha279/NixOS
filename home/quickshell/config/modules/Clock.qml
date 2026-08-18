import QtQuick

import Quickshell

import "../core" as Core

// ================================================================
// Clock (bar module)
// ----------------------------------------------------------------
// This is the one module that is always visible. Everything else
// in the pill folds away until you hover it.
//
// Left click  : open the calendar dropdown
// Right click : toggle a seconds readout
// ================================================================

Item {
    id: root

    implicitWidth: showSeconds ? 66 : 48
    implicitHeight: Core.Theme.moduleHeight

    property bool showSeconds: false

    readonly property bool menuOpen:
        Core.PopupManager.isOpen("calendar")

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    SystemClock {
        id: systemClock

        precision: root.showSeconds
            ? SystemClock.Seconds
            : SystemClock.Minutes
    }

    Rectangle {
        anchors.fill: parent

        radius: height / 2

        color: root.menuOpen
            ? Core.Theme.surfaceActive
            : (mouse.containsMouse
                ? Core.Theme.hover
                : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    Text {
        anchors.centerIn: parent

        text: Qt.formatDateTime(
            systemClock.date,
            root.showSeconds ? "HH:mm:ss" : "HH:mm"
        )

        color: root.menuOpen
            ? Core.Theme.accent
            : Core.Theme.foreground

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        font.family: Core.Theme.fontFamily
        font.pixelSize: Core.Theme.fontSize
        font.weight: Font.Medium

        renderType: Text.QtRendering
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        acceptedButtons:
            Qt.LeftButton | Qt.RightButton

        onClicked: function(event) {

            if (event.button === Qt.RightButton) {
                root.showSeconds = !root.showSeconds
                return
            }

            const p = root.mapToItem(null, 0, root.height)

            Core.PopupManager.toggle(
                "calendar",
                p.x + root.width / 2,
                p.y + Core.Theme.barMarginTop
            )
        }
    }
}
