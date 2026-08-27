pragma Singleton

import QtQuick

// Icons

QtObject {
    // Network — Wi-Fi strength ramp

    readonly property string wifi0: "\udb82\udd1f"        // F091F
    readonly property string wifi1: "\udb82\udd22"        // F0922
    readonly property string wifi2: "\udb82\udd25"        // F0925
    readonly property string wifi3: "\udb82\udd28"        // F0928
    readonly property string wifiOff: "\udb82\udd2d"      // F092D
    readonly property string wifiNone: "\udb82\udd2f"     // F092F

    readonly property string ethernet: "\udb80\ude00"     // F0200

    // Bluetooth

    readonly property string bluetooth: "\udb80\udcaf"    // F00AF
    readonly property string btConnected: "\udb80\udcb1"  // F00B1
    readonly property string btOff: "\udb80\udcb2"        // F00B2

    // Audio

    readonly property string volumeHigh: "\udb81\udd7e"   // F057E
    readonly property string volumeLow: "\udb81\udd7f"    // F057F
    readonly property string volumeMedium: "\udb81\udd80" // F0580
    readonly property string volumeOff: "\udb81\udd81"    // F0581

    readonly property string mic: "\udb80\udf6c"          // F036C
    readonly property string micOff: "\udb80\udf6d"       // F036D

    readonly property string speaker: "\udb81\udd8f"      // F058F
    readonly property string headset: "\udb81\udcd0"      // F04D0

    // Battery — discharging ramp, 0% .. 100%

    readonly property var batteryRamp: ["\udb80\udc8e"  // F008E  empty
        , "\udb80\udc7a"  // F007A  10
        , "\udb80\udc7b"  // F007B  20
        , "\udb80\udc7c"  // F007C  30
        , "\udb80\udc7d"  // F007D  40
        , "\udb80\udc7e"  // F007E  50
        , "\udb80\udc7f"  // F007F  60
        , "\udb80\udc80"  // F0080  70
        , "\udb80\udc81"  // F0081  80
        , "\udb80\udc82"  // F0082  90
        , "\udb80\udc79"   // F0079  full
    ]

    readonly property var batteryChargeRamp: ["\udb82\udc9c"  // F089C
        , "\udb82\udc9c"  // F089C
        , "\udb80\udc86"  // F0086
        , "\udb80\udc87"  // F0087
        , "\udb80\udc88"  // F0088
        , "\udb82\udc9d"  // F089D
        , "\udb80\udc89"  // F0089
        , "\udb82\udc9e"  // F089E
        , "\udb80\udc8a"  // F008A
        , "\udb80\udc8b"  // F008B
        , "\udb80\udc85"   // F0085
    ]

    readonly property string batteryAlert: "\udb80\udc83"   // F0083
    readonly property string batteryUnknown: "\udb80\udc8f" // F008F
    readonly property string plug: "\udb81\udea5"           // F06A5

    readonly property string profileSaver: "\udb80\udf2a"       // F032A
    readonly property string profileBalanced: "\udb81\uddd1"    // F05D1
    readonly property string profilePerformance: "\udb81\udcc5" // F04C5
    readonly property string health: "\udb81\uddf6"             // F05F6

    readonly property string brightness: "\udb80\udce0"     // F00E0

    // Brightness ramp, dim -> bright (mdi-brightness-4..7).
    readonly property var brightnessRamp: ["\udb80\udcde", "\udb80\udcdf", "\udb80\udce0", "\udb80\udce1"]

    // fraction is 0..1.
    function forBrightness(fraction) {
        const f = Math.max(0, Math.min(1, fraction));

        const i = Math.min(brightnessRamp.length - 1, Math.floor(f * brightnessRamp.length));

        return brightnessRamp[i];
    }

    readonly property string bell: "\udb80\udc9c"            // F009C  bell-outline
    readonly property string bellFilled: "\udb80\udc9a"      // F009A  bell
    readonly property string bellOff: "\udb80\udc9b"         // F009B  bell-off
    readonly property string bellRing: "\udb80\udc9e"        // F009E  bell-ring
    readonly property string bellRingOutline: "\udb80\udc9f" // F009F  bell-ring-outline

    // Alias kept so existing call sites keep resolving.
    readonly property string bellBadge: bellRing

    // App-class glyphs.
    readonly property string alert: "\udb80\udc26"        // F0026
    readonly property string alertCircle: "\udb80\udc28"  // F0028
    readonly property string email: "\udb80\uddee"        // F01EE
    readonly property string message: "\udb80\udf61"      // F0361
    readonly property string musicNote: "\udb80\udf87"    // F0387
    readonly property string download: "\udb80\uddda"     // F01DA
    readonly property string folder: "\udb80\ude4b"       // F024B
    readonly property string terminal: "\udb80\udd8d"      // F018D
    readonly property string image: "\udb80\udee9"        // F02E9
    readonly property string power: "\udb81\udc25"        // F0425
    readonly property string web: "\udb81\udd9f"          // F059F
    readonly property string timer: "\udb81\udd1b"        // F051B

    // Best-effort app-name -> glyph mapping.
    function forApp(appName) {
        const n = String(appName === undefined ? "" : appName).toLowerCase();

        if (n === "")
            return bell;

        if (n.indexOf("thunderbird") >= 0 || n.indexOf("mail") >= 0 || n.indexOf("gmail") >= 0 || n.indexOf("evolution") >= 0)
            return email;

        if (n.indexOf("discord") >= 0 || n.indexOf("telegram") >= 0 || n.indexOf("signal") >= 0 || n.indexOf("slack") >= 0 || n.indexOf("element") >= 0 || n.indexOf("whatsapp") >= 0 || n.indexOf("chat") >= 0 || n.indexOf("message") >= 0)
            return message;

        if (n.indexOf("spotify") >= 0 || n.indexOf("music") >= 0 || n.indexOf("mpd") >= 0 || n.indexOf("vlc") >= 0 || n.indexOf("mpv") >= 0 || n.indexOf("audacious") >= 0)
            return musicNote;

        if (n.indexOf("firefox") >= 0 || n.indexOf("chrom") >= 0 || n.indexOf("brave") >= 0 || n.indexOf("librewolf") >= 0 || n.indexOf("qutebrowser") >= 0)
            return web;

        if (n.indexOf("transmission") >= 0 || n.indexOf("qbittorrent") >= 0 || n.indexOf("download") >= 0 || n.indexOf("wget") >= 0)
            return download;

        if (n.indexOf("nautilus") >= 0 || n.indexOf("thunar") >= 0 || n.indexOf("dolphin") >= 0 || n.indexOf("nemo") >= 0 || n.indexOf("file") >= 0)
            return folder;

        if (n.indexOf("screenshot") >= 0 || n.indexOf("grim") >= 0 || n.indexOf("flameshot") >= 0 || n.indexOf("satty") >= 0)
            return camera;

        if (n.indexOf("gimp") >= 0 || n.indexOf("image") >= 0 || n.indexOf("viewer") >= 0 || n.indexOf("imv") >= 0)
            return image;

        if (n.indexOf("kitty") >= 0 || n.indexOf("alacritty") >= 0 || n.indexOf("foot") >= 0 || n.indexOf("term") >= 0 || n.indexOf("shell") >= 0 || n.indexOf("zsh") >= 0)
            return terminal;

        if (n.indexOf("volume") >= 0 || n.indexOf("audio") >= 0 || n.indexOf("pipewire") >= 0 || n.indexOf("pulse") >= 0)
            return volumeHigh;

        if (n.indexOf("battery") >= 0 || n.indexOf("upower") >= 0)
            return batteryAlert;

        if (n.indexOf("power") >= 0 || n.indexOf("logout") >= 0)
            return power;

        if (n.indexOf("network") >= 0 || n.indexOf("wifi") >= 0 || n.indexOf("nm-") >= 0)
            return wifi3;

        if (n.indexOf("blue") >= 0)
            return bluetooth;

        if (n.indexOf("calendar") >= 0 || n.indexOf("remind") >= 0)
            return calendar;

        if (n.indexOf("timer") >= 0 || n.indexOf("clock") >= 0 || n.indexOf("alarm") >= 0 || n.indexOf("pomodoro") >= 0)
            return timer;

        return bell;
    }

    // Generic UI

    readonly property string check: "\udb80\udc93"

    readonly property string close: "\udb80\udd56"

    readonly property string checkCircle: "\udb80\udd34"

    readonly property string closeCircle: "\udb80\udd59"

    readonly property string chevronDown: "\udb80\udd40"
    readonly property string chevronLeft: "\udb80\udd41"
    readonly property string chevronRight: "\udb80\udd42"
    readonly property string chevronUp: "\udb80\udd43"

    readonly property string calendar: "\udb80\udced"
    readonly property string info: "\udb80\udd7c"
    readonly property string gear: "\udb81\udc93"

    readonly property string refresh: "\udb81\udc50"
    readonly property string lock: "\udb80\udfba"
    readonly property string send: "\udb81\udc0c"
    readonly property string spinner: "\udb81\udd1e"
    readonly property string link: "\udb80\udd74"
    readonly property string linkOff: "\udb80\udd75"
    readonly property string accountPlus: "\udb80\udd7f"

    readonly property string search: "\udb80\udf49"
    readonly property string clipboard: "\udb80\udd47"
    readonly property string trash: "\udb80\uddb4"
    readonly property string emoji: "\uf118"

    // Device classes (Bluetooth / battery peripherals)

    readonly property string phone: "\udb80\udcb6"
    readonly property string camera: "\udb80\udd00"
    readonly property string printer: "\udb80\udeb7"
    readonly property string keyboard: "\udb80\udf0c"
    readonly property string computer: "\udb80\udf79"
    readonly property string mouse: "\udb80\udf7c"
    readonly property string watch: "\udb81\udd71"
    readonly property string gamepad: "\udb81\udd8b"
}
