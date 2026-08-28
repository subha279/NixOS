pragma Singleton

import QtQuick


QtObject {
    id: root

    property string kind: ""

    property real value: 0

    property bool muted: false

    readonly property bool active: root.kind !== ""

    readonly property int holdDuration: 1600


    property bool armed: false

    property Timer armTimer: Timer {
        interval: 1500

        running: true
        repeat: false

        onTriggered: root.armed = true
    }


    property Timer hideTimer: Timer {
        interval: root.holdDuration

        repeat: false

        onTriggered: root.kind = ""
    }


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
