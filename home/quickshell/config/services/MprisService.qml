pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Services.Mpris


Singleton {
    id: root


    readonly property var players: (Mpris.players && Mpris.players.values) ? Mpris.players.values : []


    readonly property var active: {
        const list = root.players;

        for (let i = 0; i < list.length; i++) {
            const p = list[i];

            if (p && p.playbackState === MprisPlaybackState.Playing)
                return p;
        }

        for (let i = 0; i < list.length; i++) {
            const p = list[i];

            if (p && String(p.trackTitle || "") !== "")
                return p;
        }

        return list.length > 0 ? list[0] : null;
    }

    readonly property bool available: root.active !== null

    readonly property bool playing: root.available && root.active.playbackState === MprisPlaybackState.Playing


    readonly property string title: root.available ? String(root.active.trackTitle || "") : ""

    readonly property string artist: root.available ? String(root.active.trackArtist || "") : ""

    readonly property string identity: root.available ? String(root.active.identity || "") : ""

    readonly property string label: {
        if (!root.available)
            return "";

        if (root.title !== "")
            return root.title;

        if (root.identity !== "")
            return root.identity;

        return "Playing";
    }


    readonly property bool canToggle: root.available && root.active.canTogglePlaying

    readonly property bool canNext: root.available && root.active.canGoNext

    readonly property bool canPrevious: root.available && root.active.canGoPrevious

    function toggle() {
        if (root.canToggle)
            root.active.togglePlaying();
    }

    function next() {
        if (root.canNext)
            root.active.next();
    }

    function previous() {
        if (root.canPrevious)
            root.active.previous();
    }
}
