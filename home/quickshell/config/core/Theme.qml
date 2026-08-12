pragma Singleton

import QtQuick

QtObject {
    // ============================================================
    // Aurora Glass Design System
    // ============================================================

    // Main glass surface
    readonly property color background: "#cc16161f"

    // Solid surface for menus / important UI
    readonly property color backgroundSolid: "#f216161f"

    // Text
    readonly property color foreground: "#f2f2f5"
    readonly property color foregroundMuted: "#a8a8b3"

    // Accent
    readonly property color accent: "#b58cff"
    readonly property color accentSoft: "#6f5aa8"

    // Glass borders
    readonly property color border: "#35ffffff"
    readonly property color separator: "#25ffffff"

    // Interaction states
    readonly property color hover: "#20ffffff"
    readonly property color pressed: "#35ffffff"

    // ============================================================
    // Glass
    // ============================================================

    readonly property real glassOpacity: 0.80
    readonly property real shadowOpacity: 0.12

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
