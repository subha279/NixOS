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

    // Only the module popups (network, bluetooth, battery, audio, calendar,
    // notifications) hold the bar open. Their cards are anchored under the icon
    // that spawned them, so that icon has to stay on screen.
    //
    // Launcher ids are filtered out here rather than leaning on `launcherOpen`.
    // That value is derived through the launcher items, so it settles one pass
    // later than `PopupManager.current` - long enough for the bar to start
    // expanding before the popup takes the surface over.
    readonly property bool modulePopupOpen: {
        const id = Core.PopupManager.current;

        if (id === "")
            return false;

        const list = root.launchers;

        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].launcherId === id)
                return false;
        }

        return true;
    }

    readonly property bool wantExpanded: !root.launcherOpen && (surfaceHover.hovered || root.modulePopupOpen)

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
            // Instant while a launcher is up. `onLauncherOpenChanged` clears
            // `expanded` the moment a popup appears, and that drop must not be
            // visible: an expanded bar shrinking underneath the growing card is
            // exactly the intermediate state we never want.
            duration: root.launcherOpen ? 0 : (root.expanded ? Core.Theme.barRevealDuration : Core.Theme.barHideDuration)
            easing.type: Easing.OutQuint
        }
    }

    // Popup takeover
    //
    // A popup always grows out of the normal pill, never out of the expanded bar.

    // True for one pass of the event loop when a launcher opens. While it is set
    // the surface is snapped back to pill geometry unanimated, so the morph has
    // the pill as its starting point even if the bar happened to be hovered open
    // a moment earlier.
    property bool fromPill: false

    // The surface has to keep animating for a moment after `launcherOpen` goes
    // false, otherwise the card would snap to the pill instead of shrinking into
    // it.
    property bool closing: false

    function releasePill() {
        root.fromPill = false;
    }

    onLauncherOpenChanged: {
        // No collapse delay and no collapse animation: the expanded bar is gone
        // before the popup draws a single frame.
        collapseTimer.stop();
        root.expanded = false;

        if (root.launcherOpen) {
            closeTimer.stop();
            root.closing = false;

            root.fromPill = true;
            Qt.callLater(root.releasePill);
            return;
        }

        root.fromPill = false;
        root.closing = true;
        closeTimer.restart();
    }

    Timer {
        id: closeTimer

        interval: Core.Theme.barRevealDuration

        onTriggered: root.closing = false
    }

    readonly property bool modulesVisible: root.reveal > 0.012 && !root.launcherOpen

    // OSD takeover

    readonly property bool osd: Core.OsdController.active && !root.expanded && !root.launcherOpen

    property real osdMix: root.osd ? 1.0 : 0.0

    Behavior on osdMix {
        NumberAnimation {
            // Snapped for the same reason as `reveal`: the pill a popup grows out
            // of has to be the normal pill, not a half-faded OSD readout.
            duration: root.launcherOpen ? 0 : Core.Theme.barRevealDuration
            easing.type: Easing.OutQuint
        }
    }

    readonly property real barContentWidth: content.implicitWidth + (osdView.implicitWidth - content.implicitWidth) * root.osdMix

    // Surface geometry
    //
    // One target per dimension, so there is exactly one animation on each and
    // nothing competes.

    // Bar shape until the pill snap has been released, so opening a launcher
    // reads pill -> card and never bar -> card.
    readonly property bool popupShape: root.launcherOpen && !root.fromPill

    readonly property real targetWidth: root.popupShape ? root.activeLauncher.cardWidth : root.barContentWidth + 24

    readonly property real targetHeight: root.popupShape ? root.activeLauncher.viewHeight : Core.Theme.pillHeight

    readonly property real targetRadius: root.popupShape ? Core.Theme.radiusLarge : Core.Theme.pillHeight / 2

    // Zero while the surface is a bar.
    //
    // In bar state the width comes from `content.implicitWidth`, which `reveal`
    // is already animating. Animating the surface on top of that was a second
    // animation on the same dimension: the surface trailed its own content, and
    // because it clips, the modules were sliced against its edge while expanding
    // and then popped into view. That is the hover jitter.
    //
    // So `reveal` owns hover motion, and the Behaviors below own only the
    // pill <-> card morph and the launcher's live resize as results filter.
    readonly property int morphDuration: root.fromPill ? 0 : ((root.launcherOpen || root.closing) ? Core.Theme.barRevealDuration : 0)

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

        // Only needed to hold popup content inside the rounded card while it is
        // still growing into it. Left on in bar state it clipped the modules
        // against the surface edge during hover expansion.
        clip: root.launcherOpen

        Behavior on width {
            NumberAnimation {
                duration: root.morphDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: root.morphDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: root.morphDuration
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
