pragma Singleton

import QtQuick

QtObject {
    // ============================================================
    // Aurora / Stylix glass palette
    // ============================================================

    readonly property color background: "#cc16161f"
    readonly property color backgroundSolid: "#f216161f"

    readonly property color foreground: "#f2f2f5"
    readonly property color foregroundMuted: "#a8a8b3"

    readonly property color accent: "#b58cff"
    readonly property color accentSoft: "#6f5aa8"

    readonly property color border: "#30ffffff"
    readonly property color separator: "#20ffffff"

    readonly property color hover: "#18ffffff"
    readonly property color pressed: "#28ffffff"

    // ============================================================
    // Layout
    // ============================================================

    readonly property int pillHeight: 32
    readonly property int moduleHeight: 30

    readonly property int radius: 999

    readonly property int fontSize: 12
    readonly property int iconSize: 16

    readonly property string fontFamily:
        "JetBrains Mono Nerd Font"
}
