import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import "../core" as Core
import "../modules" as Modules
import "../services" as Services

// Bar

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

    // Reveal state

    readonly property bool launcherPopupOpen: Core.PopupManager.current === "launcher" || Core.PopupManager.current === "wallpaper" || Core.PopupManager.current === "theme"

    readonly property bool wantExpanded: !root.launcherPopupOpen && (pillHover.hovered || Core.PopupManager.current !== "")

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
            easing.type: Easing.OutQuint
        }
    }

    readonly property bool modulesVisible: root.reveal > 0.012

    // OSD takeover

    readonly property bool osd: Core.OsdController.active && !root.expanded

    // One animated value drives the entire OSD morph

    property real osdMix: root.osd ? 1.0 : 0.0

    Behavior on osdMix {
        NumberAnimation {
            duration: Core.Theme.barRevealDuration
            easing.type: Easing.OutQuint
        }
    }

    // Deliberately NOT animated.
    readonly property real barContentWidth: content.implicitWidth + (osdView.implicitWidth - content.implicitWidth) * root.osdMix

    // OUTER BORDER RING

    Rectangle {
        id: pillBorder

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        height: Core.Theme.pillHeight + (Core.Theme.borderWidth * 2)

        width: root.barContentWidth + 24 + (Core.Theme.borderWidth * 2)

        radius: height / 2

        antialiasing: true

        // Hyprland-style active border palette

        gradient: Gradient {

            // Diagonal-style visual approximation using the same active Hyprland palette.
            GradientStop {
                position: 0.0
                color: Core.Theme.borderWidth > 0 ? Core.Theme.borderActive : "transparent"
            }

            GradientStop {
                position: 1.0
                color: Core.Theme.borderWidth > 0 ? Core.Theme.borderActiveEnd : "transparent"
            }
        }

        // Floating shadow
        //
        // Three stacked layers with falling opacity approximate a soft blur
        // without pulling in GraphicalEffects. This is what lifts the pill off
        // the wallpaper. Lower z is wider and fainter, so darkness builds up
        // towards the pill edge.

        Rectangle {
            anchors.fill: parent

            anchors.margins: -Core.Theme.shellShadowSpread

            z: -4

            radius: pillBorder.radius + Core.Theme.shellShadowSpread

            color: "#000000"

            opacity: Core.Theme.shellShadowOpacity * 0.16

            antialiasing: true
        }

        Rectangle {
            anchors.fill: parent

            anchors.margins: -4

            z: -3

            radius: pillBorder.radius + 4

            color: "#000000"

            opacity: Core.Theme.shellShadowOpacity * 0.30

            antialiasing: true
        }

        Rectangle {
            anchors.fill: parent

            anchors.margins: -2

            z: -2

            radius: pillBorder.radius + 2

            color: "#000000"

            opacity: Core.Theme.shellShadowOpacity * 0.55

            antialiasing: true
        }

        // ACTUAL BAR SURFACE

        Rectangle {
            id: pill

            anchors.centerIn: parent

            height: Core.Theme.pillHeight

            width: root.barContentWidth + 24

            radius: height / 2

            color: Core.Theme.background

            antialiasing: true

            // Hover detection

            HoverHandler {
                id: pillHover
            }

            // CONTENT

            // OSD READOUT

            BarOsd {
                id: osdView

                anchors.centerIn: parent

                // Straight off the shared mix value — no Behavior of its own, so it is exactly in step with the width and the fading module row.
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

                // Fades out while the bar is acting as an OSD.
                opacity: 1.0 - root.osdMix

                visible: root.osdMix < 0.99

                // Notification center

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

                // Volume

                Modules.Volume {
                    Layout.preferredWidth: 58 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }

                // Brightness

                Modules.Brightness {
                    Layout.preferredWidth: 58 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }

                // Clock

                Modules.Clock {
                    id: clockModule

                    Layout.preferredWidth: clockModule.implicitWidth

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    // The clock hides its now-playing line whenever the bar is
                    // wide, so it needs the same reveal value the collapsible
                    // modules already use.
                    reveal: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }

                // Network

                Modules.Network {
                    Layout.preferredWidth: 30 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                // Wi-Fi / Bluetooth separator

                Separator {
                    reveal: root.reveal
                }

                // Bluetooth

                Modules.Bluetooth {
                    Layout.preferredWidth: 30 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }

                // Battery

                Modules.Battery {
                    Layout.preferredWidth: 58 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible && Services.BatteryService.available

                    opacity: root.reveal
                }

                // Battery separator

                Separator {
                    reveal: root.reveal

                    available: Services.BatteryService.available
                }

                // System tray

                Modules.Tray {
                    id: tray

                    barWindow: root

                    Layout.preferredWidth: tray.implicitWidth * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }
            }
        }
    }

    component Separator: Item {
        id: sep

        property real reveal: 1.0

        property bool available: true

        readonly property color tint: Core.Theme.separator

        Layout.preferredWidth: 1

        Layout.preferredHeight: 18

        visible: sep.available && sep.reveal > 0.012

        // Slightly under full strength so it never competes with the glyphs.
        opacity: sep.reveal * 0.9

        Rectangle {
            anchors.centerIn: parent

            width: 1

            height: parent.height

            antialiasing: true

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(sep.tint.r, sep.tint.g, sep.tint.b, 0.0)
                }

                GradientStop {
                    position: 0.32
                    color: sep.tint
                }

                GradientStop {
                    position: 0.68
                    color: sep.tint
                }

                GradientStop {
                    position: 1.0
                    color: Qt.rgba(sep.tint.r, sep.tint.g, sep.tint.b, 0.0)
                }
            }
        }
    }
}
