import QtQuick
import Quickshell
import Quickshell.Io
import "../components" as Components
import "../core" as Core
import "../services" as Services

// ============================================================
// Application Launcher
// ============================================================
//
// Replaces the Fuzzel application mode.
//
// Opened from Hyprland with:
//
//   qs ipc call launcher toggle
//
// ============================================================

Components.LauncherSurface {
    id: launcher

    launcherId: "launcher"
    promptIcon: Core.Icons.search
    placeholder: "Search applications"

    cardWidth: 460
    cardHeight: 460

    columns: 1

    readonly property var results: Services.AppsService.search(launcher.query)

    itemCount: launcher.results.length

    counterText: launcher.query.length === 0 ? launcher.results.length + " apps" : launcher.results.length + " of " + Services.AppsService.count

    onAccepted: {
        const entry = launcher.results[launcher.selectedIndex];
        if (!entry)
            return;

        // Dismiss first: otherwise the closing surface and the new
        // window race for keyboard focus.
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
            // Contiguous rows: no gap between selection bars.
            spacing: 0

            // Keep the selection off the very edge while scrolling.
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

                width: list.width
                height: 40

                // Omarchy selection: the entire row inverts to a solid
                // accent bar running edge to edge, replacing the
                // rounded pill plus indicator stripe.
                radius: 0

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
                            color: row.selected ? Core.Theme.accentForeground : Core.Theme.foreground
                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSize
                        }

                        Text {
                            readonly property string subtitle: row.modelData.genericName && row.modelData.genericName.length > 0 ? row.modelData.genericName : (row.modelData.comment || "")

                            visible: subtitle.length > 0

                            text: subtitle
                            // On an accent-filled row, faint grey would
                            // be unreadable, so dim the accent
                            // foreground instead.
                            color: row.selected ? Qt.alpha(Core.Theme.accentForeground, 0.75) : Core.Theme.foregroundFaint
                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSizeSmall

                            width: row.width - 22 - Core.Theme.padding * 3
                            elide: Text.ElideRight
                        }
                    }
                }

                HoverHandler {
                    id: hover

                    // Syncing hover into the selection keeps mouse and
                    // keyboard from disagreeing about what Enter does.
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
