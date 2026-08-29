pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Io

// CavaService

Singleton {
    id: root

    // Must match `bars` in cava.conf. level() tolerates a mismatch rather than
    // letting the strip break, but the two are meant to be edited together.
    readonly property int barCount: 11

    // cava.conf sets ascii_max_range to this, so values arrive as 0..1000.
    readonly property real range: 1000.0

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/cava.conf"

    // Held false by default. NowPlaying binds this to its own visibility so
    // cava is not decoding audio while nothing is drawing it.
    property bool enabled: false

    property var values: root.silence()

    readonly property bool running: proc.running

    function silence() {
        const out = [];

        for (let i = 0; i < root.barCount; i++) {
            out.push(0.0);
        }

        return out;
    }

    function level(i) {
        const v = root.values[i];

        return (v === undefined || isNaN(v)) ? 0.0 : v;
    }

    onEnabledChanged: {
        if (!root.enabled)
            root.values = root.silence();
    }

    Process {
        id: proc

        running: root.enabled

        command: ["cava", "-p", root.configPath]

        // cava writes one frame per line as "v;v;...;v;", with a trailing bar
        // delimiter on the last value, so the split leaves an empty tail.
        stdout: SplitParser {
            splitMarker: "\n"

            onRead: function (line) {
                const parts = line.split(";");

                const out = [];

                for (let i = 0; i < parts.length; i++) {
                    if (parts[i].length === 0)
                        continue;

                    const v = parseInt(parts[i], 10);

                    out.push(isNaN(v) ? 0.0 : Math.min(1.0, v / root.range));
                }

                if (out.length > 0)
                    root.values = out;
            }
        }
    }
}
