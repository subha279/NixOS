pragma Singleton

import QtQuick

QtObject {
    // ============================================================
    // Aurora Glass Design System
    // ============================================================

    // The base is a soft, slightly warm ink rather than pure
    // black. Pure black against a wallpaper reads as a hole; a
    // touch of blue-violet lets the panel sit in the image.
    readonly property color ink: "#1a1a24"
    readonly property color inkDeep: "#12121a"

    // Main glass surface
    readonly property color background: "#d91a1a24"

    // Solid surface for menus / important UI
    readonly property color backgroundSolid: "#f51a1a24"

    // Raised surfaces inside menus (rows, fields).
    // Kept as low-alpha white so they pick up whatever is behind
    // the glass instead of fighting it with a fixed colour.
    readonly property color surface: "#0fffffff"
    readonly property color surfaceHover: "#19ffffff"
    readonly property color surfaceActive: "#24b3a4f5"

    // Text — three steps is enough. Anything more reads as noise.
    readonly property color foreground: "#e6e4ef"
    readonly property color foregroundMuted: "#9b98ad"
    readonly property color foregroundFaint: "#605d75"

    // Accent: a desaturated lavender. The old #b58cff was a fully
    // saturated violet that glowed against everything next to it.
    readonly property color accent: "#b3a4f5"
    readonly property color accentSoft: "#6a5f9e"
    readonly property color accentDim: "#3a3455"

    // Semantic colours are muted to roughly the same chroma as the
    // accent, so nothing shouts louder than anything else.
    readonly property color success: "#8fd3a8"
    readonly property color warning: "#e6c68f"
    readonly property color danger: "#e58fa0"
    readonly property color info: "#8fb8d3"

    // Glass borders — deliberately faint. A hard 1px white border
    // is the fastest way to make a panel look cheap.
    readonly property color border: "#24ffffff"
    readonly property color separator: "#16ffffff"

    // Interaction states
    readonly property color hover: "#14ffffff"
    readonly property color pressed: "#26ffffff"

    // Text colour to place ON an accent fill (today's date, toggle
    // knobs, badges). Always the deep ink, never white.
    readonly property color accentForeground: "#16161f"

    // ============================================================
    // Glass
    // ============================================================

    readonly property real glassOpacity: 0.80

    // A slightly deeper shadow lets the popups detach from the
    // wallpaper without needing a brighter border.
    readonly property real shadowOpacity: 0.20

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

    readonly property string uiFontFamily:
        "Inter"

    readonly property string monoFontFamily:
        "JetBrains Mono Nerd Font"

    readonly property string iconFontFamily:
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
