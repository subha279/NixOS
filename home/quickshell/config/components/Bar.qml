import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import "../core" as Core
import "../modules" as Modules
import "../services" as Services

// The one PanelWindow for the bar and the launcher popups.
//
// A single `surface` morphs between three states:
//
//   normal pill   ->  contentWidth  x pillHeight,  fully rounded
//   OSD pill      ->  osdWidth      x pillHeight,  fully rounded
//   popup         ->  cardWidth     x viewHeight,  radiusLarge
//
// Only that surface animates. The window itself is a fixed tall box so the popup
// has somewhere to live, and its exclusive zone stays at pill height so the
// workspace gap never moves.

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    margins.top: Core.Theme.barMarginTop

    // Fixed, and deliberately never animated: tall enough for the largest
    // launcher plus the pill above it. Animating this would move the reserved
    // area and shove windows around on every popup.
    implicitHeight: root.surfaceTop + Core.Theme.launcherMaxHeight + 40

    color: "transparent"

    // Independent of implicitHeight, so a tall window still only reserves the
    // pill. Unchanged from before so the gap stays exactly where it was.
    exclusiveZone: Core.Theme.pillHeight + margins.top + 4

    WlrLayershell.namespace: "aurora-bar"

    // Keyboard only while a launcher is up; the bar itself never wants focus.
    WlrLayershell.keyboardFocus: root.launcherOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Where the surface sits inside the window. Reproduces the old geometry: the
    // pill used to be centred in a (pillHeight + 20) window.
    readonly property int surfaceTop: 10

    // Launchers

    readonly property var launchers: [appLauncher, wallpaperPicker, themePicker, clipboardView, emojiPicker]

    readonly property var activeLauncher: {
        const list = root.launchers;

        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].open)
                return list[i];
        }

        return null;
    }

    readonly property bool launcherOpen: root.activeLauncher !== null

    // While a launcher is open the whole window takes input, so clicking beside
    // the popup still dismisses it. Otherwise only the pill is clickable and
    // everything else passes through to the desktop.
    property Region surfaceRegion: Region {
        item: surfaceBorder
    }

    mask: root.launcherOpen ? null : root.surfaceRegion

    // Reveal state

    readonly property bool wantExpanded: !root.launcherOpen && (surfaceHover.hovered || Core.PopupManager.current !== "")

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

    readonly property bool modulesVisible: root.reveal > 0.012 && !root.launcherOpen

    // OSD takeover

    readonly property bool osd: Core.OsdController.active && !root.expanded && !root.launcherOpen

    property real osdMix: root.osd ? 1.0 : 0.0

    Behavior on osdMix {
        NumberAnimation {
            duration: Core.Theme.barRevealDuration
            easing.type: Easing.OutQuint
        }
    }

    readonly property real barContentWidth: content.implicitWidth + (osdView.implicitWidth - content.implicitWidth) * root.osdMix

    // Surface geometry
    //
    // One target per dimension, so there is exactly one animation on each and
    // nothing competes.

    readonly property real targetWidth: root.launcherOpen ? root.activeLauncher.cardWidth : root.barContentWidth + 24

    readonly property real targetHeight: root.launcherOpen ? root.activeLauncher.viewHeight : Core.Theme.pillHeight

    readonly property real targetRadius: root.launcherOpen ? Core.Theme.radiusLarge : Core.Theme.pillHeight / 2

    // OUTER BORDER RING

    Rectangle {
        id: surfaceBorder

        anchors.horizontalCenter: parent.horizontalCenter

        y: root.surfaceTop - Core.Theme.borderWidth

        width: surface.width + (Core.Theme.borderWidth * 2)

        height: surface.height + (Core.Theme.borderWidth * 2)

        radius: surface.radius + Core.Theme.borderWidth

        antialiasing: true

        color: "transparent"

        border.width: Core.Theme.borderWidth
        border.color: Core.Theme.borderActive
    }

    // THE SURFACE

    Rectangle {
        id: surface

        anchors.horizontalCenter: parent.horizontalCenter

        y: root.surfaceTop

        width: root.targetWidth

        height: root.targetHeight

        radius: root.targetRadius

        color: "transparent"

        antialiasing: true

        // Keeps popup content inside the rounded shape while the surface is
        // still growing into it.
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: Core.Theme.barRevealDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: Core.Theme.barRevealDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: Core.Theme.barRevealDuration
                easing.type: Easing.OutCubic
            }
        }

        Glass {
            anchors.fill: parent
            radius: parent.radius
        }

        // Hover
        //
        // On the surface rather than a MouseArea, so it cannot swallow clicks
        // meant for the popup content inside it.
        HoverHandler {
            id: surfaceHover
        }

        // OSD READOUT

        BarOsd {
            id: osdView

            anchors.centerIn: parent

            opacity: root.osdMix

            visible: root.osdMix > 0.01 && !root.launcherOpen

            transform: Translate {
                y: (1.0 - root.osdMix) * 4
            }
        }

        // NORMAL BAR CONTENT

        RowLayout {
            id: content

            anchors.centerIn: parent

            spacing: 3

            opacity: 1.0 - root.osdMix

            visible: root.osdMix < 0.99 && !root.launcherOpen

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

            Modules.Volume {
                Layout.preferredWidth: 58 * root.reveal

                Layout.preferredHeight: Core.Theme.moduleHeight

                visible: root.modulesVisible

                opacity: root.reveal
            }

            Separator {
                reveal: root.reveal
            }

            Modules.Brightness {
                Layout.preferredWidth: 58 * root.reveal

                Layout.preferredHeight: Core.Theme.moduleHeight

                visible: root.modulesVisible

                opacity: root.reveal
            }

            Separator {
                reveal: root.reveal
            }

            Modules.Clock {
                id: clockModule

                Layout.preferredWidth: clockModule.implicitWidth

                Layout.preferredHeight: Core.Theme.moduleHeight

                reveal: root.reveal
            }

            Separator {
                reveal: root.reveal
            }

            Modules.Network {
                Layout.preferredWidth: 30 * root.reveal

                Layout.preferredHeight: Core.Theme.moduleHeight

                visible: root.modulesVisible

                opacity: root.reveal
            }

            Separator {
                reveal: root.reveal
            }

            Modules.Bluetooth {
                Layout.preferredWidth: 30 * root.reveal

                Layout.preferredHeight: Core.Theme.moduleHeight

                visible: root.modulesVisible

                opacity: root.reveal
            }

            Separator {
                reveal: root.reveal
            }

            Modules.Battery {
                Layout.preferredWidth: 58 * root.reveal

                Layout.preferredHeight: Core.Theme.moduleHeight

                visible: root.modulesVisible && Services.BatteryService.available

                opacity: root.reveal
            }

            Separator {
                reveal: root.reveal

                available: Services.BatteryService.available
            }

            Modules.Tray {
                id: tray

                barWindow: root

                Layout.preferredWidth: tray.implicitWidth * root.reveal

                Layout.preferredHeight: Core.Theme.moduleHeight

                visible: root.modulesVisible

                opacity: root.reveal
            }
        }

        // POPUP CONTENT
        //
        // The launchers live here instead of each owning a PanelWindow. They draw
        // content only: the background, border, radius and clipping all come from
        // the surface above.

        Item {
            id: popupLayer

            anchors.fill: parent

            visible: root.launcherOpen

            Modules.AppLauncher {
                id: appLauncher

                anchors.fill: parent
            }

            Modules.WallpaperPicker {
                id: wallpaperPicker

                anchors.fill: parent
            }

            Modules.ThemePicker {
                id: themePicker

                anchors.fill: parent
            }

            Modules.Clipboard {
                id: clipboardView

                anchors.fill: parent
            }

            Modules.EmojiPicker {
                id: emojiPicker

                anchors.fill: parent
            }
        }
    }

    // Click-away dismiss while a launcher is open. Behind the surface, so popup
    // content is never blocked.
    MouseArea {
        anchors.fill: parent

        z: -1

        enabled: root.launcherOpen

        acceptedButtons: Qt.LeftButton

        onClicked: Core.PopupManager.close()
    }

    component Separator: Item {
        id: sep

        property real reveal: 1.0

        property bool available: true

        readonly property color tint: Core.Theme.separator

        Layout.preferredWidth: 1

        Layout.preferredHeight: 18

        visible: sep.available && sep.reveal > 0.012

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
