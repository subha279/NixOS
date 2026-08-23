import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services

// Battery bar module

Item {
    id: root

    implicitWidth: 58
    implicitHeight: Core.Theme.moduleHeight

    readonly property bool menuOpen: Core.PopupManager.isOpen("battery")

    readonly property var svc: Services.BatteryService

    // Hide the module entirely on desktops with no battery.
    visible: root.svc.available

    Rectangle {
        anchors.fill: parent

        radius: height / 2

        color: root.menuOpen ? Core.Theme.surfaceActive : mouse.containsMouse ? Core.Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 120
                easing.type: Easing.OutQuint
            }
        }
    }

    // Critical-battery breathing glow

    Rectangle {
        anchors.fill: parent

        radius: height / 2

        color: "transparent"

        border.width: 0
        border.color: Core.Theme.danger

        opacity: root.svc.critical ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuint
            }
        }

        SequentialAnimation on scale {
            running: root.svc.critical
            loops: Animation.Infinite

            NumberAnimation {
                to: 1.06
                duration: 700
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                to: 1.0
                duration: 700
                easing.type: Easing.InOutSine
            }
        }
    }

    Row {
        anchors.centerIn: parent

        spacing: 4

        Text {
            id: icon

            anchors.verticalCenter: parent.verticalCenter

            text: root.svc.icon

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.iconSize

            color: root.svc.color

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuint
                }
            }

            // Pop whenever the glyph changes (level crossed, charger plugged in, etc.)
            onTextChanged: popAnim.restart()

            SequentialAnimation {
                id: popAnim

                NumberAnimation {
                    target: icon
                    property: "scale"
                    to: 1.22
                    duration: 110
                    easing.type: Easing.OutQuint
                }

                NumberAnimation {
                    target: icon
                    property: "scale"
                    to: 1.0
                    duration: 160
                    easing.type: Easing.OutQuint
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: root.svc.percentInt + "%"

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            color: root.svc.critical ? Core.Theme.danger : root.svc.low ? Core.Theme.warning : Core.Theme.foreground

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuint
                }
            }
        }
    }

    // Interaction

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: function (event) {
            if (event.button === Qt.MiddleButton) {
                root.cycleProfile();
                return;
            }

            if (event.button === Qt.RightButton) {
                root.svc.openPowerSettings();
                return;
            }

            const p = root.mapToItem(null, 0, root.height);

            Core.PopupManager.toggle("battery", p.x + root.width / 2, p.y + Core.Theme.barMarginTop);
        }

        onWheel: function (event) {
            if (event.angleDelta.y === 0)
                return;
            root.cycleProfile(event.angleDelta.y > 0 ? 1 : -1);
        }
    }

    function cycleProfile(direction) {
        if (!root.svc.profilesAvailable)
            return;
        const step = direction === undefined ? 1 : direction;

        const max = root.svc.hasPerformance ? 2 : 1;

        let next = root.svc.profile + step;

        if (next > max)
            next = 0;

        if (next < 0)
            next = max;

        root.svc.setProfile(next);
    }
}
