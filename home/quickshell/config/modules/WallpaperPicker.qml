import QtQuick
import Quickshell
import Quickshell.Io
import "../components" as Components
import "../core" as Core
import "../services" as Services

// ============================================================
// Wallpaper Picker
// ============================================================
//
// Replaces wallpaper.sh, which shelled out to ImageMagick to build
// a thumbnail cache so Fuzzel could show icons. Here the images are
// loaded and scaled asynchronously by QML, so there is no cache to
// build, invalidate or clean up.
//
// Opened from Hyprland with:
//
//   qs ipc call wallpaper toggle
//
// ============================================================

Components.LauncherSurface {
    id: launcher

    launcherId: "wallpaper"
    promptIcon: Core.Icons.image
    placeholder: "Search wallpapers"

    cardWidth: 760
    cardHeight: 540

    columns: 3

    readonly property var results: Services.WallpaperService.search(launcher.query)

    itemCount: launcher.results.length

    counterText: Services.WallpaperService.scanning ? "scanning" : (launcher.query.length === 0 ? launcher.results.length + " wallpapers" : launcher.results.length + " of " + Services.WallpaperService.count)

    // Wallpapers are dropped into ~/Wallpapers by hand, so rescan on
    // every open rather than trusting a cached list.
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

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2

                    // Square tiles, to match the flat Omarchy chrome.
                    // This also removes the need for the corner-faking
                    // overlay that used to sit on top of the image.
                    radius: 0

                    color: Core.Theme.surface
                    clip: true

                    // Selection is now shown by border weight rather
                    // than by scaling the tile: no bounce, no reflow.
                    border.width: cell.selected ? Core.Theme.borderWidth * 2 : Core.Theme.borderWidth
                    border.color: cell.selected ? Core.Theme.accent : (cell.applied ? Core.Theme.accentMuted : Core.Theme.border)

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Core.Theme.durFast
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

                        opacity: status === Image.Ready ? 1.0 : 0.0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Core.Theme.durBase
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

                    onEntered: launcher.selectedIndex = cell.index
                    onClicked: {
                        launcher.selectedIndex = cell.index;
                        launcher.accepted();
                    }
                }
            }
        }
    }
}
