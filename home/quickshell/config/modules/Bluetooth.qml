import QtQuick

import Quickshell
import Quickshell.Bluetooth

import "../core" as Core

Item {
    id: root

    implicitWidth: 30
    implicitHeight: Core.Theme.moduleHeight

    property var adapter:
        Bluetooth.defaultAdapter

    property bool enabled:
        adapter && adapter.enabled

    property bool connected:
        Bluetooth.devices.count > 0

    Rectangle {
        anchors.fill: parent

        radius: height / 2

        color:
            mouse.containsMouse
                ? Core.Theme.hover
                : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    Text {
        anchors.centerIn: parent

        text: "󰂯"

        font.family:
            Core.Theme.fontFamily

        font.pixelSize:
            Core.Theme.iconSize

        color:
            !root.enabled
                ? Core.Theme.foregroundMuted
                : root.connected
                    ? Core.Theme.accent
                    : Core.Theme.foreground

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor

        onClicked: {

            Quickshell.execDetached([
                "blueman-manager"
            ])
        }
    }
}
