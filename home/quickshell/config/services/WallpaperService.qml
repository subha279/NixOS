pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Aurora Wallpaper Service

QtObject {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string wallpaperDirectory: root.home + "/Wallpapers"
    readonly property string statePath: root.home + "/.cache/aurora/current-wallpaper"

    property bool scanning: false
    property string error: ""
    property var wallpapers: []

    // Applied wallpaper

    property FileView stateFile: FileView {
        path: root.statePath
        watchChanges: true
        blockLoading: true
        printErrors: false
        onFileChanged: this.reload()
    }

    readonly property string current: {
        const raw = root.stateFile.text()
        if (!raw)
            return ""

        return raw.trim()
    }

    // Scanning

    property Process scanProcess: Process {
        command: [
            "sh",
            "-c",
            "find \"$1\" -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \\) -printf '%f\\t%p\\n' 2>/dev/null | sort -f",
            "sh",
            root.wallpaperDirectory
        ]

        stdout: StdioCollector {
            onStreamFinished: root.ingest(this.text)
        }

        onExited: function (exitCode, exitStatus) {
            root.scanning = false

            if (exitCode !== 0 && root.wallpapers.length === 0)
                root.error = "Could not read " + root.wallpaperDirectory
        }
    }

    function refresh() {
        if (root.scanning)
            return

        root.scanning = true
        root.error = ""
        root.scanProcess.running = true
    }

    function ingest(text) {
        if (!text) {
            root.wallpapers = []
            return
        }

        const lines = text.split("\n")
        const out = []

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            if (!line || line.trim().length === 0)
                continue

            const tab = line.indexOf("\t")
            if (tab <= 0)
                continue

            const name = line.substring(0, tab)
            const path = line.substring(tab + 1)

            out.push({
                "name": name,
                "path": path,
                "label": name.replace(/\.[^.]+$/, "")
            })
        }

        root.wallpapers = out
    }

    readonly property int count: root.wallpapers.length

    // Search

    function search(query) {
        const all = root.wallpapers

        if (!query || query.trim().length === 0)
            return all

        const q = query.trim().toLowerCase()
        const out = []

        for (let i = 0; i < all.length; i++) {
            if (all[i].label.toLowerCase().indexOf(q) !== -1)
                out.push(all[i])
        }

        return out
    }

    // Actions

    function apply(path) {
        if (!path || path.length === 0)
            return

        Quickshell.execDetached([
            "sh",
            "-c",
            "mkdir -p \"$(dirname \"$2\")\" && awww img \"$1\" --transition-type grow --transition-duration 0.7 && printf '%s\\n' \"$1\" > \"$2\"",
            "sh",
            path,
            root.statePath
        ])
    }
}
