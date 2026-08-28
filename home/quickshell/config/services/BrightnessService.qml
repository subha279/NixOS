pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Io

import "../core" as Core


Singleton {
    id: root

    property int level: 0

    readonly property real fraction: root.level / 100

    property bool available: false

    readonly property int stepSize: 5


    property string device: ""

    property int maxRaw: 0

    property int probeTries: 0

    property double ignoreReadsUntil: 0


    function ingest(percent) {
        if (percent < 0)
            return;
        root.available = true;

        if (Date.now() < root.ignoreReadsUntil)
            return;
        const value = Math.max(0, Math.min(100, Math.round(percent)));

        if (value !== root.level) {
            root.level = value;

            root.markInteraction();
        }
    }


    property Process probe: Process {
        command: ["brightnessctl", "-m"]

        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim().split("\n")[0];

                if (!line)
                    return;
                const fields = line.split(",");

                if (fields.length < 5)
                    return;
                const max = parseInt(fields[4]);

                if (isNaN(max) || max <= 0)
                    return;
                root.device = fields[0];
                root.maxRaw = max;

                root.ingest(parseInt(String(fields[3]).replace("%", "")));
            }
        }
    }

    function runProbe() {
        root.probeTries += 1;
        root.probe.running = false;
        root.probe.running = true;
    }


    property FileView backlightFile: FileView {
        path: root.device === "" ? "" : "/sys/class/backlight/" + root.device + "/actual_brightness"

        onLoaded: {
            if (root.maxRaw <= 0)
                return;
            const raw = parseInt(root.backlightFile.text().trim());

            if (isNaN(raw))
                return;
            root.ingest(raw / root.maxRaw * 100);
        }
    }


    function change(amount) {
        Quickshell.execDetached(["brightnessctl", "-e4", "-n2", "set", amount]);
    }

    function applyPredicted(next) {
        const clamped = Math.max(0, Math.min(100, Math.round(next)));

        root.ignoreReadsUntil = Date.now() + 120;

        root.markInteraction();

        if (clamped !== root.level) {
            root.level = clamped;
        } else {
            Core.OsdController.show("brightness", root.fraction, false);
        }
    }

    function step(up) {
        root.applyPredicted(root.level + (up ? root.stepSize : -root.stepSize));

        root.change(up ? root.stepSize + "%+" : root.stepSize + "%-");
    }

    function setPercent(percent) {
        root.applyPredicted(percent);
        root.change(Math.round(percent) + "%");
    }

    function refresh() {
        if (root.device === "")
            root.runProbe();
        else
            root.backlightFile.reload();
    }


    onLevelChanged: Core.OsdController.show("brightness", root.fraction, false)


    property bool interacting: false

    function markInteraction() {
        root.interacting = true;
        root.interactionCooldown.restart();
    }

    property Timer interactionCooldown: Timer {
        interval: 2500

        repeat: false

        onTriggered: root.interacting = false
    }

    property Timer poll: Timer {
        interval: root.interacting ? 100 : 400

        running: root.device !== ""
        repeat: true

        onTriggered: root.backlightFile.reload()
    }

    property Timer discoveryRetry: Timer {
        interval: 1000

        running: root.device === "" && root.probeTries < 5

        repeat: true

        onTriggered: root.runProbe()
    }

    Component.onCompleted: root.runProbe()
}
