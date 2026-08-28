pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var items: []
    property bool ready: false

    readonly property string emojiPath: Quickshell.env("HOME") + "/.config/quickshell/assets/emoji.json"

    property FileView emojiFile: FileView {
        path: root.emojiPath

        // Loaded asynchronously.
        //
        // This was blockLoading: true, which stalled the QML event loop while a
        // ~5000-entry JSON database was read and parsed -- and it happened during
        // shell startup, not on first use, because EmojiPicker binds itemCount to
        // results.length, which touches this singleton as soon as shell.qml is
        // created. So the bar's first paint waited on the emoji database.
        //
        // Nothing needed that: `ready` already exists and EmojiPicker already
        // renders a "Loading emoji…" state from it.
        blockLoading: false
        printErrors: false

        onLoadedChanged: {
            if (loaded)
                root.load();
        }

        onFileChanged: {
            reload();
        }
    }

    function load() {
        if (!root.emojiFile.loaded)
            return;
        try {
            const data = JSON.parse(root.emojiFile.text());

            if (!Array.isArray(data)) {
                root.items = [];
                root.ready = false;
                return;
            }

            // One lowercase haystack per entry, built once here.
            //
            // search() used to lowercase name, group and subgroup and run four
            // includes() per item on every keystroke: roughly 20k string
            // operations and 15k throwaway strings per character typed, which is
            // what made the picker feel heavy while filtering.
            for (let i = 0; i < data.length; i++) {
                const item = data[i];

                if (!item)
                    continue;

                item.haystack = (String(item.name || "") + " " + String(item.group || "") + " " + String(item.subgroup || "")).toLowerCase();
            }

            root.items = data;
            root.ready = true;
        } catch (error) {
            console.warn("Aurora Emoji: failed to parse emoji database:", error);

            root.items = [];
            root.ready = false;
        }
    }

    function search(query) {
        const source = root.items || [];
        const q = String(query || "").trim().toLowerCase();

        if (q === "")
            return source;

        const out = [];

        for (let i = 0; i < source.length; i++) {
            const item = source[i];

            if (!item)
                continue;

            // haystack is name + group + subgroup, precomputed in load(). The
            // glyph is checked separately so pasting an emoji still finds it.
            if (item.haystack !== undefined) {
                if (item.haystack.indexOf(q) !== -1 || String(item.emoji || "").indexOf(q) !== -1)
                    out.push(item);

                continue;
            }

            // Fallback for an entry that predates the index.
            const name = String(item.name || "").toLowerCase();

            if (name.indexOf(q) !== -1 || String(item.emoji || "").indexOf(q) !== -1)
                out.push(item);
        }

        return out;
    }

    Component.onCompleted: {
        if (root.emojiFile.loaded)
            root.load();
    }
}
