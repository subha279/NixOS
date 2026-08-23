pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// NetworkService

Singleton {
    id: root

    // Wi-Fi state

    property bool wifiEnabled: true
    property string wifiDevice: ""
    property string wifiState: "unavailable"   // nmcli device state
    property string activeSsid: ""
    property int activeSignal: 0

    readonly property bool wifiConnected: root.wifiState === "connected"

    // Ethernet state

    property string ethDevice: ""
    property string ethState: "unavailable"
    property string ethConnection: ""

    readonly property bool ethAvailable: root.ethDevice !== ""

    readonly property bool ethConnected: root.ethState === "connected"

    // Unified link

    readonly property string primaryLink: root.ethConnected ? "ethernet" : root.wifiConnected ? "wifi" : "none"

    readonly property bool online: root.primaryLink !== "none"

    readonly property string linkLabel: root.ethConnected ? (root.ethConnection !== "" ? root.ethConnection : "Ethernet") : root.wifiConnected ? root.activeSsid : root.wifiEnabled ? "Not connected" : "Wi-Fi off"

    // Scan results / saved profiles

    property var networks: []          // [{ ssid, strength, security, bssid, inUse, saved }]
    property var savedProfiles: []     // [ "HomeWifi", ... ]

    property bool scanning: false
    property bool busy: false
    property string pendingSsid: ""    // ssid currently being connected
    property string lastError: ""

    // Poll faster while a menu is open
    property bool fastPoll: false

    signal connectFailed(string ssid, string message)
    signal connectSucceeded(string ssid)

    // Desktop notifications

    property string lastLink: ""
    property bool linkPrimed: false

    // Fire and forget; a shared Process drops rapid back-to-back events.
    function notify(summary, body, icon, urgency) {
        Quickshell.execDetached(["notify-send", "-a", "Network", "-i", icon, "-u", urgency, summary, body]);
    }

    function linkFingerprint() {
        if (root.ethConnected)
            return "eth:" + (root.ethConnection !== "" ? root.ethConnection : "Ethernet");

        if (root.wifiConnected)
            return "wifi:" + root.activeSsid;

        if (!root.wifiEnabled)
            return "off";

        return "none";
    }

    function syncLinkNotification() {
        const now = root.linkFingerprint();

        if (now === root.lastLink)
            return;

        const prev = root.lastLink;

        root.lastLink = now;

        // The first evaluation lands while nmcli is still being polled for the first time.
        if (!root.linkPrimed) {
            root.linkPrimed = true;
            return;
        }

        if (now.indexOf("eth:") === 0) {
            root.notify("Ethernet connected", now.substring(4), "network-wired", "low");
            return;
        }

        if (now.indexOf("wifi:") === 0) {
            root.notify("Wi-Fi connected", now.substring(5), "network-wireless", "low");
            return;
        }

        if (now === "off") {
            root.notify("Wi-Fi off", "Radio disabled", "network-wireless-offline", "low");
            return;
        }

        if (prev.indexOf("wifi:") === 0) {
            root.notify("Wi-Fi disconnected", prev.substring(5), "network-wireless-offline", "normal");
            return;
        }

        if (prev.indexOf("eth:") === 0) {
            root.notify("Ethernet disconnected", prev.substring(4), "network-wired-disconnected", "normal");
            return;
        }

        root.notify("Disconnected", "No network connection", "network-offline", "normal");
    }

    onWifiStateChanged: root.syncLinkNotification()
    onEthStateChanged: root.syncLinkNotification()
    onActiveSsidChanged: root.syncLinkNotification()
    onEthConnectionChanged: root.syncLinkNotification()
    onWifiEnabledChanged: root.syncLinkNotification()

    // ------------------------------------------------------------
    // Live ListModel (stable rows => real add/remove animations)
    // ------------------------------------------------------------

    property ListModel networkModel: ListModel {}

    // Parsing helpers

    // nmcli -t escapes literal ':' as '\:'
    function splitFields(line) {
        const out = [];
        let cur = "";

        for (let i = 0; i < line.length; i++) {
            const c = line.charAt(i);

            if (c === "\\" && i + 1 < line.length) {
                cur += line.charAt(i + 1);
                i++;
            } else if (c === ":") {
                out.push(cur);
                cur = "";
            } else {
                cur += c;
            }
        }

        out.push(cur);
        return out;
    }

    function isSaved(ssid) {
        return root.savedProfiles.indexOf(ssid) !== -1;
    }

    function signalIcon(strength, secured) {
        if (strength >= 75)
            return "\udb82\udd28";
        if (strength >= 50)
            return "\udb82\udd25";
        if (strength >= 25)
            return "\udb82\udd22";
        return "\udb82\udd1f";
    }

    // True when any field of the incoming row differs from the row already in the model.
    function rowsDiffer(current, incoming) {
        for (const k in incoming) {
            if (current[k] !== incoming[k])
                return true;
        }

        return false;
    }

    // Keeps delegates alive so ListView add/remove/move transitions fire.
    function syncModel(model, items, key) {
        const freezeOrder = root.fastPoll;

        for (let i = model.count - 1; i >= 0; i--) {
            const existing = model.get(i)[key];
            let stillThere = false;

            for (let j = 0; j < items.length; j++) {
                if (items[j][key] === existing) {
                    stillThere = true;
                    break;
                }
            }

            if (!stillThere)
                model.remove(i);
        }

        for (let j = 0; j < items.length; j++) {
            const item = items[j];
            let found = -1;

            for (let i = 0; i < model.count; i++) {
                if (model.get(i)[key] === item[key]) {
                    found = i;
                    break;
                }
            }

            if (found === -1) {
                model.insert(freezeOrder ? model.count : Math.min(j, model.count), item);

                continue;
            }

            if (!freezeOrder && found !== j) {
                model.move(found, j, 1);
                found = j;
            }

            if (root.rowsDiffer(model.get(found), item))
                model.set(found, item);
        }
    }

    // Readers

    property Process deviceProc: Process {
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");

                let wifiDev = "";
                let wifiSt = "unavailable";
                let ethDev = "";
                let ethSt = "unavailable";
                let ethConn = "";

                for (const line of lines) {
                    if (line.trim() === "")
                        continue;
                    const f = root.splitFields(line);
                    if (f.length < 3)
                        continue;
                    const dev = f[0];
                    const type = f[1];
                    const state = f[2];
                    const conn = f.length > 3 ? f[3] : "";

                    if (type === "wifi" && wifiDev === "") {
                        wifiDev = dev;
                        wifiSt = state;
                    }

                    if (type === "ethernet" && ethDev === "") {
                        ethDev = dev;
                        ethSt = state;
                        ethConn = conn === "--" ? "" : conn;
                    }
                }

                root.wifiDevice = wifiDev;
                root.wifiState = wifiSt;
                root.ethDevice = ethDev;
                root.ethState = ethSt;
                root.ethConnection = ethConn;
            }
        }
    }

    property Process radioProc: Process {
        command: ["nmcli", "-t", "radio", "wifi"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() === "enabled";
            }
        }
    }

    property Process savedProc: Process {
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const names = [];

                for (const line of lines) {
                    if (line.trim() === "")
                        continue;
                    const f = root.splitFields(line);
                    if (f.length >= 1 && f[0] !== "")
                        names.push(f[0]);
                }

                root.savedProfiles = names;
            }
        }
    }

    property Process wifiListProc: Process {
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY,BSSID", "device", "wifi", "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const seen = {};
                const list = [];

                let activeSsid = "";
                let activeSignal = 0;

                for (const line of lines) {
                    if (line.trim() === "")
                        continue;
                    const f = root.splitFields(line);
                    if (f.length < 4)
                        continue;
                    const inUse = f[0].trim() === "*";
                    const ssid = f[1];
                    const strength = parseInt(f[2]) || 0;
                    const security = f[3].trim();
                    const bssid = f.length > 4 ? f[4] : "";

                    // Hidden networks have an empty SSID
                    if (ssid === "")
                        continue;
                    if (inUse) {
                        activeSsid = ssid;
                        activeSignal = strength;
                    }

                    // Collapse multiple APs of the same SSID, keeping the strongest one.
                    if (seen[ssid] !== undefined) {
                        const prev = list[seen[ssid]];

                        if (strength > prev.strength) {
                            prev.strength = strength;
                            prev.bssid = bssid;
                        }

                        if (inUse)
                            prev.inUse = true;

                        continue;
                    }

                    seen[ssid] = list.length;

                    list.push({
                        ssid: ssid,
                        strength: strength,
                        security: security === "" ? "Open" : security,
                        secured: security !== "",
                        bssid: bssid,
                        inUse: inUse,
                        saved: root.isSaved(ssid)
                    });
                }

                // Connected first, then by signal strength Sort on BUCKETED strength, never the raw value.
                list.sort(function (a, b) {
                    if (a.inUse !== b.inUse)
                        return a.inUse ? -1 : 1;

                    if (a.saved !== b.saved)
                        return a.saved ? -1 : 1;

                    const ba = Math.round(a.strength / 10);
                    const bb = Math.round(b.strength / 10);

                    if (ba !== bb)
                        return bb - ba;

                    return a.ssid < b.ssid ? -1 : (a.ssid > b.ssid ? 1 : 0);
                });

                root.activeSsid = activeSsid;
                root.activeSignal = activeSignal;
                root.networks = list;

                root.syncModel(root.networkModel, list, "ssid");

                root.scanning = false;
            }
        }
    }

    // Action runner (serialised queue)

    property var actionQueue: []
    property string currentTag: ""

    property Process actionProc: Process {
        id: actionProcImpl

        property string errText: ""

        stdout: StdioCollector {}

        stderr: StdioCollector {
            onStreamFinished: actionProcImpl.errText = text.trim()
        }

        onExited: function (exitCode) {
            const tag = root.currentTag;
            const err = actionProcImpl.errText;

            actionProcImpl.errText = "";
            root.currentTag = "";
            root.busy = false;

            if (exitCode !== 0) {
                root.lastError = err !== "" ? err : "Command failed";

                if (tag !== "")
                    root.connectFailed(tag, root.lastError);
            } else {
                root.lastError = "";

                if (tag !== "")
                    root.connectSucceeded(tag);
            }

            if (root.pendingSsid === tag)
                root.pendingSsid = "";

            root.refresh();
            root.drainQueue();
        }
    }

    function drainQueue() {
        if (root.busy)
            return;
        if (root.actionQueue.length === 0)
            return;
        const next = root.actionQueue.shift();

        root.busy = true;
        root.currentTag = next.tag;

        actionProcImpl.command = next.command;
        actionProcImpl.running = true;
    }

    function run(command, tag) {
        const q = root.actionQueue.slice();

        q.push({
            command: command,
            tag: tag === undefined ? "" : tag
        });

        root.actionQueue = q;
        root.drainQueue();
    }

    // Public API — Wi-Fi

    function toggleWifi() {
        root.run(["nmcli", "radio", "wifi", root.wifiEnabled ? "off" : "on"]);
    }

    function rescan() {
        if (!root.wifiEnabled)
            return;
        root.scanning = true;
        root.run(["nmcli", "device", "wifi", "rescan"]);

        rescanTimer.restart();
    }

    function connectWifi(ssid, password) {
        root.pendingSsid = ssid;
        root.lastError = "";

        if (password !== undefined && password !== "") {
            root.run(["nmcli", "device", "wifi", "connect", ssid, "password", password, "ifname", root.wifiDevice], ssid);
            return;
        }

        if (root.isSaved(ssid)) {
            root.run(["nmcli", "connection", "up", "id", ssid], ssid);
            return;
        }

        root.run(["nmcli", "device", "wifi", "connect", ssid], ssid);
    }

    function disconnectWifi() {
        if (root.wifiDevice === "")
            return;
        root.run(["nmcli", "device", "disconnect", root.wifiDevice]);
    }

    function forgetNetwork(ssid) {
        root.run(["nmcli", "connection", "delete", "id", ssid]);
    }

    function setAutoconnect(ssid, enabled) {
        root.run(["nmcli", "connection", "modify", "id", ssid, "connection.autoconnect", enabled ? "yes" : "no"]);
    }

    function connectHidden(ssid, password) {
        root.pendingSsid = ssid;

        const cmd = ["nmcli", "device", "wifi", "connect", ssid, "hidden", "yes"];

        if (password !== undefined && password !== "") {
            cmd.push("password");
            cmd.push(password);
        }

        root.run(cmd, ssid);
    }

    // Public API — Ethernet

    function connectEthernet(exclusive) {
        if (root.ethDevice === "")
            return;
        root.run(["nmcli", "device", "connect", root.ethDevice]);

        // "Click one and the other disappears"
        if (exclusive && root.wifiConnected)
            root.disconnectWifi();
    }

    function disconnectEthernet() {
        if (root.ethDevice === "")
            return;
        root.run(["nmcli", "device", "disconnect", root.ethDevice]);
    }

    function toggleEthernet() {
        if (root.ethConnected)
            root.disconnectEthernet();
        else
            root.connectEthernet(true);
    }

    // Misc

    function openEditor() {
        Quickshell.execDetached(["nm-connection-editor"]);
    }

    function refresh() {
        deviceProc.running = false;
        deviceProc.running = true;

        radioProc.running = false;
        radioProc.running = true;

        savedProc.running = false;
        savedProc.running = true;

        wifiListProc.running = false;
        wifiListProc.running = true;
    }

    property Timer rescanTimer: Timer {
        interval: 2500
        repeat: false
        onTriggered: root.refresh()
    }

    property Timer pollTimer: Timer {
        interval: root.fastPoll ? 3000 : 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
