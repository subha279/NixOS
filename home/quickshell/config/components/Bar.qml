import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import "../core" as Core
import "../modules" as Modules
import "../services" as Services

// ================================================================
// Bar
// ----------------------------------------------------------------
// The window now spans the FULL screen width (with a click-through
// mask everywhere except the pill). That means any module can call
// mapToItem(null, ...) and get real screen coordinates, which is
// what the dropdowns use to position themselves under the icon.
// ================================================================

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    margins.top: Core.Theme.barMarginTop

    implicitHeight: Core.Theme.pillHeight + 20

    color: "transparent"

    exclusiveZone:
        Core.Theme.pillHeight + margins.top + 4

    WlrLayershell.namespace: "aurora-bar"

    // Only the pill itself receives input
    mask: Region {
        item: pill
    }

    Rectangle {
        id: pill

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        height: Core.Theme.pillHeight

        width: content.implicitWidth + 24

        radius: height / 2

        color: Core.Theme.background

        border.width: 1
        border.color: Core.Theme.border

        antialiasing: true

        // Width changes (e.g. tray items appearing) feel springy too
        Behavior on width {
            SpringAnimation {
                spring: 4.0
                damping: 0.45
                epsilon: 0.25
            }
        }

        // --------------------------------------------------------
        // Subtle glass shadow
        // --------------------------------------------------------

        Rectangle {
            anchors.fill: parent

            anchors.margins: -3

            z: -1

            radius: pill.radius + 3

            color: "#000000"

            opacity: Core.Theme.shadowOpacity
        }

        RowLayout {
            id: content

            anchors.centerIn: parent

            spacing: 3

            // ====================================================
            // Notification center (leftmost)
            // ====================================================

            Modules.NotificationCenter {
                id: notificationCenter

                Layout.preferredWidth: 30
                Layout.preferredHeight:
                    Core.Theme.moduleHeight
            }

            Separator {}

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
            // Network (Wi-Fi + Ethernet, one slot)
            // ====================================================

            Modules.Network {
                Layout.preferredWidth: 30
                Layout.preferredHeight:
                    Core.Theme.moduleHeight
            }

            // ====================================================
            // Bluetooth
            // ====================================================

            Modules.Bluetooth {
                Layout.preferredWidth: 30
                Layout.preferredHeight:
                    Core.Theme.moduleHeight
            }

            Separator {}

            // ====================================================
            // Battery (auto-hides on desktops)
            // ====================================================

            Modules.Battery {
                Layout.preferredWidth: 58
                Layout.preferredHeight:
                    Core.Theme.moduleHeight
            }

            // Hidden together with the battery module so desktops
            // don't get a dangling divider.
            Separator {
                visible: Services.BatteryService.available
            }

            // ====================================================
            // System tray
            // ====================================================

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
