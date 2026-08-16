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
// The window spans the FULL screen width with a click-through mask
// everywhere except the pill.
//
// The pill itself is COLLAPSED by default: only the clock is shown.
// Hovering it (or having any dropdown open) expands every other
// module outwards with a springy reveal.
//
// A single animated scalar, `reveal` (0..1), drives every module's
// width, opacity and scale. Sharing one value keeps the whole row
// perfectly in sync and means there is only ever one animation
// running instead of a dozen competing ones.
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

    // ============================================================
    // Reveal state
    // ============================================================

    // Stay open while the pointer is over the pill, and also while
    // any dropdown is open — otherwise the module you just clicked
    // would fold away underneath its own popup.
    readonly property bool wantExpanded:
        pillHover.hovered ||
        Core.PopupManager.current !== ""

    property bool expanded: false

    onWantExpandedChanged: {

        if (root.wantExpanded) {
            collapseTimer.stop()
            root.expanded = true
            return
        }

        // Small grace period so brushing past the clock doesn't
        // cause the row to flicker open and shut.
        collapseTimer.restart()
    }

    Timer {
        id: collapseTimer

        interval: Core.Theme.barCollapseDelay

        onTriggered: root.expanded = root.wantExpanded
    }

    // 0 = collapsed (clock only), 1 = fully expanded.
    property real reveal: root.expanded ? 1.0 : 0.0

    Behavior on reveal {
        SpringAnimation {
            spring: 4.2
            damping: 0.46
            mass: 1.0
            epsilon: 0.004
        }
    }

    // Below this the modules are effectively invisible, so we drop
    // them out of the layout entirely and reclaim their spacing.
    readonly property bool modulesVisible: root.reveal > 0.012

    Rectangle {
        id: pill

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        height: Core.Theme.pillHeight

        width: content.implicitWidth + 24

        radius: height / 2

        color: Core.Theme.background

        border.width: 1

        border.color: root.expanded
            ? Core.Theme.border
            : Core.Theme.separator

        Behavior on border.color {
            ColorAnimation {
                duration: Core.Theme.durBase
            }
        }

        antialiasing: true

        // No Behavior on width here on purpose. The width already
        // follows `reveal`, which is spring driven; animating it a
        // second time just adds lag.

        // --------------------------------------------------------
        // Hover detection
        // --------------------------------------------------------
        //
        // A HoverHandler is used rather than a MouseArea because it
        // is passive: it reports hover for the whole pill including
        // its children, without swallowing clicks or blocking the
        // per-module MouseAreas stacked above it.

        HoverHandler {
            id: pillHover
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

                Layout.preferredWidth: 30 * root.reveal
                Layout.preferredHeight:
                    Core.Theme.moduleHeight

                visible: root.modulesVisible

                opacity: root.reveal

                scale: 0.55 + 0.45 * root.reveal
            }

            Separator {
                reveal: root.reveal
            }

            // ====================================================
            // Volume
            // ====================================================

            Modules.Volume {
                Layout.preferredWidth: 58 * root.reveal
                Layout.preferredHeight:
                    Core.Theme.moduleHeight

                visible: root.modulesVisible

                opacity: root.reveal

                scale: 0.55 + 0.45 * root.reveal
            }

            Separator {
                reveal: root.reveal
            }

            // ====================================================
            // Brightness
            // ====================================================

            Modules.Brightness {
                Layout.preferredWidth: 58 * root.reveal
                Layout.preferredHeight:
                    Core.Theme.moduleHeight

                visible: root.modulesVisible

                opacity: root.reveal

                scale: 0.55 + 0.45 * root.reveal
            }

            Separator {
                reveal: root.reveal
            }

            // ====================================================
            // Clock — the anchor. Always visible, never animated.
            // ====================================================

            Modules.Clock {
                id: clockModule

                Layout.preferredWidth: clockModule.implicitWidth
                Layout.preferredHeight:
                    Core.Theme.moduleHeight
            }

            Separator {
                reveal: root.reveal
            }

            // ====================================================
            // Network (Wi-Fi + Ethernet, one slot)
            // ====================================================

            Modules.Network {
                Layout.preferredWidth: 30 * root.reveal
                Layout.preferredHeight:
                    Core.Theme.moduleHeight

                visible: root.modulesVisible

                opacity: root.reveal

                scale: 0.55 + 0.45 * root.reveal
            }

            // ====================================================
            // Bluetooth
            // ====================================================

            Modules.Bluetooth {
                Layout.preferredWidth: 30 * root.reveal
                Layout.preferredHeight:
                    Core.Theme.moduleHeight

                visible: root.modulesVisible

                opacity: root.reveal

                scale: 0.55 + 0.45 * root.reveal
            }

            Separator {
                reveal: root.reveal
            }

            // ====================================================
            // Battery (auto-hides on desktops)
            // ====================================================

            Modules.Battery {
                Layout.preferredWidth: 58 * root.reveal
                Layout.preferredHeight:
                    Core.Theme.moduleHeight

                visible: root.modulesVisible &&
                         Services.BatteryService.available

                opacity: root.reveal

                scale: 0.55 + 0.45 * root.reveal
            }

            // Hidden together with the battery module so desktops
            // don't get a dangling divider.
            Separator {
                reveal: root.reveal

                available: Services.BatteryService.available
            }

            // ====================================================
            // System tray
            // ====================================================

            Modules.Tray {
                id: tray

                Layout.preferredWidth:
                    tray.implicitWidth * root.reveal

                Layout.preferredHeight:
                    Core.Theme.moduleHeight

                visible: root.modulesVisible

                opacity: root.reveal

                scale: 0.55 + 0.45 * root.reveal
            }
        }
    }

    // ============================================================
    // Separator component
    // ============================================================
    //
    // Inline components cannot reach ids declared in the enclosing
    // file, so `reveal` is passed in explicitly at every use site.

    component Separator: Rectangle {
        property real reveal: 1.0
        property bool available: true

        Layout.preferredWidth: 1
        Layout.preferredHeight: 16

        visible: available && reveal > 0.012

        opacity: reveal

        color: Core.Theme.separator

        radius: 1
    }
}
