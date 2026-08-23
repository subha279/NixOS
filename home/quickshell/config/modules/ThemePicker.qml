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

            spacing: 4
            interactive: false

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

                // Inset from the list, which is the whole reason the zoom is
                // safe: a full-bleed row has nowhere to grow into, so scaling it
                // up ran it off both edges and the clip shaved it flat. 12px of
                // gutter against the 6.5px the row gains at 1.03.
                //
                // The inset has to come from a transform, not from x. A vertical
                // ListView positions its delegates itself and assigns x = 0 on
                // every layout pass, which overwrites an x binding here and
                // leaves the row narrow but still hugging the left edge, with
                // its scaled edge and its accent bar clipped away. A Translate
                // is applied on top of the view's positioning, so it survives.
                width: list.width - 24

                transform: Translate {
                    x: 12
                }

                height: 56

                // Always rounded now, like the rows in the battery popup.
                radius: Core.Theme.radiusRow

                readonly property bool selected: row.index === launcher.selectedIndex
                readonly property bool isActive: row.modelData.id === Services.ThemeService.activeId

                // The selected row grows past its slot, so it paints over its
                // neighbours.
                z: row.selected ? 2 : 0

                // Zoom on selection, kept small on purpose: the row is nearly
                // card-wide, so a few percent is already a lot of travel. The
                // miniature below carries the rest of it.
                scale: row.selected ? 1.03 : 1.0

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

                // Battery-popup selection: a quiet raised surface rather than a
                // solid accent fill. The accent moves to the bar on the left
                // and into the text, so the row no longer has to invert
                // everything sitting on it.
                color: row.selected ? Core.Theme.surfaceActive : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Core.Theme.durFast
                        easing.type: Easing.OutQuint
                    }
                }

                // Selection marker, borrowed from ListRow: a short accent bar
                // on the left edge that grows out of nothing.
                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    anchors.verticalCenter: parent.verticalCenter

                    width: 3
                    height: row.selected ? parent.height * 0.5 : 0

                    radius: 2

                    color: Core.Theme.accent

                    Behavior on height {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuint
                        }
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
                        scale: row.selected ? 1.18 : 1.0

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

                            // Not inverted any more: the row keeps its own
                            // surface, so the label keeps its own colour and
                            // just gains weight when selected.
                            color: Core.Theme.foreground
                            font.weight: row.selected ? Font.DemiBold : Font.Medium

                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSize
                        }

                        Text {
                            text: row.isActive ? "active" : row.modelData.id

                            // Accent for the theme actually applied, muted for
                            // one merely selected -- the same split the battery
                            // popup uses on its rows.
                            color: row.isActive ? Core.Theme.accent : (row.selected ? Core.Theme.foregroundMuted : Core.Theme.foregroundFaint)
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

                    // Applied-theme tick, the same idiom the battery popup uses
                    // to mark the live power profile.
                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        rightPadding: 4

                        visible: row.isActive

                        text: Core.Icons.checkCircle

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: Core.Theme.iconSize

                        color: Core.Theme.accent
                    }

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

                // Wheel and click only. Hover no longer moves the selection:
                // with the wheel driving the highlight, a pointer resting over
                // the list was just fighting it for control.
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        launcher.selectedIndex = row.index;
                    }

                    onClicked: {
                        launcher.selectedIndex = row.index;
                        launcher.accepted();
                    }
                }
            }
        }
    }
}
