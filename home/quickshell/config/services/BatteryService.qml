pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../core" as Core

// BatteryService

Singleton {
    id: root

    // Main battery

    readonly property var device: (typeof UPower !== "undefined" && UPower.displayDevice) ? UPower.displayDevice : null

    // True when this machine actually has a battery worth showing.
    readonly property bool available: root.device !== null && root.device.isPresent === true && root.device.isLaptopBattery !== false

    // 0..100, always.
    readonly property real percent: root.device ? root.normalise(root.device.percentage) : 0

    readonly property int percentInt: Math.round(root.percent)

    // UPowerDeviceState numeric values: 0 Unknown 1 Charging 2 Discharging 3 Empty 4 FullyCharged 5 PendingCharge 6 PendingDischarge
    readonly property int state: root.device ? root.device.state : 0

    readonly property bool charging: root.state === 1 || root.state === 5

    readonly property bool full: root.state === 4

    readonly property bool discharging: root.state === 2 || root.state === 6

    // AC connected (either explicitly charging, full, or UPower says we are not running on battery).
    readonly property bool onAc: root.charging || root.full || (typeof UPower !== "undefined" && UPower.onBattery === false)

    readonly property int secondsToEmpty: root.device && root.device.timeToEmpty ? root.device.timeToEmpty : 0

    readonly property int secondsToFull: root.device && root.device.timeToFull ? root.device.timeToFull : 0

    // Watts. Negative means draining in some builds — take abs.
    readonly property real changeRate: root.device && root.device.changeRate ? Math.abs(root.device.changeRate) : 0

    readonly property real health: (root.device && root.device.healthSupported && root.device.healthPercentage) ? root.normalise(root.device.healthPercentage) : -1

    // Warning levels

    readonly property int lowThreshold: 20
    readonly property int criticalThreshold: 10

    readonly property bool low: root.available && !root.onAc && root.percentInt <= root.lowThreshold

    readonly property bool critical: root.available && !root.onAc && root.percentInt <= root.criticalThreshold

    // Peripherals (mouse, keyboard, headset, controller...)

    property ListModel peripheralModel: ListModel {}

    readonly property var allDevices: (typeof UPower !== "undefined" && UPower.devices) ? UPower.devices.values : []

    onAllDevicesChanged: root.rebuildPeripherals()

    // Power profiles

    // 0 = power-saver, 1 = balanced, 2 = performance
    readonly property bool profilesAvailable: typeof PowerProfiles !== "undefined"

    readonly property int profile: root.profilesAvailable ? PowerProfiles.profile : 1

    readonly property bool hasPerformance: root.profilesAvailable ? PowerProfiles.hasPerformanceProfile !== false : false

    readonly property string degradationReason: (root.profilesAvailable && PowerProfiles.degradationReason) ? String(PowerProfiles.degradationReason) : ""

    function setProfile(value) {
        if (!root.profilesAvailable)
            return;
        try {
            PowerProfiles.profile = value;
        } catch (e) {
            root.lastError = "Could not switch power profile";
        }
    }

    property string lastError: ""

    // Derived labels

    readonly property string stateLabel: {
        if (!root.available)
            return "No battery";

        if (root.full)
            return "Fully charged";

        if (root.charging)
            return root.secondsToFull > 0 ? root.formatTime(root.secondsToFull) + " until full" : "Charging";

        if (root.discharging)
            return root.secondsToEmpty > 0 ? root.formatTime(root.secondsToEmpty) + " remaining" : "On battery";

        if (root.onAc)
            return "Plugged in";

        return "Unknown";
    }

    readonly property string profileLabel: {
        if (!root.profilesAvailable)
            return "";

        switch (root.profile) {
        case 0:
            return "Power saver";
        case 2:
            return "Performance";
        default:
            return "Balanced";
        }
    }

    // Icons (Nerd Font, Material Design set)

    readonly property var dischargeIcons: ["\udb80\udc8e" // 0%   battery-outline
        , "\udb80\udc7a" // 10%
        , "\udb80\udc7b" // 20%
        , "\udb80\udc7c" // 30%
        , "\udb80\udc7d" // 40%
        , "\udb80\udc7e" // 50%
        , "\udb80\udc7f" // 60%
        , "\udb80\udc80" // 70%
        , "\udb80\udc81" // 80%
        , "\udb80\udc82" // 90%
        , "\udb80\udc79"  // 100% battery
    ]

    readonly property var chargeIcons: ["\udb82\udc9c" // 0%
        , "\udb82\udc9c" // 10%
        , "\udb80\udc86" // 20%
        , "\udb80\udc87" // 30%
        , "\udb80\udc88" // 40%
        , "\udb82\udc9d" // 50%
        , "\udb80\udc89" // 60%
        , "\udb82\udc9e" // 70%
        , "\udb80\udc8a" // 80%
        , "\udb80\udc8b" // 90%
        , "\udb80\udc85"  // 100%
    ]

    readonly property string alertIcon: "\udb80\udc83"
    readonly property string unknownIcon: "\udb80\udc8f"
    readonly property string plugIcon: "\udb81\udea5"

    readonly property string saverIcon: "\udb80\udf2a"
    readonly property string balancedIcon: "\udb81\uddd1"
    readonly property string performanceIcon: "\udb81\udcc5"
    readonly property string healthIcon: "\udb81\uddf6"

    // The single glyph the bar shows.
    readonly property string icon: {
        if (!root.available)
            return root.plugIcon;

        if (root.critical && !root.charging)
            return root.alertIcon;

        const idx = Math.max(0, Math.min(10, Math.round(root.percent / 10)));

        return root.charging || root.full ? root.chargeIcons[idx] : root.dischargeIcons[idx];
    }

    // These are semantic states that already exist in the theme.

    readonly property color color: {
        if (!root.available)
            return Core.Theme.foregroundMuted;

        if (root.critical)
            return Core.Theme.danger;

        if (root.low)
            return Core.Theme.warning;

        if (root.charging || root.full)
            return Core.Theme.success;

        return Core.Theme.foreground;
    }

    function profileIcon(value) {
        switch (value) {
        case 0:
            return root.saverIcon;
        case 2:
            return root.performanceIcon;
        default:
            return root.balancedIcon;
        }
    }

    // Helpers

    // UPower gives 0..1 in most builds, 0..100 in a few.
    function normalise(value) {
        if (value === undefined || value === null)
            return 0;

        const v = Number(value);

        if (isNaN(v))
            return 0;

        return v <= 1.0 ? v * 100 : v;
    }

    function formatTime(seconds) {
        if (!seconds || seconds <= 0)
            return "";

        const total = Math.round(seconds / 60);

        const h = Math.floor(total / 60);
        const m = total % 60;

        if (h <= 0)
            return m + "m";

        if (m <= 0)
            return h + "h";

        return h + "h " + m + "m";
    }

    function deviceIcon(dev) {
        const generic = "\udb80\udf79";

        if (!dev)
            return generic;

        // Prefer the UPower type enum when the build exposes it.
        try {
            const t = dev.type;

            if (t === UPowerDeviceType.Mouse)
                return "\udb80\udf7c";

            if (t === UPowerDeviceType.Keyboard)
                return "\udb80\udf0c";

            if (t === UPowerDeviceType.Headphones || t === UPowerDeviceType.Headset)
                return "\udb81\udcd0";

            if (t === UPowerDeviceType.Speakers)
                return "\udb81\udd8f";

            if (t === UPowerDeviceType.Phone)
                return "\udb80\udcb6";

            if (t === UPowerDeviceType.GamingInput)
                return "\udb81\udd8b";

            if (t === UPowerDeviceType.Tablet)
                return "\udb81\udd71";
        } catch (e) {
            // enum not available in this build — fall through
        }

        // Fall back to the freedesktop icon name string.
        const name = String(dev.iconName || "").toLowerCase();

        if (name.indexOf("mouse") >= 0)
            return "\udb80\udf7c";

        if (name.indexOf("keyboard") >= 0)
            return "\udb80\udf0c";

        if (name.indexOf("headset") >= 0 || name.indexOf("headphone") >= 0 || name.indexOf("audio") >= 0)
            return "\udb81\udcd0";

        if (name.indexOf("phone") >= 0)
            return "\udb80\udcb6";

        if (name.indexOf("gaming") >= 0)
            return "\udb81\udd8b";

        return generic;
    }

    function deviceLabel(dev) {
        if (!dev)
            return "Device";

        if (dev.model && String(dev.model).length > 0)
            return String(dev.model);

        if (dev.nativePath && String(dev.nativePath).length > 0)
            return String(dev.nativePath);

        return "Device";
    }

    // Peripheral list building

    function rebuildPeripherals() {
        const items = [];

        const list = root.allDevices || [];

        for (let i = 0; i < list.length; i++) {
            const dev = list[i];

            if (!dev)
                continue;

            // Skip the laptop battery + the synthetic display device + AC adapters — they have no useful percent.
            if (dev === root.device)
                continue;
            if (dev.isLaptopBattery === true)
                continue;
            if (dev.isPresent === false)
                continue;
            const pct = root.normalise(dev.percentage);

            if (pct <= 0)
                continue;
            items.push({
                label: root.deviceLabel(dev),
                deviceIcon: root.deviceIcon(dev),
                percent: Math.round(pct),
                charging: dev.state === 1
            });
        }

        items.sort(function (a, b) {
            return a.percent - b.percent;
        });

        root.syncModel(root.peripheralModel, items, "label");
    }

    // Reconcile a ListModel in place so ListView add/remove transitions actually run instead of everything flashing.
    function syncModel(model, items, key) {
        for (let i = model.count - 1; i >= 0; i--) {
            const existing = model.get(i);

            let stillThere = false;

            for (let j = 0; j < items.length; j++) {
                if (items[j][key] === existing[key]) {
                    stillThere = true;
                    break;
                }
            }

            if (!stillThere)
                model.remove(i);
        }

        for (let i = 0; i < items.length; i++) {
            const item = items[i];

            let foundAt = -1;

            for (let j = 0; j < model.count; j++) {
                if (model.get(j)[key] === item[key]) {
                    foundAt = j;
                    break;
                }
            }

            if (foundAt < 0) {
                model.insert(Math.min(i, model.count), item);
            } else {
                model.set(foundAt, item);

                if (foundAt !== i)
                    model.move(foundAt, Math.min(i, model.count - 1), 1);
            }
        }
    }

    // External helpers

    Process {
        id: launcher
    }

    function launch(command) {
        launcher.running = false;
        launcher.command = command;
        launcher.running = true;
    }

    function openPowerSettings() {
        // Try the usual suspects; the first one installed wins.
        root.launch(["sh", "-c", "command -v gnome-control-center >/dev/null " + "&& gnome-control-center power " + "|| command -v xfce4-power-manager-settings " + ">/dev/null && xfce4-power-manager-settings " + "|| command -v powerprofilesctl >/dev/null " + "&& powerprofilesctl list"]);
    }

    function copySummary() {
        const text = root.percentInt + "% — " + root.stateLabel;

        try {
            Quickshell.clipboardText = text;
        } catch (e) {
            root.launch(["sh", "-c", "printf %s " + JSON.stringify(text) + " | wl-copy"]);
        }
    }

    // Lifecycle

    Component.onCompleted: root.rebuildPeripherals()

    // UPower is event driven, but peripheral percentages update lazily — a slow tick keeps them honest without any cost.
    Timer {
        interval: 30000
        running: true
        repeat: true

        onTriggered: root.rebuildPeripherals()
    }
}
