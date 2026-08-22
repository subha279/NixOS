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

    implicitWidth: showSeconds ? 72 : 48
    implicitHeight: Core.Theme.moduleHeight

    property bool showSeconds: false

    readonly property bool menuOpen: Core.PopupManager.isOpen("calendar")

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    SystemClock {
        id: systemClock

        precision: root.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    Rectangle {
        anchors.fill: parent

        radius: height / 2

        color: root.menuOpen ? Core.Theme.surfaceActive : (mouse.containsMouse ? Core.Theme.hover : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    Row {
        anchors.centerIn: parent

        spacing: 0

        Text {
            text: Qt.formatDateTime(systemClock.date, "HH")

            color: root.menuOpen ? Core.Theme.accent : Core.Theme.clockHour

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            renderType: Text.QtRendering

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
        }

        Text {
            text: ":"

            color: root.menuOpen ? Core.Theme.accent : Core.Theme.clockSeparator

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            renderType: Text.QtRendering

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
        }

        Text {
            text: Qt.formatDateTime(systemClock.date, "mm")

            color: root.menuOpen ? Core.Theme.accent : Core.Theme.clockMinute

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            renderType: Text.QtRendering

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
        }

        Text {
            visible: root.showSeconds

            text: ":"

            color: Core.Theme.clockSeparator

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            renderType: Text.QtRendering
        }

        Text {
            visible: root.showSeconds

            text: Qt.formatDateTime(systemClock.date, "ss")

            color: Core.Theme.clockSecond

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            renderType: Text.QtRendering
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function (event) {
            if (event.button === Qt.RightButton) {
                root.showSeconds = !root.showSeconds;
                return;
            }

            const p = root.mapToItem(null, 0, root.height);

            Core.PopupManager.toggle("calendar", p.x + root.width / 2, p.y + Core.Theme.barMarginTop);
        }
    }
}
