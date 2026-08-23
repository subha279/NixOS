pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Aurora Apps Service
//
// Application list and ranking for the launcher.
// State: ~/.cache/aurora/launcher-usage.json

QtObject {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string usagePath: root.home + "/.cache/aurora/launcher-usage.json"

    property var usage: ({})

    // Frecency

    property FileView usageFile: FileView {
        path: root.usagePath
        blockLoading: true
        printErrors: false
    }

    function loadUsage() {
        const raw = root.usageFile.text()
        if (!raw) {
            root.usage = ({})
            return
        }

        try {
            const parsed = JSON.parse(raw)
            root.usage = (parsed && typeof parsed === "object") ? parsed : ({})
        } catch (e) {
            root.usage = ({})
        }
    }

    function bump(id) {
        if (!id || id.length === 0)
            return

        // Copy, then mutate, then assign.
        const next = ({})
        const keys = Object.keys(root.usage)

        for (let i = 0; i < keys.length; i++)
            next[keys[i]] = root.usage[keys[i]]

        next[id] = (next[id] || 0) + 1
        root.usage = next

        root.usageFile.setText(JSON.stringify(next))
    }

    // Entries

    readonly property var entries: {
        const source = DesktopEntries.applications.values
        const out = []

        for (let i = 0; i < source.length; i++) {
            const entry = source[i]
            if (!entry)
                continue

            // NoDisplay entries are things like MIME handlers and settings panels that are not meant to be launched.
            if (entry.noDisplay === true)
                continue

            if (!entry.name || entry.name.length === 0)
                continue

            out.push(entry)
        }

        out.sort(function (a, b) {
            const an = a.name.toLowerCase()
            const bn = b.name.toLowerCase()

            if (an < bn)
                return -1

            if (an > bn)
                return 1

            return 0
        })

        return out
    }

    readonly property int count: root.entries.length

    // Matching

    function subsequence(haystack, needle) {
        let h = 0

        for (let n = 0; n < needle.length; n++) {
            let found = false

            while (h < haystack.length) {
                if (haystack.charAt(h) === needle.charAt(n)) {
                    found = true
                    h++
                    break
                }
                h++
            }

            if (!found)
                return false
        }

        return true
    }

    // Tiers, strongest first.
    function score(entry, q) {
        const name = entry.name ? entry.name.toLowerCase() : ""

        if (name.indexOf(q) === 0)
            return 400

        const words = name.split(/[\s\-_.]+/)
        for (let i = 0; i < words.length; i++) {
            if (words[i].indexOf(q) === 0)
                return 300
        }

        if (name.indexOf(q) !== -1)
            return 200

        const generic = entry.genericName ? entry.genericName.toLowerCase() : ""
        if (generic.length > 0 && generic.indexOf(q) !== -1)
            return 140

        const comment = entry.comment ? entry.comment.toLowerCase() : ""
        if (comment.length > 0 && comment.indexOf(q) !== -1)
            return 100

        const keywords = entry.keywords
        if (keywords) {
            for (let k = 0; k < keywords.length; k++) {
                if (String(keywords[k]).toLowerCase().indexOf(q) !== -1)
                    return 100
            }
        }

        if (root.subsequence(name, q))
            return 60

        return -1
    }

    function search(query) {
        const all = root.entries

        if (!query || query.trim().length === 0)
            return all

        const q = query.trim().toLowerCase()
        const scored = []

        for (let i = 0; i < all.length; i++) {
            const entry = all[i]
            let s = root.score(entry, q)

            if (s < 0)
                continue

            // Frecency is a tie-breaker, capped so a heavily used app can never leapfrog a genuine prefix match.
            const hits = root.usage[entry.id] || 0
            s += Math.min(50, hits * 6)

            scored.push({ "entry": entry, "score": s, "index": i })
        }

        scored.sort(function (a, b) {
            if (b.score !== a.score)
                return b.score - a.score

            return a.index - b.index
        })

        const out = []
        for (let j = 0; j < scored.length; j++)
            out.push(scored[j].entry)

        return out
    }

    // Actions

    function launch(entry) {
        if (!entry)
            return

        root.bump(entry.id)
        entry.execute()
    }

    Component.onCompleted: root.loadUsage()
}
