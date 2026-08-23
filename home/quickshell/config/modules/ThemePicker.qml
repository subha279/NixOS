import QtQuick
import Quickshell
import Quickshell.Io
import "../components" as Components
import "../core" as Core
import "../services" as Services

// Colorscheme Picker

Components.LauncherSurface {
    id: launcher

    launcherId: "theme"
    promptIcon: Core.Icons.brightness
    placeholder: "Search colorschemes"

    cardWidth: 460
    cardHeight: 460

    columns: 1

    // Selection only, same as the wallpaper picker: the wheel and h/j/k/l move
    // the highlight, and Enter applies. Applying a colourscheme relinks symlinks
    // and reloads Hyprland, so it is not something to fire off per row anyway.
    vimNavigation: true

    readonly property var results: Services.ThemeService.search(launcher.query)

    itemCount: launcher.results.length

    counterText: launcher.query.length === 0 ? launcher.results.length + " themes" : launcher.results.length + " of " + Services.ThemeService.count

    onAccepted: {
        const theme = launcher.results[launcher.selectedIndex];
        if (!theme)
            return;

        launcher.dismiss();

        // Re-applying the active theme would relink five symlinks and trigger a hyprctl reload for no visible change.
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
            boundsBehavior: Flickable.StopAtBounds
            // Contiguous rows: no gap between selection bars.
            spacing: 0

            // One theme per wheel notch. highlightRangeMode below already keeps
            // the current row inside the view, so the view follows the
            // selection instead of flicking on its own.
            interactive: false

            WheelHandler {
                onWheel: function (event) {
                    launcher.wheelSelect(event.angleDelta.y);
                }
            }

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

                // Was a full-bleed square bar. The selected row is now a
                // rounded slab that lifts out of the list; unselected rows stay
                // square, so the list still reads as a list.
                radius: row.selected ? Core.Theme.radiusSmall : 0

                Behavior on radius {
                    NumberAnimation {
                        duration: Core.Theme.durFast
                        easing.type: Easing.OutQuint
                    }
                }

                readonly property bool selected: row.index === launcher.selectedIndex
                readonly property bool isActive: row.modelData.id === Services.ThemeService.activeId

                // The selected row grows past its slot, so it paints over its
                // neighbours.
                z: row.selected ? 2 : 0

                // Zoom on selection. A row is full width and grows against the
                // list's clip edge, so it stays modest -- the miniature below
                // carries the zoom instead.
                scale: row.selected ? 1.04 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: 240
                        easing.type: Easing.OutQuint
                    }
                }

                // A partially generated themes.json must not break layout, so every read has a fallback.
                readonly property var palette: row.modelData.colors || ({})

                function shade(key, fallback) {
                    const value = row.palette[key];
                    return (value && String(value).length > 0) ? value : fallback;
                }

                color: row.selected ? Core.Theme.accent : (hover.hovered ? Core.Theme.surfaceHover : "transparent")

                Behavior on color {
                    ColorAnimation {
                        duration: Core.Theme.durFast
                        easing.type: Easing.OutQuint
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Core.Theme.padding
                    anchors.right: parent.right
                    anchors.rightMargin: Core.Theme.padding
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: Core.Theme.padding

                    // Miniature of the theme, in its own colours

                    Rectangle {
                        id: chip

                        anchors.verticalCenter: parent.verticalCenter

                        width: 52
                        height: 34
                        radius: Core.Theme.radiusSmall

                        // The zoom you actually see in a list: the miniature
                        // pushes forward while the row itself only lifts. It is
                        // also the one part of the row that is a picture, which
                        // is what makes scaling it read as focus.
                        scale: row.selected ? 1.28 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 260
                                easing.type: Easing.OutQuint
                            }
                        }

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

                    // Name

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

                            // The "active" marker used to be drawn in the accent colour.
                            color: row.selected ? Qt.alpha(Core.Theme.accentForeground, row.isActive ? 1.0 : 0.75) : (row.isActive ? Core.Theme.accent : Core.Theme.foregroundFaint)
                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSizeSmall
                        }
                    }
                }

                // ANSI swatches

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
                        // Ignored for a moment after each wheel notch, so a
                        // list scrolling under a still pointer cannot steal the
                        // selection back. See wheelActive in LauncherSurface.
                        if (hovered && !launcher.wheelActive)
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
