import QtQuick
import Quickshell
import Quickshell.Io
import "../components" as Components
import "../core" as Core
import "../services" as Services

// ============================================================
// Colorscheme Picker
// ============================================================
//
// Replaces the `aurora-theme` Fuzzel dmenu.
//
// The whole reason this is worth moving off Fuzzel: each row is
// drawn in the palette of the theme it offers, so a low-contrast
// theme looks low-contrast before you commit to it. A text-only
// dmenu cannot do that.
//
// No palette glyph is invented here. Icons.qml has no verified
// palette codepoint, and hand-computing a surrogate pair is exactly
// the bug class that file exists to prevent, so this uses the
// brightness glyph plus live swatches instead.
//
// Opened from Hyprland with:
//
//   qs ipc call theme toggle
//
// ============================================================

Components.LauncherSurface {
    id: launcher

    launcherId: "theme"
    promptIcon: Core.Icons.brightness
    placeholder: "Search colorschemes"

    cardWidth: 460
    cardHeight: 460

    columns: 1

    readonly property var results: Services.ThemeService.search(launcher.query)

    itemCount: launcher.results.length

    counterText: launcher.query.length === 0 ? launcher.results.length + " themes" : launcher.results.length + " of " + Services.ThemeService.count

    onAccepted: {
        const theme = launcher.results[launcher.selectedIndex];
        if (!theme)
            return;

        launcher.dismiss();

        // Re-applying the active theme would relink five symlinks and
        // trigger a hyprctl reload for no visible change.
        if (theme.id === Services.ThemeService.activeId)
            return;

        Services.ThemeService.apply(theme.id);
    }

    IpcHandler {
        target: "theme"

        function toggle(): void {
            launcher.toggle();
        }

        function open(): void {
            launcher.show();
        }

        function close(): void {
            launcher.dismiss();
        }
    }

    contentComponent: Component {
        ListView {
            id: list

            model: launcher.results
            currentIndex: launcher.selectedIndex

            clip: true

            // Contiguous rows: no gap between selection bars.
            spacing: 0

            highlightRangeMode: ListView.ApplyRange
            preferredHighlightBegin: 56
            preferredHighlightEnd: height - 56

            Text {
                anchors.centerIn: parent
                visible: launcher.results.length === 0

                text: "No matching colorschemes"
                color: Core.Theme.foregroundFaint
                font.family: Core.Theme.fontMono
                font.pixelSize: Core.Theme.fontSize
            }

            delegate: Rectangle {
                id: row

                required property var modelData
                required property int index

                width: list.width
                height: 56

                // Omarchy selection: full-bleed accent bar, no pill.
                radius: 0

                readonly property bool selected: row.index === launcher.selectedIndex
                readonly property bool isActive: row.modelData.id === Services.ThemeService.activeId

                // A partially generated themes.json must not break
                // layout, so every read has a fallback.
                readonly property var palette: row.modelData.colors || ({})

                function shade(key, fallback) {
                    const value = row.palette[key];
                    return (value && String(value).length > 0) ? value : fallback;
                }

                color: row.selected ? Core.Theme.accent : (hover.hovered ? Core.Theme.surfaceHover : "transparent")

                Behavior on color {
                    ColorAnimation {
                        duration: Core.Theme.durFast
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Core.Theme.padding
                    anchors.right: parent.right
                    anchors.rightMargin: Core.Theme.padding
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: Core.Theme.padding

                    // --------------------------------------------
                    // Miniature of the theme, in its own colours
                    // --------------------------------------------

                    Rectangle {
                        id: chip

                        anchors.verticalCenter: parent.verticalCenter

                        width: 52
                        height: 34
                        radius: Core.Theme.radiusSmall

                        color: row.shade("background", Core.Theme.background)

                        border.width: Core.Theme.borderWidth
                        border.color: row.shade("border", Core.Theme.border)

                        // Fake bar
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 3

                            height: 8
                            radius: 2

                            color: row.shade("surface", Core.Theme.surface)

                            Rectangle {
                                anchors.left: parent.left
                                anchors.leftMargin: 2
                                anchors.verticalCenter: parent.verticalCenter

                                width: 12
                                height: 4
                                radius: 2

                                color: row.shade("accent", Core.Theme.accent)
                            }
                        }

                        // Text weight samples
                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 5

                            spacing: 3

                            Rectangle {
                                width: 26
                                height: 3
                                radius: 1.5
                                color: row.shade("text", Core.Theme.foreground)
                            }

                            Rectangle {
                                width: 18
                                height: 3
                                radius: 1.5
                                color: row.shade("textMuted", Core.Theme.foregroundFaint)
                            }
                        }
                    }

                    // --------------------------------------------
                    // Name
                    // --------------------------------------------

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: row.modelData.name
                            color: row.selected ? Core.Theme.accentForeground : Core.Theme.foreground
                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSize
                        }

                        Text {
                            text: row.isActive ? "active" : row.modelData.id

                            // The "active" marker used to be drawn in
                            // the accent colour. On a selected row that
                            // is now accent-on-accent, i.e. invisible,
                            // so selected rows switch to the accent
                            // foreground and keep the marker bolder
                            // than a plain id.
                            color: row.selected ? Qt.alpha(Core.Theme.accentForeground, row.isActive ? 1.0 : 0.75) : (row.isActive ? Core.Theme.accent : Core.Theme.foregroundFaint)
                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSizeSmall
                        }
                    }
                }

                // ------------------------------------------------
                // ANSI swatches
                // ------------------------------------------------

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: Core.Theme.padding
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 4

                    Repeater {
                        model: ["terminalRed", "terminalYellow", "terminalGreen", "terminalCyan", "terminalBlue", "terminalMagenta"]

                        delegate: Rectangle {
                            required property var modelData

                            width: 9
                            height: 9
                            radius: 4.5

                            color: row.shade(modelData, Core.Theme.surfaceHover)
                        }
                    }
                }

                HoverHandler {
                    id: hover

                    onHoveredChanged: {
                        if (hovered)
                            launcher.selectedIndex = row.index;
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        launcher.selectedIndex = row.index;
                        launcher.accepted();
                    }
                }
            }
        }
    }
}
