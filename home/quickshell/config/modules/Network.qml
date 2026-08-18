import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services

// ================================================================
// Network bar module
// ----------------------------------------------------------------
// ONE icon slot for the whole network stack.
//
//   * Ethernet up  -> Ethernet icon
//   * Wi-Fi up     -> Wi-Fi strength icon
//   * Nothing up   -> muted "disconnected" icon
//
// The two never show at the same time — they cross-fade in place.
// ================================================================

Item {
    id: root

    implicitWidth: 30
    implicitHeight: Core.Theme.moduleHeight

    readonly property bool menuOpen: Core.PopupManager.isOpen("network")

    readonly property string link: Services.NetworkService.primaryLink

    readonly property bool showEthernet: root.link === "ethernet"

    // ------------------------------------------------------------
    // Signal tier, with a deadband
    // ------------------------------------------------------------
    //
    // Raw nmcli strength moves a few points between polls. Testing
    // it directly against 25/50/75 makes the glyph flip back and
    // forth whenever the real value sits near a boundary. The tier
    // only advances once the signal clears the boundary by `dead`,
    // and only drops once it falls below by the same margin.

    property int tier: 3

    readonly property int rawSignal: Services.NetworkService.activeSignal

    onRawSignalChanged: {
        const s = root.rawSignal;
        const bounds = [25, 50, 75];
        const dead = 6;

        let t = root.tier;

        while (t < 3 && s >= bounds[t] + dead)
            t++;

        while (t > 0 && s < bounds[t - 1] - dead)
            t--;

        root.tier = t;
    }

    // ------------------------------------------------------------
    // Hover / open background
    // ------------------------------------------------------------

    Rectangle {
        anchors.fill: parent

        radius: height / 2

        color: root.menuOpen ? Core.Theme.surfaceActive : mouse.containsMouse ? Core.Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    // ------------------------------------------------------------
    // Ethernet icon
    // ------------------------------------------------------------

    Text {
        anchors.centerIn: parent

        text: "\udb80\ude00"

        font.family: Core.Theme.fontFamily
        font.pixelSize: Core.Theme.iconSize

        color: Core.Theme.foreground

        opacity: root.showEthernet ? 1.0 : 0.0

        scale: root.showEthernet ? 1.0 : 0.6

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }
    }

    // ------------------------------------------------------------
    // Wi-Fi icon
    // ------------------------------------------------------------

    Text {
        anchors.centerIn: parent

        text: {
            const svc = Services.NetworkService;

            if (!svc.wifiEnabled)
                return Core.Icons.wifiOff;

            if (!svc.wifiConnected)
                return Core.Icons.wifiNone;

            if (root.tier >= 3)
                return Core.Icons.wifi3;
            if (root.tier === 2)
                return Core.Icons.wifi2;
            if (root.tier === 1)
                return Core.Icons.wifi1;

            return Core.Icons.wifi0;
        }

        font.family: Core.Theme.fontFamily
        font.pixelSize: Core.Theme.iconSize

        color: Services.NetworkService.wifiConnected ? Core.Theme.foreground : Core.Theme.foregroundMuted

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        opacity: root.showEthernet ? 0.0 : 1.0

        scale: root.showEthernet ? 0.6 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }
    }

    // ------------------------------------------------------------
    // Activity dot (connecting / scanning)
    // ------------------------------------------------------------

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right

        anchors.topMargin: 5
        anchors.rightMargin: 4

        width: 5
        height: 5

        radius: 3

        color: Core.Theme.accent

        opacity: Services.NetworkService.busy || Services.NetworkService.scanning ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
            }
        }

        SequentialAnimation on scale {
            running: Services.NetworkService.busy || Services.NetworkService.scanning

            loops: Animation.Infinite

            NumberAnimation {
                to: 1.5
                duration: 500
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                to: 1.0
                duration: 500
                easing.type: Easing.InOutSine
            }
        }
    }

    // ------------------------------------------------------------
    // Interaction
    // ------------------------------------------------------------

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: function (event) {
            if (event.button === Qt.MiddleButton) {
                Services.NetworkService.toggleWifi();
                return;
            }

            if (event.button === Qt.RightButton) {
                Services.NetworkService.openEditor();
                return;
            }

            // Screen-space anchor for the dropdown.
            // The bar window spans the full width, so mapToItem(null)
            // already gives us screen X; we only add the bar's top
            // margin to get screen Y.
            const p = root.mapToItem(null, 0, root.height);

            Core.PopupManager.toggle("network", p.x + root.width / 2, p.y + Core.Theme.barMarginTop);

            if (Core.PopupManager.isOpen("network"))
                Services.NetworkService.rescan();
        }

        onWheel: function (event) {
            if (event.angleDelta.y === 0)
                return;
            Services.NetworkService.toggleWifi();
        }
    }

    // Poll faster while the menu is open
    Binding {
        target: Services.NetworkService
        property: "fastPoll"
        value: root.menuOpen
    }
}
