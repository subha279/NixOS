import QtQuick
import Quickshell
import Quickshell.Io
import "../components" as Components
import "../core" as Core
import "../services" as Services


Components.LauncherSurface {
    id: launcher

    launcherId: "theme"
    promptIcon: Core.Icons.brightness
    placeholder: "Search colorschemes"

    cardWidth: 460

    columns: 1

    rowHeight: 60

    vimNavigation: true

    readonly property var results: Services.ThemeService.search(launcher.query)

    itemCount: launcher.results.length

    counterText: launcher.query.length === 0 ? launcher.results.length + " themes" : launcher.results.length + " of " + Services.ThemeService.count

    onAccepted: {
        const theme = launcher.results[launcher.selectedIndex];
        if (!theme)
            return;

        launcher.dismiss();

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

                width: list.width - 24

                transform: Translate {
                    x: 12
                }

                height: 56

                radius: Core.Theme.radiusRow

                readonly property bool selected: row.index === launcher.selectedIndex
                readonly property bool isActive: row.modelData.id === Services.ThemeService.activeId

                z: row.selected ? 2 : 0

                scale: row.selected ? 1.03 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: 240
                        easing.type: Easing.OutQuint
                    }
                }

                readonly property var palette: row.modelData.colors || ({})

                function shade(key, fallback) {
                    const value = row.palette[key];
                    return (value && String(value).length > 0) ? value : fallback;
                }

                color: row.selected ? Core.Theme.surfaceGlass : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Core.Theme.durFast
                        easing.type: Easing.OutQuint
                    }
                }

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


                    Rectangle {
                        id: chip

                        anchors.verticalCenter: parent.verticalCenter

                        width: 52
                        height: 34
                        radius: Core.Theme.radiusSmall

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


                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: row.modelData.name

                            color: Core.Theme.foreground
                            font.weight: row.selected ? Font.DemiBold : Font.Medium

                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSize
                        }

                        Text {
                            text: row.isActive ? "active" : row.modelData.id

                            color: row.isActive ? Core.Theme.accent : (row.selected ? Core.Theme.foregroundMuted : Core.Theme.foregroundFaint)
                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSizeSmall
                        }
                    }
                }


                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: Core.Theme.padding
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 4

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        rightPadding: 4

                        visible: row.isActive

                        text: Core.Icons.checkCircle

                        font.family: Core.Theme.iconFont
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

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        launcher.selectedIndex = row.index;
                        launcher.accepted();
                    }
                }
            }
        }
    }
}
