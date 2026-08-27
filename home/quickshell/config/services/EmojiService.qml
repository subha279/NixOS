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

        blockLoading: true
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

        return source.filter(function (item) {
            if (!item)
                return false;

            const name = String(item.name || "").toLowerCase();
            const group = String(item.group || "").toLowerCase();
            const subgroup = String(item.subgroup || "").toLowerCase();
            const emoji = String(item.emoji || "");

            return (name.includes(q) || group.includes(q) || subgroup.includes(q) || emoji.includes(q));
        });
    }

    Component.onCompleted: {
        if (root.emojiFile.loaded)
            root.load();
    }
}
