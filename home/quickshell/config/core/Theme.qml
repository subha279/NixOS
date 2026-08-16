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

    // Raised surface inside menus (rows, fields)
    readonly property color surface: "#14ffffff"
    readonly property color surfaceHover: "#22ffffff"
    readonly property color surfaceActive: "#2eb58cff"

    // Text
    readonly property color foreground: "#f2f2f5"
    readonly property color foregroundMuted: "#a8a8b3"
    readonly property color foregroundFaint: "#6e6e7a"

    // Accent
    readonly property color accent: "#b58cff"
    readonly property color accentSoft: "#6f5aa8"

    // Semantic
    readonly property color success: "#7ee2a8"
    readonly property color warning: "#ffcc70"
    readonly property color danger: "#ff7b8a"

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

    // Distance from the top of the screen to the bar window.
    // Popups use this to convert bar coordinates into screen ones.
    readonly property int barMarginTop: 8

    readonly property int radius: 999
    readonly property int radiusMenu: 18
    readonly property int radiusRow: 12

    readonly property int padding: 10
    readonly property int spacing: 6

    readonly property int fontSize: 12
    readonly property int fontSizeSmall: 10
    readonly property int fontSizeLarge: 13
    readonly property int iconSize: 16

    readonly property string fontFamily:
        "JetBrains Mono Nerd Font"

    // ============================================================
    // Popup geometry
    // ============================================================

    readonly property int popupWidth: 340
    readonly property int popupMaxHeight: 460

    // Vertical distance between the bottom of the bar pill and the
    // top of a dropdown. Keep this small so menus feel attached.
    readonly property int popupGap: 2

    readonly property int rowHeight: 42

    // ============================================================
    // Motion — the "rubbery / organic" feel
    // ============================================================

    // Spring used for the popup's height as content grows / shrinks.
    readonly property real springStiffness: 3.2
    readonly property real springDamping: 0.32
    readonly property real springEpsilon: 0.25
    readonly property real springMass: 1.1

    // Fade + slide of the inner content
    readonly property int durFast: 120
    readonly property int durBase: 200
    readonly property int durSlow: 320

    // Open / close of the whole card
    readonly property int durOpen: 360
    readonly property int durClose: 200

    readonly property real overshoot: 1.6

    // ============================================================
    // Collapsing bar
    // ============================================================

    // How long the modules take to slide out / fold away when the
    // pointer enters or leaves the pill.
    readonly property int barRevealDuration: 380
    readonly property int barHideDuration: 260

    // Grace period before the bar folds back up, so brushing past
    // the pill doesn't cause a flicker.
    readonly property int barCollapseDelay: 260
}
