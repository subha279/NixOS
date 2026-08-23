import QtQuick
import QtQuick.Layouts

import Quickshell

import "../core" as Core

// Launchers (bar module)

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: Core.Theme.moduleHeight

    RowLayout {
        id: row

        anchors.centerIn: parent

        spacing: 2

        LauncherButton {
            surfaceId: "launcher"
            glyph: Core.Icons.search
        }

        LauncherButton {
            surfaceId: "wallpaper"
            glyph: Core.Icons.image
        }

        LauncherButton {
            surfaceId: "theme"
            glyph: Core.Icons.brightness
        }
    }

    // Button

    component LauncherButton: Item {
        id: button

        property string surfaceId: ""
        property string glyph: ""

        readonly property bool active: Core.PopupManager.current === button.surfaceId

        implicitWidth: 26
        implicitHeight: Core.Theme.moduleHeight

        Layout.preferredWidth: 26
        Layout.preferredHeight: Core.Theme.moduleHeight

        Rectangle {
            anchors.fill: parent

            radius: height / 2

            color: button.active
                ? Core.Theme.surfaceActive
                : (mouse.containsMouse ? Core.Theme.hover : "transparent")

            Behavior on color {
                ColorAnimation {
                    duration: Core.Theme.durFast
                    easing.type: Easing.OutQuint
                }
            }
        }

        Text {
            anchors.centerIn: parent

            text: button.glyph

            font.family: Core.Theme.fontFamily

            font.pixelSize: Core.Theme.iconSize

            // Accent while its surface is open, so the bar shows which launcher you are in.
            color: button.active ? Core.Theme.accent : Core.Theme.foreground

            Behavior on color {
                ColorAnimation {
                    duration: Core.Theme.durFast
                    easing.type: Easing.OutQuint
                }
            }
        }

        MouseArea {
            id: mouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape: Qt.PointingHandCursor

            acceptedButtons: Qt.LeftButton

            onClicked: Core.PopupManager.toggle(button.surfaceId, 0, 0)
        }
    }
}
