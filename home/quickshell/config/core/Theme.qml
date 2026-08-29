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
        blockLoading: false

        onFileChanged: {
            this.reload();
            theme.themeFile.reload();
        }
    }

    // Active Theme ID

    readonly property string activeTheme: activeThemeFile.loaded ? activeThemeFile.text().trim() : "catppuccin-mocha"

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

    readonly property color red: colors.terminalRed || "#FF7F96"

    readonly property color green: colors.terminalGreen || "#8FE3A5"

    readonly property color yellow: colors.terminalYellow || "#FFD479"

    readonly property color blue: colors.terminalBlue || "#8FB8FF"

    readonly property color magenta: colors.terminalMagenta || "#F5C2E7"

    readonly property color cyan: colors.terminalCyan || "#94E2D5"

    readonly property color hueNetwork: info

    readonly property color hueBluetooth: accentActive

    readonly property color hueAudio: accent

    readonly property color hueBattery: success

    readonly property color hueBrightness: warning

    readonly property color hueCalendar: magenta

    readonly property color hueNotify: warning

    readonly property color hueClipboard: info

    readonly property color hueTheme: magenta

    readonly property color hueApps: accent

    readonly property color hueWallpaper: green

    readonly property color hueEmoji: accentHover

    function tinted(base, amount) {
        return Qt.rgba(base.r, base.g, base.b, amount);
    }

    readonly property real chipAlpha: 0.15

    readonly property real chipAlphaHover: 0.24

    readonly property real chipAlphaActive: 0.30

    readonly property color scrim: Qt.rgba(0, 0, 0, 0.30)

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

    // Liquid Glass

    readonly property real glassOpacity: ui.glassOpacity !== undefined ? ui.glassOpacity : 0.45

    readonly property real surfaceOpacity: ui.surfaceOpacity !== undefined ? ui.surfaceOpacity : 0.38

    readonly property real glassLuminosity: ui.glassLuminosity !== undefined ? ui.glassLuminosity : 0.0

    readonly property real glassGradientOpacity: ui.glassGradientOpacity !== undefined ? ui.glassGradientOpacity : 0.055

    readonly property color glassBody: {
        if (glassOnLight) {
            return Qt.rgba(background.r * (1.0 - glassLuminosity), background.g * (1.0 - glassLuminosity), background.b * (1.0 - glassLuminosity), 1.0);
        }

        return Qt.rgba(background.r + (1.0 - background.r) * glassLuminosity, background.g + (1.0 - background.g) * glassLuminosity, background.b + (1.0 - background.b) * glassLuminosity, 1.0);
    }

    readonly property color surfaceGlass: Qt.alpha(surface, surfaceOpacity)
    readonly property color surfaceGlassHover: Qt.alpha(surfaceHover, 0.55)

    readonly property color surfaceRaised: Qt.alpha(surfaceHover, Math.min(1.0, surfaceOpacity + 0.14))

    readonly property color surfaceSunken: Qt.alpha(backgroundDark, 0.42)

    readonly property color glassTintTop: {
        const mixed = Qt.tint(glassBody, Qt.rgba(accent.r, accent.g, accent.b, 0.10));

        return Qt.rgba(mixed.r, mixed.g, mixed.b, glassOpacity);
    }

    readonly property color glassTintBottom: {
        const mixed = Qt.tint(glassBody, Qt.rgba(backgroundDark.r, backgroundDark.g, backgroundDark.b, 0.60));

        return Qt.rgba(mixed.r, mixed.g, mixed.b, glassOpacity);
    }

    readonly property color glassTintMid: {
        const top = Qt.tint(glassBody, Qt.rgba(accent.r, accent.g, accent.b, 0.10));

        const bottom = Qt.tint(glassBody, Qt.rgba(backgroundDark.r, backgroundDark.g, backgroundDark.b, 0.60));

        return Qt.rgba((top.r + bottom.r) / 2, (top.g + bottom.g) / 2, (top.b + bottom.b) / 2, glassOpacity);
    }

    readonly property color glassWash: Qt.rgba(accent.r, accent.g, accent.b, glassGradientOpacity)

    readonly property color glassWashEnd: Qt.rgba(accent.r, accent.g, accent.b, 0.0)

    readonly property bool glassOnLight: background.hslLightness > 0.5

    readonly property color backgroundGlass: Qt.rgba(background.r, background.g, background.b, glassOpacity)

    readonly property color backgroundSolid: background

    // UI
    //
    // Same `!== undefined` idiom as the glass knobs above: `0 || 10` is 10, so
    // `||` would make radius = 0 (square corners) or borderWidth = 0 impossible.

    readonly property int borderWidth: ui.borderWidth !== undefined ? ui.borderWidth : 0

    readonly property int radius: ui.radius !== undefined ? ui.radius : 10

    readonly property int radiusSmall: ui.radiusSmall !== undefined ? ui.radiusSmall : 6

    readonly property int radiusLarge: ui.radiusLarge !== undefined ? ui.radiusLarge : 22

    readonly property int iconSize: Math.max(8, ui.iconSize !== undefined ? ui.iconSize : 16)

    // Glyph sizes were spread across ten different expressions from 10px to 26px,
    // several taken from FONT tokens, which is why some icons looked large and
    // others small. Four steps, derived from iconSize so they move together.
    readonly property int iconSizeSmall: Math.round(iconSize * 0.875)

    readonly property int iconSizeMedium: Math.round(iconSize * 1.25)

    readonly property int iconSizeLarge: Math.round(iconSize * 1.6)

    readonly property int fontSize: Math.max(8, ui.fontSize !== undefined ? ui.fontSize : 13)
    readonly property int fontSizeSmall: Math.max(8, ui.fontSizeSmall !== undefined ? ui.fontSizeSmall : 10)
    readonly property int fontSizeLarge: Math.max(8, ui.fontSizeLarge !== undefined ? ui.fontSizeLarge : 15)

    readonly property real shadowOpacity: ui.shadowOpacity !== undefined ? ui.shadowOpacity : 0.20

    readonly property real shellShadowOpacity: 0.0

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

    readonly property int space1: 4

    readonly property int space2: 8

    readonly property int space3: 12

    readonly property int space4: 16

    readonly property int space5: 20

    readonly property int space6: 28

    readonly property int padCard: 14

    readonly property int padRow: 12

    readonly property int gapTight: 2

    readonly property int gapRow: 4

    readonly property int gapSection: 12

    readonly property int rowHeightCompact: 36

    readonly property int chipSize: 30

    readonly property int chipRadius: 10

    // Typography

    readonly property string fontFamily: fonts.interface || "Inter"
    readonly property string fontMono: fonts.terminal || "JetBrainsMono Nerd Font Mono"

    readonly property string iconFont: fonts.terminal || "JetBrainsMono Nerd Font Mono"

    readonly property string emojiFont: fonts.emoji || "Noto Color Emoji"

    readonly property int fontSizeTiny: Math.max(8, fontSizeSmall - 1)

    readonly property int fontSizeHeading: fontSizeLarge + 1

    readonly property real trackingWide: 0.8

    readonly property real trackingTight: -0.2

    // Popup Geometry

    readonly property int popupWidth: 340

    readonly property int popupMaxHeight: 620

    // Visible detachment from the bar pill. At 2 the cards looked welded to it.
    readonly property int popupGap: 10

    // Tallest a launcher popup may grow. Bar sizes its PanelWindow from this,
    // and LauncherView clamps itself to it, so the window is always big enough
    // to contain the popup it has to host.
    readonly property int launcherMaxHeight: 620

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


    // Collapsing Bar

    readonly property int barRevealDuration: 200

    readonly property int barHideDuration: 140

    readonly property int barCollapseDelay: 180
}
