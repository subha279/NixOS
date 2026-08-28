pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var items: []
    property bool ready: false

    signal historyChanged

    function refresh() {
        listProcess.running = false;
        listProcess.running = true;
    }

    function shellQuote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'";
    }

    function paste(item) {
        if (!item)
            return;

        const command = "printf '%s\\n' " + shellQuote(item.raw) + " | cliphist decode | wl-copy";

        Quickshell.execDetached(["sh", "-c", command]);

        Quickshell.execDetached(["sh", "-c", "sleep 0.05; wtype -M ctrl v -m ctrl"]);

        refresh();
    }

    function remove(item) {
        if (!item)
            return;

        const command = "printf '%s\\n' " + shellQuote(item.raw) + " | cliphist delete";

        Quickshell.execDetached(["sh", "-c", command]);

        refresh();
    }

    function clear() {
        Quickshell.execDetached(["sh", "-c", "cliphist wipe"]);

        refresh();
    }

    Process {
        id: listProcess

        command: ["sh", "-c", "cliphist list"]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim();
                const result = [];

                if (output !== "") {
                    const lines = output.split("\n");

                    for (const line of lines) {
                        if (!line.trim())
                            continue;

                        const tab = line.indexOf("\t");

                        result.push({
                            raw: line,
                            text: tab >= 0 ? line.slice(tab + 1) : line
                        });
                    }
                }

                root.items = result;
                root.ready = true;
                root.historyChanged();
            }
        }
    }

    Process {
        id: watcher

        // No --type filter on purpose: cliphist stores images too, and pinning
        // this to text meant image copies never reached the history.
        command: ["sh", "-c", "wl-paste --watch cliphist store"]

        running: true

        // Restart via a timer instead of reassigning running here. The immediate
        // version was an unbounded busy loop any time wl-paste could not start at
        // all -- missing binary, or no Wayland display yet.
        onExited: watcherRestart.start()
    }

    Timer {
        id: watcherRestart

        interval: 2000
        repeat: false

        onTriggered: {
            if (!watcher.running)
                watcher.running = true;
        }
    }

    Component.onCompleted: {
        refresh();
    }
}
