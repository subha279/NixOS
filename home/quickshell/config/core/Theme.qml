pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: theme


    readonly property string auroraDirectory: Quickshell.env("HOME") + "/.config/aurora"

    readonly property string activeThemePath: auroraDirectory + "/active-theme"


    property var activeThemeFile: FileView {
        path: theme.activeThemePath

        watchChanges: true
        blockLoading: false

        onFileChanged: {
            this.reload();
            theme.themeFile.reload();
        }
    }


    readonly property string activeTheme: activeThemeFile.loaded ? activeThemeFile.text().trim() : "catppuccin-mocha"


    property var themeFile: FileView {
        path: theme.auroraDirectory + "/themes/" + theme.activeTheme + ".json"

        watchChanges: true
        blockLoading: true

        onFileChanged: {
            this.reload();
        }
    }


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


    readonly property color background: colors.background || "#181D25"

    readonly property color backgroundDark: colors.backgroundDark || "#141920"


    readonly property color surface: colors.surface || "#282E37"

    readonly property color surfaceHover: colors.surfaceHover || "#303743"

    readonly property color surfaceActive: colors.surfaceActive || "#363D49"


    readonly property color border: colors.border || "#3B4350"

    readonly property color borderFocus: colors.borderFocus || "#A970FF"
    readonly property color borderActive: colors.accent || "#A970FF"
    readonly property color borderActiveEnd: colors.accentActive || "#C7A6FF"

    readonly property color separator: colors.separator || "#343B47"


    readonly property color text: colors.text || "#F2F3F7"

    readonly property color textSecondary: colors.textSecondary || "#B9BEC8"

    readonly property color textMuted: colors.textMuted || "#858D9A"


    readonly property color accent: colors.accent || "#A970FF"

    readonly property color accentHover: colors.accentHover || "#B98AFF"

    readonly property color accentActive: colors.accentActive || "#C7A6FF"

    readonly property color accentMuted: colors.accentMuted || "#55406F"

    readonly property color accentForeground: colors.accentForeground || "#181D25"


    readonly property color success: colors.success || "#8FE3A5"

    readonly property color warning: colors.warning || "#FFD479"

    readonly property color error: colors.error || "#FF7F96"

    readonly property color info: colors.info || "#8FB8FF"


    readonly property color foreground: text

    readonly property color foregroundMuted: textSecondary

    readonly property color foregroundFaint: textMuted

    readonly property color danger: error

    readonly property color accentSoft: accentMuted

    readonly property color accentDim: accentMuted

    readonly property color hover: surfaceHover

    readonly property color pressed: surfaceActive


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


    readonly property color clockHour: resolveColor(ui.clock?.hour, foreground)

    readonly property color clockSeparator: resolveColor(ui.clock?.separator, foregroundMuted)

    readonly property color clockMinute: resolveColor(ui.clock?.minute, accent)

    readonly property color clockSecond: resolveColor(ui.clock?.second, foregroundFaint)


    readonly property real glassOpacity: ui.glassOpacity !== undefined ? ui.glassOpacity : 0.51

    readonly property real surfaceOpacity: ui.surfaceOpacity !== undefined ? ui.surfaceOpacity : 0.38

    readonly property real glassLuminosity: ui.glassLuminosity !== undefined ? ui.glassLuminosity : 0.20

    readonly property real glassGradientOpacity: ui.glassGradientOpacity !== undefined ? ui.glassGradientOpacity : 0.055

    readonly property real glassGrainOpacity: ui.glassGrainOpacity !== undefined ? ui.glassGrainOpacity : 0.010

    readonly property real glassRimOpacity: ui.glassRimOpacity !== undefined ? ui.glassRimOpacity : 0.10


    readonly property real glassSpecularOpacity: ui.glassSpecularOpacity !== undefined ? ui.glassSpecularOpacity : 0.14

    readonly property real glassLensOpacity: ui.glassLensOpacity !== undefined ? ui.glassLensOpacity : 0.10

    readonly property real glassDepthOpacity: ui.glassDepthOpacity !== undefined ? ui.glassDepthOpacity : 0.07

    readonly property real glassClarity: ui.glassClarity !== undefined ? ui.glassClarity : 0.06

    readonly property color glassBody: {
        if (glassOnLight) {
            return Qt.rgba(background.r * (1.0 - glassLuminosity), background.g * (1.0 - glassLuminosity), background.b * (1.0 - glassLuminosity), 1.0);
        }

        return Qt.rgba(background.r + (1.0 - background.r) * glassLuminosity, background.g + (1.0 - background.g) * glassLuminosity, background.b + (1.0 - background.b) * glassLuminosity, 1.0);
    }

    readonly property color surfaceGlass: Qt.alpha(surface, surfaceOpacity)
    readonly property color surfaceGlassHover: Qt.alpha(surfaceHover, 0.55)

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

        return Qt.rgba((top.r + bottom.r) / 2, (top.g + bottom.g) / 2, (top.b + bottom.b) / 2, glassOpacity * (1.0 - glassClarity));
    }


    readonly property color glassWash: Qt.rgba(accent.r, accent.g, accent.b, glassGradientOpacity)

    readonly property color glassWashEnd: Qt.rgba(accent.r, accent.g, accent.b, 0.0)


    readonly property bool glassOnLight: background.hslLightness > 0.5


    readonly property color glassRim: glassOnLight ? Qt.rgba(0, 0, 0, glassRimOpacity) : Qt.rgba(1, 1, 1, glassRimOpacity)


    readonly property color glassSpecular: Qt.rgba(1, 1, 1, glassSpecularOpacity * (glassOnLight ? 0.45 : 1.0))

    readonly property color glassSpecularEnd: Qt.rgba(1, 1, 1, 0.0)


    readonly property color glassLensShade: Qt.rgba(0, 0, 0, glassLensOpacity * (glassOnLight ? 1.60 : 1.0))

    readonly property color glassLensShadeEnd: Qt.rgba(0, 0, 0, 0.0)


    readonly property color glassDepth: Qt.rgba(0, 0, 0, glassDepthOpacity * (glassOnLight ? 1.30 : 1.0))


    readonly property url glassGrainSource: Qt.resolvedUrl("../assets/grain.png")

    readonly property color backgroundGlass: Qt.rgba(background.r, background.g, background.b, glassOpacity)

    readonly property color backgroundSolid: background


    readonly property int borderWidth: ui.borderWidth !== undefined ? ui.borderWidth : 0

    // `!== undefined` and not `||` throughout: 0 is a valid radius and width.
    readonly property int radius: ui.radius !== undefined ? ui.radius : 10

    readonly property int radiusSmall: ui.radiusSmall !== undefined ? ui.radiusSmall : 6

    readonly property int radiusLarge: ui.radiusLarge !== undefined ? ui.radiusLarge : 18

    readonly property int iconSize: Math.max(8, ui.iconSize !== undefined ? ui.iconSize : 16)
    readonly property int fontSize: Math.max(8, ui.fontSize !== undefined ? ui.fontSize : 13)
    readonly property int fontSizeSmall: Math.max(8, ui.fontSizeSmall !== undefined ? ui.fontSizeSmall : 10)
    readonly property int fontSizeLarge: Math.max(8, ui.fontSizeLarge !== undefined ? ui.fontSizeLarge : 15)

    readonly property int fontSizeDisplay: Math.round(fontSize * 2.8)

    readonly property int fontSizeTitle: Math.round(fontSize * 2.0)

    readonly property int iconSizeMedium: Math.round(iconSize * 1.25)

    readonly property int iconSizeLarge: Math.round(iconSize * 1.6)

    readonly property int iconSizeSmall: Math.round(iconSize * 0.875)

    readonly property real shadowOpacity: ui.shadowOpacity !== undefined ? ui.shadowOpacity : 0.20

    readonly property real shellShadowOpacity: 0.0

    readonly property int shellShadowSpread: 7


    readonly property int pillHeight: 32

    readonly property int moduleHeight: 30

    readonly property int barMarginTop: 10

    readonly property int radiusMenu: radiusLarge

    readonly property int radiusRow: radius + 2

    readonly property int padding: 10

    readonly property int spacing: 6


    readonly property string fontFamily: fonts.interface || "Inter"
    readonly property string fontMono: fonts.terminal || "JetBrainsMono Nerd Font Mono"

    readonly property string iconFont: fonts.terminal || "JetBrainsMono Nerd Font Mono"

    readonly property string emojiFont: fonts.emoji || "Noto Color Emoji"

    readonly property var textFamilies: [fontFamily, iconFont]


    readonly property int popupWidth: 340

    readonly property int popupMaxHeight: 460

    readonly property int popupGap: 10

    readonly property int rowHeight: 42


    readonly property int durInstant: 110

    readonly property int durShort: 180

    readonly property int durMedium: 260

    readonly property int durLong: 340

    readonly property int durExitShort: 130

    readonly property int durExitMedium: 180


    readonly property var easeStandard: [0.2, 0.0, 0.0, 1.0, 1, 1]

    readonly property var easeDecelerate: [0.05, 0.7, 0.1, 1.0, 1, 1]

    readonly property var easeAccelerate: [0.3, 0.0, 0.8, 0.15, 1, 1]

    readonly property real popScale: 1.16

    readonly property int durFast: durInstant

    readonly property int durBase: durShort

    readonly property int durSlow: durMedium

    readonly property int durOpen: durMedium

    readonly property int durClose: durExitMedium


    readonly property int barRevealDuration: 200

    readonly property int barHideDuration: 140

    readonly property int barCollapseDelay: 180
}
