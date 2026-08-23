pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: theme

    // Aurora Runtime Theme

    readonly property string auroraDirectory: Quickshell.env("HOME") + "/.config/aurora"

    readonly property string activeThemePath: auroraDirectory + "/active-theme"

    // Active Theme

    property var activeThemeFile: FileView {
        path: theme.activeThemePath

        watchChanges: true
        blockLoading: true

        onFileChanged: {
            this.reload();
            theme.themeFile.reload();
        }
    }

    // Active Theme ID

    readonly property string activeTheme: activeThemeFile.loaded ? activeThemeFile.text().trim() : "aurora"

    // Active Theme JSON

    property var themeFile: FileView {
        path: theme.auroraDirectory + "/themes/" + theme.activeTheme + ".json"

        watchChanges: true
        blockLoading: true

        onFileChanged: {
            this.reload();
        }
    }

    // Parsed Theme

    readonly property var data: {
        if (!theme.themeFile.loaded)
            return ({});

        try {
            return JSON.parse(theme.themeFile.text());
        } catch (error) {
            console.warn("Aurora Theme: invalid JSON:", error);

            return ({});
        }
    }

    readonly property var fonts: data.fonts || ({})

    readonly property var colors: data.colors || ({})

    readonly property var ui: data.ui || ({})

    // Background

    readonly property color background: colors.background || "#181D25"

    readonly property color backgroundDark: colors.backgroundDark || "#141920"

    // Surfaces

    readonly property color surface: colors.surface || "#282E37"

    readonly property color surfaceHover: colors.surfaceHover || "#303743"

    readonly property color surfaceActive: colors.surfaceActive || "#363D49"

    // Borders

    readonly property color border: colors.border || "#3B4350"

    readonly property color borderFocus: colors.borderFocus || "#A970FF"
    readonly property color borderActive: colors.accent || "#A970FF"
    readonly property color borderActiveEnd: colors.accentActive || "#C7A6FF"

    readonly property color separator: colors.separator || "#343B47"

    // Text

    readonly property color text: colors.text || "#F2F3F7"

    readonly property color textSecondary: colors.textSecondary || "#B9BEC8"

    readonly property color textMuted: colors.textMuted || "#858D9A"

    // Accent

    readonly property color accent: colors.accent || "#A970FF"

    readonly property color accentHover: colors.accentHover || "#B98AFF"

    readonly property color accentActive: colors.accentActive || "#C7A6FF"

    readonly property color accentMuted: colors.accentMuted || "#55406F"

    readonly property color accentForeground: colors.accentForeground || "#181D25"

    // Semantic States

    readonly property color success: colors.success || "#8FE3A5"

    readonly property color warning: colors.warning || "#FFD479"

    readonly property color error: colors.error || "#FF7F96"

    readonly property color info: colors.info || "#8FB8FF"

    // Compatibility Aliases

    readonly property color foreground: text

    readonly property color foregroundMuted: textSecondary

    readonly property color foregroundFaint: textMuted

    readonly property color danger: error

    readonly property color accentSoft: accentMuted

    readonly property color accentDim: accentMuted

    readonly property color hover: surfaceHover

    readonly property color pressed: surfaceActive

    // Semantic Color Resolver

    function resolveColor(name, fallback) {
        switch (name) {
        case "foreground":
            return foreground;
        case "foregroundMuted":
            return foregroundMuted;
        case "foregroundFaint":
            return foregroundFaint;
        case "accent":
            return accent;
        case "accentHover":
            return accentHover;
        case "accentActive":
            return accentActive;
        case "success":
            return success;
        case "warning":
            return warning;
        case "danger":
            return danger;
        case "info":
            return info;
        default:
            return fallback;
        }
    }

    // Clock

    readonly property color clockHour: resolveColor(ui.clock?.hour, foreground)

    readonly property color clockSeparator: resolveColor(ui.clock?.separator, foregroundMuted)

    readonly property color clockMinute: resolveColor(ui.clock?.minute, accent)

    readonly property color clockSecond: resolveColor(ui.clock?.second, foregroundFaint)

    // Glass

    readonly property real glassOpacity: ui.glassOpacity || 0.80

    readonly property color backgroundGlass: Qt.rgba(background.r, background.g, background.b, glassOpacity)

    readonly property color backgroundSolid: background

    // UI

    readonly property int borderWidth: ui.borderWidth || 0

    readonly property int radius: ui.radius || 10

    readonly property int radiusSmall: ui.radiusSmall || 6

    readonly property int radiusLarge: ui.radiusLarge || 18

    readonly property int iconSize: ui.iconSize || 16

    readonly property int fontSize: ui.fontSize || 13

    readonly property int fontSizeSmall: ui.fontSizeSmall || 10

    readonly property int fontSizeLarge: ui.fontSizeLarge || 15

    readonly property real shadowOpacity: ui.shadowOpacity !== undefined ? ui.shadowOpacity : 0.20

    // Shell surfaces draw their own stacked shadow to read as floating.
    // Deliberately separate from ui.shadowOpacity, which decoration.lua also
    // reads for Hyprland window shadows, so the shell can float without
    // touching window decorations.
    readonly property real shellShadowOpacity: 0.30

    // How far the stacked shadow bleeds past a floating surface.
    readonly property int shellShadowSpread: 7

    // Existing QuickShell Geometry

    readonly property int pillHeight: 32

    readonly property int moduleHeight: 30

    readonly property int barMarginTop: 10

    // Was a hardcoded 18, identical to radiusLarge.
    readonly property int radiusMenu: radiusLarge

    // Was a hardcoded 12, an undeclared fourth radius step between radius (10) and radiusLarge (18).
    readonly property int radiusRow: radius + 2

    readonly property int padding: 10

    readonly property int spacing: 6

    // Typography

    readonly property string fontFamily: fonts.interface || "Inter"

    // themes.nix already defines a terminal font; only the interface
    // font was ever exposed here. The launcher surfaces use this for
    // their Omarchy-style monospace rows.
    readonly property string fontMono: fonts.terminal || "monospace"

    // Popup Geometry

    readonly property int popupWidth: 340

    readonly property int popupMaxHeight: 460

    // Visible detachment from the bar pill. At 2 the cards looked welded to it.
    readonly property int popupGap: 10

    readonly property int rowHeight: 42

    // Animation

    readonly property real springStiffness: 3.2

    readonly property real springDamping: 0.32

    readonly property real springEpsilon: 0.25

    readonly property real springMass: 1.1

    // Motion is intentionally short and deterministic.
    readonly property int durFast: 110

    readonly property int durBase: 180

    readonly property int durSlow: 260

    readonly property int durOpen: 220

    readonly property int durClose: 150

    readonly property real overshoot: 1.0

    // Collapsing Bar

    readonly property int barRevealDuration: 200

    readonly property int barHideDuration: 140

    readonly property int barCollapseDelay: 180
}
