pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Services.Mpris

// MprisService
//
// Thin wrapper around the MPRIS players Quickshell exposes over D-Bus.
//
// Everything the bar needs is flattened into plain properties (available /
// playing / title / artist) so NowPlaying.qml stays a pure view and never has
// to import the Mpris module or reach into Mpris.players itself.

Singleton {
    id: root

    // Players

    readonly property var players: (Mpris.players && Mpris.players.values) ? Mpris.players.values : []

    // Active player
    //
    // Prefers whatever is actually playing, then whatever carries track
    // metadata, then simply the first player that registered. Browsers publish
    // a player per tab, so picking blindly would happily show a paused YouTube
    // tab while Spotify is the thing making noise.

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

    // Track info

    readonly property string title: root.available ? String(root.active.trackTitle || "") : ""

    readonly property string artist: root.available ? String(root.active.trackArtist || "") : ""

    readonly property string identity: root.available ? String(root.active.identity || "") : ""

    // What the bar prints.
    //
    // Falls back to the player name so the module never shows an empty label
    // while a stream is still resolving its metadata.
    readonly property string label: {
        if (!root.available)
            return "";

        if (root.title !== "")
            return root.title;

        if (root.identity !== "")
            return root.identity;

        return "Playing";
    }

    // Controls
    //
    // Guarded individually: MPRIS compliance varies wildly by player, so the
    // canXyz flags are the only safe way to call any of this.

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
