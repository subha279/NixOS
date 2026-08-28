pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Io

import "../core" as Core

// BrightnessService

Singleton {
    id: root

    // 0..100.
    property int level: 0

    readonly property real fraction: root.level / 100

    // False until a reading actually succeeds, so a desktop with no backlight can be detected rather than showing a fake 0%.
    property bool available: false

    readonly property int stepSize: 5

    // Discovered hardware

    // e.g. "amdgpu_bl1" or "intel_backlight".
    property string device: ""

    // Raw scale maximum, NOT a percentage.
    property int maxRaw: 0

    property int probeTries: 0

    // A local change updates the number instantly and briefly suppresses readings, so a poll landing mid-write cannot snap the value back and
    property double ignoreReadsUntil: 0

    // Single entry point for every reading

    function ingest(percent) {
        if (percent < 0)
            return;
        root.available = true;

        if (Date.now() < root.ignoreReadsUntil)
            return;
        const value = Math.max(0, Math.min(100, Math.round(percent)));

        // Only assign on a real change.
        if (value !== root.level) {
            root.level = value;

            // Something moved the backlight, so poll fast for a moment in case
            // this is the start of a burst (a held brightness key).
            root.markInteraction();
        }
    }

    // One-shot discovery

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

                // Seed the value immediately so the bar is correct on the very first frame, before the first file read lands.
                root.ingest(parseInt(String(fields[3]).replace("%", "")));
            }
        }
    }

    function runProbe() {
        root.probeTries += 1;
        root.probe.running = false;
        root.probe.running = true;
    }

    // The cheap reading path

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

    // Actions

    function change(amount) {
        Quickshell.execDetached(["brightnessctl", "-e4", "-n2", "set", amount]);
    }

    // Predict so the click feels instant, then let the file read (within ~100ms) settle the true value.
    function applyPredicted(next) {
        const clamped = Math.max(0, Math.min(100, Math.round(next)));

        root.ignoreReadsUntil = Date.now() + 120;

        // A local change is interaction by definition.
        root.markInteraction();

        if (clamped !== root.level) {
            root.level = clamped;
        } else {
            // Already at the rail, so onLevelChanged will not fire.
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

    // OSD trigger

    onLevelChanged: Core.OsdController.show("brightness", root.fraction, false)

    // Timers

    // Adaptive polling.
    //
    // This was a flat 100ms, i.e. ten sysfs reads a second for the entire
    // session, to catch brightness changed from outside the shell -- the
    // XF86MonBrightness keys run brightnessctl directly, so a poll is the only
    // way we hear about it.
    //
    // Brightness changes arrive in bursts (you hold the key), so the fast rate is
    // only needed for the length of a burst. Idle drops to 400ms, which is still
    // well inside "the OSD appeared immediately" for a single tap, and any
    // observed change switches to 100ms so a held key tracks as smoothly as
    // before. Steady-state wakeups drop by 60%.
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

    // Only runs until the device is found, and gives up rather than spawning brightnessctl forever on a machine that has no backlight at all.
    property Timer discoveryRetry: Timer {
        interval: 1000

        running: root.device === "" && root.probeTries < 5

        repeat: true

        onTriggered: root.runProbe()
    }

    Component.onCompleted: root.runProbe()
}
