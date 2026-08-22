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
// Full-width Wayland layer surface.
//
// The visible bar is a 2px themed gradient ring with the actual
// shell surface inset inside it.
//
// Reveal:
//   0 = clock only
//   1 = fully expanded
//
// The entire module row remains driven by one animated `reveal`
// value so all modules stay synchronized.
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

    exclusiveZone: Core.Theme.pillHeight + margins.top + 4

    WlrLayershell.namespace: "aurora-bar"

    // Only the actual pill receives input.
    mask: Region {
        item: pill
    }

    // ============================================================
    // Reveal state
    // ============================================================

    readonly property bool wantExpanded: pillHover.hovered

    property bool expanded: false

    onWantExpandedChanged: {
        if (root.wantExpanded) {
            collapseTimer.stop();
            root.expanded = true;
            return;
        }

        collapseTimer.restart();
    }

    Timer {
        id: collapseTimer

        interval: Core.Theme.barCollapseDelay

        onTriggered: root.expanded = root.wantExpanded
    }

    // 0 = collapsed
    // 1 = fully expanded
    property real reveal: root.expanded ? 1.0 : 0.0

    Behavior on reveal {
        NumberAnimation {
            duration: root.expanded ? Core.Theme.barRevealDuration : Core.Theme.barHideDuration
            easing.type: Easing.OutCubic
        }
    }

    readonly property bool modulesVisible: root.reveal > 0.012

    // ============================================================
    // OSD takeover
    // ============================================================
    //
    // There is no separate OSD window. The bar becomes the OSD: the
    // module row fades out, the readout fades in, and when the hold
    // timer in OsdController expires the bar returns to the clock.
    //
    // Hovering always wins. If the pill is expanded or a popup is
    // open the OSD stays out of the way instead of yanking the
    // modules out from under the pointer — you can already see the
    // volume module in that state.

    readonly property bool osd: Core.OsdController.active && !root.expanded

    // ------------------------------------------------------------
    // One animated value drives the entire OSD morph
    // ------------------------------------------------------------
    //
    // 0 = module row, 1 = OSD readout. Width, both opacities and
    // the rise all read this single value, so they physically
    // cannot drift apart the way three separate Behaviors did.

    property real osdMix: root.osd ? 1.0 : 0.0

    Behavior on osdMix {
        NumberAnimation {
            duration: Core.Theme.barRevealDuration
            easing.type: Easing.OutCubic
        }
    }

    // Deliberately NOT animated. content.implicitWidth is already
    // changing every frame while the modules unfold; animating this
    // as well meant the ring and surface were chasing a moving
    // target and always lagged their own content. That lag is what
    // read as an unsmooth bar. Interpolating instead means the pill
    // tracks the row exactly, frame for frame, and still morphs
    // when the OSD takes over.
    readonly property real barContentWidth: content.implicitWidth + (osdView.implicitWidth - content.implicitWidth) * root.osdMix

    // ============================================================
    // OUTER BORDER RING
    // ============================================================
    //
    // This replaces Rectangle.border.
    //
    // The ring is exactly 2px because the inner pill is inset by
    // Core.Theme.borderWidth.
    //
    // Hyprland active border colors:
    //
    //   accent       -> accentActive
    //
    // ============================================================

    Rectangle {
        id: pillBorder

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        height: Core.Theme.pillHeight + (Core.Theme.borderWidth * 2)

        width: root.barContentWidth + 24 + (Core.Theme.borderWidth * 2)

        radius: height / 2

        antialiasing: true

        // --------------------------------------------------------
        // Hyprland-style active border palette
        // --------------------------------------------------------

        gradient: Gradient {

            // Diagonal-style visual approximation using the same
            // active Hyprland palette.
            //
            // The border remains entirely controlled by Aurora.
            GradientStop {
                position: 0.0
                color: Core.Theme.borderWidth > 0 ? Core.Theme.borderActive : "transparent"
            }

            GradientStop {
                position: 1.0
                color: Core.Theme.borderWidth > 0 ? Core.Theme.borderActiveEnd : "transparent"
            }
        }

        // --------------------------------------------------------
        // Shadow
        // --------------------------------------------------------

        Rectangle {
            anchors.fill: parent

            anchors.margins: -3

            z: -2

            radius: pillBorder.radius + 3

            color: "#000000"

            opacity: Core.Theme.shadowOpacity
        }

        // ========================================================
        // ACTUAL BAR SURFACE
        // ========================================================

        Rectangle {
            id: pill

            anchors.centerIn: parent

            height: Core.Theme.pillHeight

            width: root.barContentWidth + 24

            radius: height / 2

            color: Core.Theme.background

            antialiasing: true

            // ----------------------------------------------------
            // Hover detection
            // ----------------------------------------------------

            HoverHandler {
                id: pillHover
            }

            // ====================================================
            // CONTENT
            // ====================================================

            // ====================================================
            // OSD READOUT
            // ====================================================
            //
            // Shares the pill with the module row below. Exactly one
            // of the two is ever visible.

            BarOsd {
                id: osdView

                anchors.centerIn: parent

                // Straight off the shared mix value — no Behavior
                // of its own, so it is exactly in step with the
                // width and the fading module row.
                opacity: root.osdMix

                visible: root.osdMix > 0.01

                // Rises into place rather than just appearing.
                transform: Translate {
                    y: (1.0 - root.osdMix) * 4
                }
            }

            RowLayout {
                id: content

                anchors.centerIn: parent

                spacing: 3

                // Fades out while the bar is acting as an OSD. The
                // clock lives in this row, so this is what takes the
                // time off screen and brings it back.
                opacity: 1.0 - root.osdMix

                visible: root.osdMix < 0.99

                // ==================================================
                // Notification center
                // ==================================================

                Modules.NotificationCenter {
                    id: notificationCenter

                    Layout.preferredWidth: 30 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }

                // ==================================================
                // Volume
                // ==================================================

                Modules.Volume {
                    Layout.preferredWidth: 58 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }

                // ==================================================
                // Brightness
                // ==================================================

                Modules.Brightness {
                    Layout.preferredWidth: 58 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }

                // ==================================================
                // Clock
                // ==================================================

                Modules.Clock {
                    id: clockModule

                    Layout.preferredWidth: clockModule.implicitWidth

                    Layout.preferredHeight: Core.Theme.moduleHeight
                }

                Separator {
                    reveal: root.reveal
                }

                // ==================================================
                // Network
                // ==================================================

                Modules.Network {
                    Layout.preferredWidth: 30 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                // --------------------------------------------------
                // Wi-Fi / Bluetooth separator
                // --------------------------------------------------

                Separator {
                    reveal: root.reveal
                }

                // ==================================================
                // Bluetooth
                // ==================================================

                Modules.Bluetooth {
                    Layout.preferredWidth: 30 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }

                // ==================================================
                // Battery
                // ==================================================

                Modules.Battery {
                    Layout.preferredWidth: 58 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible && Services.BatteryService.available

                    opacity: root.reveal
                }

                // --------------------------------------------------
                // Battery separator
                // --------------------------------------------------

                Separator {
                    reveal: root.reveal

                    available: Services.BatteryService.available
                }

                // ==================================================
                // System tray
                // ==================================================

                Modules.Tray {
                    id: tray

                    Layout.preferredWidth: tray.implicitWidth * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }
            }
        }
    }

    // ============================================================
    // Separator
    // ============================================================

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
