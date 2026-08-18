pragma Singleton

import QtQuick

// ================================================================
// OsdController
// ----------------------------------------------------------------
// Single source of truth for "is an OSD showing, and of what".
//
// There is no OSD window. The bar itself becomes the OSD: the
// module row fades out, the readout fades in, and when the hold
// timer expires the bar goes back to showing the time. Because the
// state lives here and not in the bar, anything can raise an OSD
// with one call.
//
// Kinds: "" (nothing) | "volume" | "mic" | "brightness"
// ================================================================

QtObject {
    id: root

    property string kind: ""

    // Always normalised 0..1.
    property real value: 0

    property bool muted: false

    readonly property bool active:
        root.kind !== ""

    // How long the readout stays up after the last change.
    readonly property int holdDuration: 1600

    // ------------------------------------------------------------
    // Startup guard
    // ------------------------------------------------------------
    //
    // Every watched property settles from its default to its real
    // value in the first moment of the session — Pipewire nodes
    // appear, the first brightnessctl read lands. None of those are
    // user actions, so the OSD stays disarmed until they are done.
    // Without this the bar flashes a readout at every launch.

    property bool armed: false

    property Timer armTimer: Timer {
        interval: 1500

        running: true
        repeat: false

        onTriggered:
            root.armed = true
    }

    // ------------------------------------------------------------
    // Hold timer
    // ------------------------------------------------------------

    property Timer hideTimer: Timer {
        interval: root.holdDuration

        repeat: false

        onTriggered:
            root.kind = ""
    }

    // ------------------------------------------------------------
    // API
    // ------------------------------------------------------------

    // Raise (or refresh) an OSD. Calling this again while one is
    // already up just restarts the hold, so holding a volume key
    // keeps the readout alive instead of retriggering it.
    function show(kind, value, muted) {
        if (!root.armed)
            return

        root.kind = kind

        root.value =
            Math.max(0, Math.min(1, value))

        root.muted = muted === true

        root.hideTimer.restart()
    }

    function hide() {
        root.hideTimer.stop()
        root.kind = ""
    }
}
