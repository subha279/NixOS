pragma Singleton

import QtQuick

// ================================================================
// Icons
// ----------------------------------------------------------------
// Central registry of every Nerd Font glyph the shell uses.
//
// WHY THIS EXISTS
// Glyphs above U+FFFF have to be written as surrogate pairs in QML
// string literals, and hand-computing those pairs is extremely
// error prone — several icons in this config were silently
// rendering the wrong symbol because a pair was off by one block.
//
// Every codepoint below is recorded in the comment next to it. To
// convert a codepoint `cp` to a pair:
//
//     v    = cp - 0x10000
//     high = 0xD800 + (v >> 10)
//     low  = 0xDC00 + (v & 0x3FF)
//
// Prefer OUTLINE variants where a choice exists — they read as
// lighter and sit better next to text at 12-16px.
// ================================================================

QtObject {
    // ------------------------------------------------------------
    // Network — Wi-Fi strength ramp
    // ------------------------------------------------------------

    readonly property string wifi0: "\udb82\udd1f"        // F091F
    readonly property string wifi1: "\udb82\udd22"        // F0922
    readonly property string wifi2: "\udb82\udd25"        // F0925
    readonly property string wifi3: "\udb82\udd28"        // F0928
    readonly property string wifiOff: "\udb82\udd2d"      // F092D
    readonly property string wifiNone: "\udb82\udd2f"     // F092F

    readonly property string ethernet: "\udb80\ude00"     // F0200

    // ------------------------------------------------------------
    // Bluetooth
    // ------------------------------------------------------------

    readonly property string bluetooth: "\udb80\udcaf"    // F00AF
    readonly property string btConnected: "\udb80\udcb1"  // F00B1
    readonly property string btOff: "\udb80\udcb2"        // F00B2

    // ------------------------------------------------------------
    // Audio
    // ------------------------------------------------------------

    readonly property string volumeHigh: "\udb81\udd7e"   // F057E
    readonly property string volumeLow: "\udb81\udd7f"    // F057F
    readonly property string volumeMedium: "\udb81\udd80" // F0580
    readonly property string volumeOff: "\udb81\udd81"    // F0581

    readonly property string mic: "\udb80\udf6c"          // F036C
    readonly property string micOff: "\udb80\udf6d"       // F036D

    readonly property string speaker: "\udb81\udd8f"      // F058F
    readonly property string headset: "\udb81\udcd0"      // F04D0

    // ------------------------------------------------------------
    // Battery — discharging ramp, 0% .. 100%
    // ------------------------------------------------------------

    readonly property var batteryRamp: [
        "\udb80\udc8e",  // F008E  empty
        "\udb80\udc7a",  // F007A  10
        "\udb80\udc7b",  // F007B  20
        "\udb80\udc7c",  // F007C  30
        "\udb80\udc7d",  // F007D  40
        "\udb80\udc7e",  // F007E  50
        "\udb80\udc7f",  // F007F  60
        "\udb80\udc80",  // F0080  70
        "\udb80\udc81",  // F0081  80
        "\udb80\udc82",  // F0082  90
        "\udb80\udc79"   // F0079  full
    ]

    readonly property var batteryChargeRamp: [
        "\udb82\udc9c",  // F089C
        "\udb82\udc9c",  // F089C
        "\udb80\udc86",  // F0086
        "\udb80\udc87",  // F0087
        "\udb80\udc88",  // F0088
        "\udb82\udc9d",  // F089D
        "\udb80\udc89",  // F0089
        "\udb82\udc9e",  // F089E
        "\udb80\udc8a",  // F008A
        "\udb80\udc8b",  // F008B
        "\udb80\udc85"   // F0085
    ]

    readonly property string batteryAlert: "\udb80\udc83"   // F0083
    readonly property string batteryUnknown: "\udb80\udc8f" // F008F
    readonly property string plug: "\udb81\udea5"           // F06A5

    readonly property string profileSaver: "\udb80\udf2a"       // F032A
    readonly property string profileBalanced: "\udb81\uddd1"    // F05D1
    readonly property string profilePerformance: "\udb81\udcc5" // F04C5
    readonly property string health: "\udb81\uddf6"             // F05F6

    readonly property string brightness: "\udb80\udce0"     // F00E0

    // ------------------------------------------------------------
    // Notifications
    // ------------------------------------------------------------

    readonly property string bell: "\udb80\udc9c"       // F009C
    readonly property string bellOff: "\udb80\udc9a"    // F009A
    readonly property string bellBadge: "\udb81\udf9e"  // F079E

    // ------------------------------------------------------------
    // Generic UI
    // ------------------------------------------------------------

    readonly property string check: "\udb80\udc93"        // F0093
    readonly property string close: "\udb80\udc94"        // F0094
    readonly property string checkCircle: "\udb80\udd34"  // F0134
    readonly property string closeCircle: "\udb80\udd5c"  // F015C

    readonly property string chevronDown: "\udb80\udd40"  // F0140
    readonly property string chevronLeft: "\udb80\udd41"  // F0141
    readonly property string chevronRight: "\udb80\udd42" // F0142
    readonly property string chevronUp: "\udb80\udd43"    // F0143

    readonly property string calendar: "\udb80\udced"     // F00ED
    readonly property string search: "\udb80\udd6c"       // F016C
    readonly property string info: "\udb80\udd7c"         // F017C
    readonly property string gear: "\udb80\udf93"         // F0393
    readonly property string lock: "\udb80\udfba"         // F03BA
    readonly property string send: "\udb81\udc0c"         // F040C
    readonly property string clipboard: "\udb81\udcd6"    // F04D6
    readonly property string spinner: "\udb81\udd1e"      // F051E
    readonly property string trash: "\udb80\uddb4"        // F01B4
    readonly property string link: "\udb80\udd74"         // F0174
    readonly property string linkOff: "\udb80\udd75"      // F0175
    readonly property string accountPlus: "\udb80\udd7f"  // F017F

    // ------------------------------------------------------------
    // Device classes (Bluetooth / battery peripherals)
    // ------------------------------------------------------------

    readonly property string phone: "\udb80\udcb6"     // F00B6
    readonly property string camera: "\udb80\udd00"    // F0100
    readonly property string printer: "\udb80\udeb7"   // F02B7
    readonly property string keyboard: "\udb80\udf0c"  // F030C
    readonly property string computer: "\udb80\udf79"  // F0379
    readonly property string mouse: "\udb80\udf7c"     // F037C
    readonly property string watch: "\udb81\udd71"     // F0571
    readonly property string gamepad: "\udb81\udd8b"   // F058B
}
