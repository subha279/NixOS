pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Io

import "../core" as Core

// ================================================================
// BrightnessService
// ----------------------------------------------------------------
// WHY THIS READS SYSFS INSTEAD OF RUNNING brightnessctl
//
// The previous version polled `brightnessctl -m`, which meant every
// single reading cost a process spawn. That forced an ugly choice:
//
//   poll fast  -> a fork+exec several times a second, which puts a
//                 periodic hitch straight through the render loop
//   poll slow  -> brightness changed by anything OTHER than a click
//                 in the bar (your laptop's own brightness keys,
//                 which call brightnessctl directly and never reach
//                 this shell) takes up to a second to show up
//
// Reading /sys/class/backlight/<dev>/actual_brightness is just a
// file read. No fork, no exec, essentially free. So it can be read
// ten times a second without costing anything, and ANY brightness
// change from ANY source appears within ~100ms.
//
// brightnessctl is now used for exactly two things: discovering the
// device once at startup, and performing writes (which need its
// permission handling).
// ================================================================

Singleton {
    id: root

    // 0..100.
    property int level: 0

    readonly property real fraction:
        root.level / 100

    // False until a reading actually succeeds, so a desktop with no
    // backlight can be detected rather than showing a fake 0%.
    property bool available: false

    readonly property int stepSize: 5

    // ------------------------------------------------------------
    // Discovered hardware
    // ------------------------------------------------------------

    // e.g. "amdgpu_bl1" or "intel_backlight".
    property string device: ""

    // Raw scale maximum, NOT a percentage. Panels vary wildly here
    // (255, 937, 24000...), so the percentage has to be derived.
    property int maxRaw: 0

    property int probeTries: 0

    // A local change updates the number instantly and briefly
    // suppresses readings, so a poll landing mid-write cannot snap
    // the value back and flicker the OSD.
    property double ignoreReadsUntil: 0

    // ------------------------------------------------------------
    // Single entry point for every reading
    // ------------------------------------------------------------

    function ingest(percent) {
        if (percent < 0)
            return

        root.available = true

        if (Date.now() < root.ignoreReadsUntil)
            return

        const value =
            Math.max(0, Math.min(100, Math.round(percent)))

        // Only assign on a real change. Rewriting the same value ten
        // times a second would fire onLevelChanged continuously and
        // pin the OSD permanently on screen.
        if (value !== root.level)
            root.level = value
    }

    // ------------------------------------------------------------
    // One-shot discovery
    // ------------------------------------------------------------
    //
    // `brightnessctl -m` prints, comma separated:
    //   device,class,current,percent,max

    property Process probe: Process {
        command: [
            "brightnessctl",
            "-m"
        ]

        stdout: StdioCollector {
            onStreamFinished: {

                const line =
                    text.trim().split("\n")[0]

                if (!line)
                    return

                const fields =
                    line.split(",")

                if (fields.length < 5)
                    return

                const max =
                    parseInt(fields[4])

                if (isNaN(max) || max <= 0)
                    return

                root.device = fields[0]
                root.maxRaw = max

                // Seed the value immediately so the bar is correct
                // on the very first frame, before the first file
                // read lands.
                root.ingest(
                    parseInt(String(fields[3]).replace("%", ""))
                )
            }
        }
    }

    function runProbe() {
        root.probeTries += 1
        root.probe.running = false
        root.probe.running = true
    }

    // ------------------------------------------------------------
    // The cheap reading path
    // ------------------------------------------------------------
    //
    // actual_brightness rather than brightness: it reports what the
    // panel is really at, so a value written by anything else is
    // still reflected here.

    property FileView backlightFile: FileView {
        path:
            root.device === ""
                ? ""
                : "/sys/class/backlight/"
                  + root.device
                  + "/actual_brightness"

        onLoaded: {
            if (root.maxRaw <= 0)
                return

            const raw =
                parseInt(root.backlightFile.text().trim())

            if (isNaN(raw))
                return

            root.ingest(raw / root.maxRaw * 100)
        }
    }

    // ------------------------------------------------------------
    // Actions
    // ------------------------------------------------------------

    function change(amount) {
        Quickshell.execDetached([
            "brightnessctl",
            "-e4",
            "-n2",
            "set",
            amount
        ])
    }

    // Predict so the click feels instant, then let the file read
    // (within ~100ms) settle the true value. The suppression window
    // is deliberately shorter than it used to be, because the real
    // value now arrives almost immediately.
    function applyPredicted(next) {
        const clamped =
            Math.max(0, Math.min(100, Math.round(next)))

        root.ignoreReadsUntil = Date.now() + 120

        if (clamped !== root.level) {
            root.level = clamped
        } else {
            // Already at the rail, so onLevelChanged will not fire.
            // Pressing the key at 100% should still confirm 100%.
            Core.OsdController.show(
                "brightness",
                root.fraction,
                false
            )
        }
    }

    function step(up) {
        root.applyPredicted(
            root.level + (up ? root.stepSize : -root.stepSize)
        )

        root.change(
            up
                ? root.stepSize + "%+"
                : root.stepSize + "%-"
        )
    }

    function setPercent(percent) {
        root.applyPredicted(percent)
        root.change(Math.round(percent) + "%")
    }

    function refresh() {
        if (root.device === "")
            root.runProbe()
        else
            root.backlightFile.reload()
    }

    // ------------------------------------------------------------
    // OSD trigger
    // ------------------------------------------------------------
    //
    // Fires for ANY brightness change from ANY source, including
    // your laptop's function keys, because those move the sysfs
    // value and the poll below sees it.

    onLevelChanged:
        Core.OsdController.show(
            "brightness",
            root.fraction,
            false
        )

    // ------------------------------------------------------------
    // Timers
    // ------------------------------------------------------------

    // 100ms of a plain file read. This is what makes the hardware
    // keys feel immediate. It is affordable precisely because no
    // process is involved.
    property Timer poll: Timer {
        interval: 100

        running: root.device !== ""
        repeat: true

        onTriggered:
            root.backlightFile.reload()
    }

    // Only runs until the device is found, and gives up rather than
    // spawning brightnessctl forever on a machine that has no
    // backlight at all.
    property Timer discoveryRetry: Timer {
        interval: 1000

        running:
            root.device === "" && root.probeTries < 5

        repeat: true

        onTriggered:
            root.runProbe()
    }

    Component.onCompleted:
        root.runProbe()
}
