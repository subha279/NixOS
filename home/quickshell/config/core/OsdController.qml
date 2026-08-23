pragma Singleton

import QtQuick

// OsdController

QtObject {
    id: root

    property string kind: ""

    // Always normalised 0..1.
    property real value: 0

    property bool muted: false

    readonly property bool active: root.kind !== ""

    // How long the readout stays up after the last change.
    readonly property int holdDuration: 1600

    // Startup guard

    property bool armed: false

    property Timer armTimer: Timer {
        interval: 1500

        running: true
        repeat: false

        onTriggered: root.armed = true
    }

    // Hold timer

    property Timer hideTimer: Timer {
        interval: root.holdDuration

        repeat: false

        onTriggered: root.kind = ""
    }

    // API

    // Raise (or refresh) an OSD.
    function show(kind, value, muted) {
        if (!root.armed)
            return;
        root.kind = kind;

        root.value = Math.max(0, Math.min(1, value));

        root.muted = muted === true;

        root.hideTimer.restart();
    }

    function hide() {
        root.hideTimer.stop();
        root.kind = "";
    }
}
