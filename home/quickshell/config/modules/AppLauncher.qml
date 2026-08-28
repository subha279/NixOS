import QtQuick
import Quickshell
import Quickshell.Io
import "../components" as Components
import "../core" as Core
import "../services" as Services


Components.LauncherSurface {
    id: launcher

    launcherId: "launcher"
    promptIcon: Core.Icons.search
    placeholder: "Search applications"

    cardWidth: 460

    columns: 1

    rowHeight: 44

    readonly property var results: Services.AppsService.search(launcher.query)

    itemCount: launcher.results.length

    counterText: launcher.query.length === 0 ? launcher.results.length + " apps" : launcher.results.length + " of " + Services.AppsService.count

    onAccepted: {
        const entry = launcher.results[launcher.selectedIndex];
        if (!entry)
            return;

        launcher.dismiss();
        Services.AppsService.launch(entry);
    }

    IpcHandler {
        target: "launcher"

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
            preferredHighlightBegin: 40
            preferredHighlightEnd: height - 40

            Text {
                anchors.centerIn: parent
                visible: launcher.results.length === 0

                text: "No matching applications"
                color: Core.Theme.foregroundFaint
                font.family: Core.Theme.fontMono
                font.pixelSize: Core.Theme.fontSize
            }

            delegate: Rectangle {
                id: row

                required property var modelData
                required property int index

                readonly property bool selected: row.index === launcher.selectedIndex

                width: list.width - 24

                transform: Translate {
                    x: 12
                }

                height: 40

                radius: Core.Theme.radiusRow

                color: row.selected ? Core.Theme.surfaceGlass : "transparent"

                z: row.selected ? 2 : 0

                scale: row.selected ? 1.03 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: 240
                        easing.type: Easing.OutQuint
                    }
                }

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

                    Image {
                        anchors.verticalCenter: parent.verticalCenter

                        width: 22
                        height: 22

                        asynchronous: true
                        sourceSize.width: 44
                        sourceSize.height: 44

                        source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            text: row.modelData.name

                            color: Core.Theme.foreground
                            font.weight: row.selected ? Font.DemiBold : Font.Medium

                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSize
                        }

                        Text {
                            readonly property string subtitle: row.modelData.genericName && row.modelData.genericName.length > 0 ? row.modelData.genericName : (row.modelData.comment || "")

                            visible: subtitle.length > 0

                            text: subtitle
                            color: row.selected ? Core.Theme.foregroundMuted : Core.Theme.foregroundFaint
                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSizeSmall

                            width: row.width - 22 - Core.Theme.padding * 3
                            elide: Text.ElideRight
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
