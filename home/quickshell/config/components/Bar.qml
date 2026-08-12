import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import "../core" as Core
import "../modules" as Modules

PanelWindow {
    id: root

    anchors.top: true

    margins.top: 8

    implicitWidth: pill.width + 20
    implicitHeight: pill.height + 20

    color: "transparent"

    exclusiveZone:
        pill.height + margins.top + 4

    WlrLayershell.namespace:
        "aurora-bar"

    Rectangle {
        id: pill

        anchors.centerIn: parent

        height: Core.Theme.pillHeight

        width:
            content.implicitWidth + 24

        radius: height / 2

        color: Core.Theme.background

        border.width: 1
        border.color: Core.Theme.border

        antialiasing: true

        // --------------------------------------------------------
        // Subtle glass shadow
        // --------------------------------------------------------

        Rectangle {
            anchors.fill: parent

            anchors.margins: -3

            z: -1

            radius: pill.radius + 3

            color: "#000000"

            opacity: 0.12
        }

        RowLayout {
            id: content

            anchors.centerIn: parent

            spacing: 3

            // ====================================================
            // Volume
            // ====================================================

            Modules.Volume {
                Layout.preferredWidth: 58
                Layout.preferredHeight:
                    Core.Theme.moduleHeight
            }

            Separator {}

            // ====================================================
            // Brightness
            // ====================================================

            Modules.Brightness {
                Layout.preferredWidth: 58
                Layout.preferredHeight:
                    Core.Theme.moduleHeight
            }

            Separator {}

            // ====================================================
            // Clock
            // ====================================================

            Modules.Clock {
                Layout.preferredWidth: 48
                Layout.preferredHeight:
                    Core.Theme.moduleHeight
            }

            Separator {}

            // ====================================================
            // System tray
            // ====================================================
            Modules.Network {
              Layout.preferredWidth: 30
              Layout.preferredHeight:
              Core.Theme.moduleHeight
            }

            Modules.Bluetooth {
              Layout.preferredWidth: 30
              Layout.preferredHeight:
              Core.Theme.moduleHeight
            }
            Separator {}

            Modules.Tray {
                Layout.preferredHeight:
                    Core.Theme.moduleHeight
            }
        }
    }

    // ============================================================
    // Separator component
    // ============================================================

    component Separator: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 16

        color: Core.Theme.separator

        radius: 1
    }
}
