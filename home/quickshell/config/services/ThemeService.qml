pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Aurora Theme Service

QtObject {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string auroraDirectory: root.home + "/.config/aurora"
    readonly property string switcherPath: root.home + "/.local/bin/aurora-theme"

    // Sources

    property FileView listFile: FileView {
        path: root.auroraDirectory + "/themes.list"
        watchChanges: true
        blockLoading: true
        printErrors: false
        onFileChanged: this.reload()
    }

    property FileView catalogueFile: FileView {
        path: root.auroraDirectory + "/themes.json"
        watchChanges: true
        blockLoading: true
        printErrors: false
        onFileChanged: this.reload()
    }

    property FileView activeFile: FileView {
        path: root.auroraDirectory + "/active-theme"
        watchChanges: true
        blockLoading: true
        printErrors: false
        onFileChanged: this.reload()
    }

    // Derived state

    readonly property string activeId: {
        const raw = root.activeFile.text()
        if (!raw)
            return "aurora"

        const trimmed = raw.trim()
        return trimmed.length > 0 ? trimmed : "aurora"
    }

    readonly property var catalogue: {
        const raw = root.catalogueFile.text()
        if (!raw)
            return ({})

        try {
            return JSON.parse(raw)
        } catch (e) {
            return ({})
        }
    }

    // themes.list is the ordering authority.
    readonly property var themes: {
        const raw = root.listFile.text()
        if (!raw)
            return []

        const catalogue = root.catalogue
        const entries = (catalogue && catalogue.themes) ? catalogue.themes : ({})
        const lines = raw.split("\n")
        const out = []

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            if (!line || line.trim().length === 0)
                continue

            const parts = line.split("\t")
            const id = parts[0].trim()
            if (id.length === 0)
                continue

            const name = (parts.length > 1 && parts[1].trim().length > 0)
                ? parts[1].trim()
                : id

            const entry = entries[id]

            out.push({
                "id": id,
                "name": name,
                "colors": (entry && entry.colors) ? entry.colors : ({})
            })
        }

        return out
    }

    readonly property int count: root.themes.length

    // Search

    function search(query) {
        const all = root.themes

        if (!query || query.trim().length === 0)
            return all

        const q = query.trim().toLowerCase()
        const scored = []

        for (let i = 0; i < all.length; i++) {
            const theme = all[i]
            const name = theme.name.toLowerCase()
            const id = theme.id.toLowerCase()

            let score = -1

            if (name.indexOf(q) === 0 || id.indexOf(q) === 0)
                score = 100
            else if (name.indexOf(q) !== -1)
                score = 60
            else if (id.indexOf(q) !== -1)
                score = 50

            if (score < 0)
                continue

            if (theme.id === root.activeId)
                score += 5

            scored.push({ "theme": theme, "score": score, "index": i })
        }

        // Stable: equal scores keep themes.list ordering.
        scored.sort(function (a, b) {
            if (b.score !== a.score)
                return b.score - a.score

            return a.index - b.index
        })

        const out = []
        for (let j = 0; j < scored.length; j++)
            out.push(scored[j].theme)

        return out
    }

    // Actions

    function apply(themeId) {
        if (!themeId || themeId.length === 0)
            return

        Quickshell.execDetached([root.switcherPath, themeId])
    }
}
