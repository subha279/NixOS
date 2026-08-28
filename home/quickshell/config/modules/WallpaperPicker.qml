import QtQuick
import Quickshell
import Quickshell.Io
import "../components" as Components
import "../core" as Core
import "../services" as Services


Components.LauncherSurface {
    id: launcher

    launcherId: "wallpaper"
    promptIcon: Core.Icons.image
    placeholder: "Search wallpapers"

    cardWidth: 760

    columns: 3


    vimNavigation: true

    readonly property var results: Services.WallpaperService.search(launcher.query)

    itemCount: launcher.results.length

    counterText: Services.WallpaperService.scanning ? "scanning" : (launcher.query.length === 0 ? launcher.results.length + " wallpapers" : launcher.results.length + " of " + Services.WallpaperService.count)

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

            interactive: false

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

                z: cell.selected ? 3 : (cell.applied ? 1 : 0)

                Rectangle {
                    id: tile

                    anchors.fill: parent

                    anchors.margins: 8

                    radius: Core.Theme.radiusRow

                    color: Core.Theme.surfaceGlass
                    clip: true

                    scale: cell.selected ? 1.06 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutQuint
                        }
                    }

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

                        scale: cell.selected ? 1.16 : 1.0

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

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        height: 26
                        color: Core.Theme.surfaceGlass

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            spacing: 6

                            Text {
                                anchors.verticalCenter: parent.verticalCenter

                                visible: cell.applied

                                text: Core.Icons.checkCircle

                                font.family: Core.Theme.iconFont
                                font.pixelSize: Core.Theme.fontSizeSmall + 2

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

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        launcher.selectedIndex = cell.index;
                        launcher.accepted();
                    }
                }
            }
        }
    }
}
