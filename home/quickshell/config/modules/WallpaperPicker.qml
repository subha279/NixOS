import QtQuick
import Quickshell
import Quickshell.Io
import "../components" as Components
import "../core" as Core
import "../services" as Services

// Wallpaper Picker

Components.LauncherSurface {
    id: launcher

    launcherId: "wallpaper"
    promptIcon: Core.Icons.image
    placeholder: "Search wallpapers"

    cardWidth: 760
    cardHeight: 540

    columns: 3

    // The wheel and h/j/k/l move the selection only -- nothing is applied
    // until Enter, so travelling through the grid is free.
    vimNavigation: true

    readonly property var results: Services.WallpaperService.search(launcher.query)

    itemCount: launcher.results.length

    counterText: Services.WallpaperService.scanning ? "scanning" : (launcher.query.length === 0 ? launcher.results.length + " wallpapers" : launcher.results.length + " of " + Services.WallpaperService.count)

    // Wallpapers are dropped into ~/Wallpapers by hand, so rescan on every open rather than trusting a cached list.
    onDidOpen: Services.WallpaperService.refresh()

    onAccepted: {
        const item = launcher.results[launcher.selectedIndex];
        if (!item)
            return;

        launcher.dismiss();
        Services.WallpaperService.apply(item.path);
    }

    IpcHandler {
        target: "wallpaper"

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
        GridView {
            id: grid

            model: launcher.results
            currentIndex: launcher.selectedIndex

            clip: true
            boundsBehavior: Flickable.StopAtBounds

            // The wheel moves the SELECTION, one wallpaper per notch, instead
            // of flicking the view: the highlight is what you steer, and the
            // view follows it rather than drifting independently of it.
            interactive: false

            WheelHandler {
                onWheel: function (event) {
                    launcher.wheelSelect(event.angleDelta.y);
                }
            }

            cellWidth: Math.floor(width / launcher.columns)
            cellHeight: Math.round(cellWidth * 0.70)

            onCurrentIndexChanged: grid.positionViewAtIndex(grid.currentIndex, GridView.Contain)

            Text {
                anchors.centerIn: parent
                visible: launcher.results.length === 0 && !Services.WallpaperService.scanning

                text: Services.WallpaperService.error.length > 0 ? Services.WallpaperService.error : "No wallpapers in ~/Wallpapers"

                color: Core.Theme.foregroundFaint
                font.family: Core.Theme.fontMono
                font.pixelSize: Core.Theme.fontSize
            }

            delegate: Item {
                id: cell

                required property var modelData
                required property int index

                width: grid.cellWidth
                height: grid.cellHeight

                readonly property bool selected: cell.index === launcher.selectedIndex
                readonly property bool applied: Services.WallpaperService.current === cell.modelData.path

                // The selected tile grows past its own cell, so it has to paint
                // over its neighbours.
                z: cell.selected ? 3 : (cell.applied ? 1 : 0)

                Rectangle {
                    id: tile

                    anchors.fill: parent

                    // Headroom for the zoom. The selected tile grows past its
                    // own cell and the grid clips, so without a wider gutter
                    // the outer columns would get shaved flat as they scale.
                    anchors.margins: 8

                    // Was square, to match the flat Omarchy chrome. Rounded now
                    // that the tiles are meant to read as widgets.
                    radius: Core.Theme.radiusSmall

                    color: Core.Theme.surface
                    clip: true

                    // Zoom on selection -- the caelestia move. The frame itself
                    // only goes to 1.10, because it grows against the grid's
                    // clip edge; most of the zoom now lives in the image below,
                    // which the tile clips anyway and so costs nothing.
                    scale: cell.selected ? 1.10 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutQuint
                        }
                    }

                    // Everything else sits back rather than merely losing its
                    // border. Half the sense of depth comes from this, not from
                    // the scale.
                    opacity: cell.selected ? 1.0 : 0.72

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Core.Theme.durBase
                            easing.type: Easing.OutQuint
                        }
                    }

                    border.width: cell.selected ? Core.Theme.borderWidth * 2 : Core.Theme.borderWidth
                    border.color: cell.selected ? Core.Theme.accent : (cell.applied ? Core.Theme.accentMuted : Core.Theme.border)

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Core.Theme.durFast
                            easing.type: Easing.OutQuint
                        }
                    }

                    Image {
                        id: preview

                        anchors.fill: parent

                        asynchronous: true
                        cache: true
                        sourceSize.width: 480

                        fillMode: Image.PreserveAspectCrop
                        source: "file://" + cell.modelData.path

                        // A second, slower zoom inside the frame, and the one
                        // doing most of the work now: the picture pushes well
                        // past the edges of its own tile, so the crop opens up
                        // as you land on it. Two speeds is what separates this
                        // from a tile that simply got bigger.
                        scale: cell.selected ? 1.22 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 420
                                easing.type: Easing.OutQuint
                            }
                        }

                        opacity: status === Image.Ready ? 1.0 : 0.0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Core.Theme.durBase
                                easing.type: Easing.OutQuint
                            }
                        }
                    }

                    // Filename plate
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        height: 26
                        color: Qt.alpha(Core.Theme.backgroundDark, 0.78)

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            spacing: 6

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter

                                width: 6
                                height: 6
                                radius: 3

                                visible: cell.applied
                                color: Core.Theme.accent
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter

                                width: parent.width - (cell.applied ? 18 : 0)

                                text: cell.modelData.label
                                color: Core.Theme.foreground
                                font.family: Core.Theme.fontMono
                                font.pixelSize: Core.Theme.fontSizeSmall
                                elide: Text.ElideMiddle
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: 3

                    hoverEnabled: true

                    // Ignored for a moment after each wheel notch, so a view
                    // scrolling under a still pointer cannot steal the
                    // selection back. See wheelActive in LauncherSurface.
                    onEntered: {
                        if (!launcher.wheelActive)
                            launcher.selectedIndex = cell.index;
                    }
                    onClicked: {
                        launcher.selectedIndex = cell.index;
                        launcher.accepted();
                    }
                }
            }
        }
    }
}
