pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

import "../core" as Core

// AudioService

Singleton {
    id: root

    // Defaults

    readonly property var sink: Pipewire.defaultAudioSink

    readonly property var source: Pipewire.defaultAudioSource

    // Monitor sources are the "listen to what is playing" loopback devices.
    property bool showMonitors: false

    // Show per-application playback streams in the popup.
    property bool showStreams: true

    property string lastError: ""

    // Node lists

    readonly property var allNodes: (Pipewire.nodes && Pipewire.nodes.values) ? Pipewire.nodes.values : []

    readonly property var sinks: {
        const out = [];

        for (let i = 0; i < root.allNodes.length; i++) {
            const n = root.allNodes[i];

            if (!n || !n.audio)
                continue;
            if (n.isStream)
                continue;
            if (!n.isSink)
                continue;
            out.push(n);
        }

        out.sort(function (a, b) {
            return root.label(a).localeCompare(root.label(b));
        });

        return out;
    }

    readonly property var sources: {
        const out = [];

        for (let i = 0; i < root.allNodes.length; i++) {
            const n = root.allNodes[i];

            if (!n || !n.audio)
                continue;
            if (n.isStream)
                continue;
            if (n.isSink)
                continue;
            if (!root.showMonitors && root.isMonitor(n))
                continue;
            out.push(n);
        }

        out.sort(function (a, b) {
            return root.label(a).localeCompare(root.label(b));
        });

        return out;
    }

    // Per-application playback streams (Spotify, Firefox, ...).
    readonly property var streams: {
        const out = [];

        if (!root.showStreams)
            return out;

        for (let i = 0; i < root.allNodes.length; i++) {
            const n = root.allNodes[i];

            if (!n || !n.audio)
                continue;
            if (!n.isStream)
                continue;

            // Recording streams are noise in a volume mixer.
            if (!n.isSink)
                continue;
            out.push(n);
        }

        return out;
    }

    // Keep the audio properties of everything we display bound and live.
    readonly property var tracked: {
        const out = [];

        if (root.sink)
            out.push(root.sink);

        if (root.source)
            out.push(root.source);

        return out.concat(root.sinks).concat(root.sources).concat(root.streams);
    }

    property PwObjectTracker tracker: PwObjectTracker {
        objects: root.tracked
    }

    // Derived state for the bar

    readonly property real volume: (root.sink && root.sink.audio) ? root.sink.audio.volume : 0

    readonly property bool muted: (root.sink && root.sink.audio) ? root.sink.audio.muted : true

    readonly property int volumePercent: Math.round(root.volume * 100)

    readonly property real micVolume: (root.source && root.source.audio) ? root.source.audio.volume : 0

    readonly property bool micMuted: (root.source && root.source.audio) ? root.source.audio.muted : true

    readonly property int micPercent: Math.round(root.micVolume * 100)

    // OSD triggers

    onVolumeChanged: Core.OsdController.show("volume", root.volume, root.muted)

    onMutedChanged: Core.OsdController.show("volume", root.volume, root.muted)

    onMicMutedChanged: Core.OsdController.show("mic", root.micVolume, root.micMuted)

    // Icons

    readonly property string iconHigh: "\udb81\udd7e"
    readonly property string iconMedium: "\udb81\udd80"
    readonly property string iconLow: "\udb81\udd7f"
    readonly property string iconOff: "\udb81\udd81"

    readonly property string iconMic: "\udb80\udf6c"
    readonly property string iconMicOff: "\udb80\udf6d"

    readonly property string iconSpeaker: "\udb81\udd8f"
    readonly property string iconHeadset: "\udb81\udcd0"

    readonly property string icon: {
        if (!root.sink || !root.sink.audio)
            return root.iconOff;

        if (root.muted)
            return root.iconOff;

        if (root.volume <= 0.01)
            return root.iconLow;

        if (root.volume < 0.34)
            return root.iconLow;

        if (root.volume < 0.67)
            return root.iconMedium;

        return root.iconHigh;
    }

    readonly property string micIcon: (!root.source || root.micMuted) ? root.iconMicOff : root.iconMic

    // Helpers

    function label(node) {
        if (!node)
            return "Unknown device";

        if (node.description && node.description !== "")
            return node.description;

        if (node.nickname && node.nickname !== "")
            return node.nickname;

        if (node.name && node.name !== "")
            return node.name;

        return "Unknown device";
    }

    // Application name for a stream, falling back to the node name.
    function streamLabel(node) {
        if (!node)
            return "Unknown app";

        try {
            const props = node.properties;

            if (props) {
                if (props["application.name"])
                    return props["application.name"];

                if (props["media.name"])
                    return props["media.name"];
            }
        } catch (e) {
            // properties is optional depending on the build
        }

        return root.label(node);
    }

    function isMonitor(node) {
        if (!node || !node.name)
            return false;

        return node.name.indexOf(".monitor") >= 0;
    }

    // A rough guess at the device type, purely for the row icon.
    function iconFor(node) {
        if (!node)
            return root.iconSpeaker;

        const text = (root.label(node) + " " + (node.name ? node.name : "")).toLowerCase();

        if (text.indexOf("headset") >= 0 || text.indexOf("headphone") >= 0 || text.indexOf("hands-free") >= 0)
            return root.iconHeadset;

        if (!node.isSink)
            return root.iconMic;

        return root.iconSpeaker;
    }

    function isDefault(node) {
        if (!node)
            return false;

        if (node.isSink)
            return root.sink === node;

        return root.source === node;
    }

    function volumeOf(node) {
        if (!node || !node.audio)
            return 0;

        return node.audio.volume;
    }

    function mutedOf(node) {
        if (!node || !node.audio)
            return true;

        return node.audio.muted;
    }

    function percentOf(node) {
        return Math.round(root.volumeOf(node) * 100);
    }

    // Mutations

    // Hard ceiling.
    readonly property real maxVolume: 1.0

    function setVolume(node, value) {
        if (!node || !node.audio)
            return;
        const clamped = Math.max(0.0, Math.min(root.maxVolume, value));

        node.audio.volume = clamped;

        // Nudging the slider off zero should unmute, otherwise the control appears dead.
        if (clamped > 0.0 && node.audio.muted)
            node.audio.muted = false;
    }

    function stepVolume(node, delta) {
        root.setVolume(node, root.volumeOf(node) + delta);
    }

    function setMuted(node, value) {
        if (!node || !node.audio)
            return;
        node.audio.muted = value;
    }

    function toggleMute(node) {
        if (!node || !node.audio)
            return;
        node.audio.muted = !node.audio.muted;
    }

    function toggleOutputMute() {
        root.toggleMute(root.sink);
    }

    function toggleMicMute() {
        root.toggleMute(root.source);
    }

    function setDefaultSink(node) {
        if (!node)
            return;
        try {
            Pipewire.preferredDefaultAudioSink = node;
        } catch (e) {
            root.lastError = "Could not switch output device";
        }
    }

    function setDefaultSource(node) {
        if (!node)
            return;
        try {
            Pipewire.preferredDefaultAudioSource = node;
        } catch (e) {
            root.lastError = "Could not switch input device";
        }
    }

    function setDefault(node) {
        if (!node)
            return;
        if (node.isSink)
            root.setDefaultSink(node);
        else
            root.setDefaultSource(node);
    }

    // External tools

    property Process launcher: Process {
        id: launcherImpl
    }

    function launch(command) {
        if (launcherImpl.running)
            return;
        launcherImpl.command = command;
        launcherImpl.running = true;
    }

    function openMixer() {
        root.launch(["pavucontrol"]);
    }

    function openSettings() {
        root.launch(["pavucontrol", "-t", "3"]);
    }
}
