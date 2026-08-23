import QtQuick
import Quickshell
import Quickshell.Io
import "../components" as Components
import "../core" as Core
import "../services" as Services

// Application Launcher

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

        // Dismiss first: otherwise the closing surface and the new window race for keyboard focus.
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

            // Rows are inset cards now, in the style of the battery popup, so
            // they need air between them instead of butting together.
            spacing: 4

            // One app per wheel notch. The wheel moves the SELECTION rather
            // than flicking the list, so the highlight is what you steer and
            // the view follows it.
            interactive: false

            WheelHandler {
                onWheel: function (event) {
                    launcher.wheelSelect(event.angleDelta.y);
                }
            }

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

                // Inset from the list so the selected row has somewhere to
                // grow into: a full-bleed row scaled up runs off both edges and
                // gets shaved flat by the clip.
                //
                // The inset has to come from a transform, not from x. A vertical
                // ListView positions its delegates itself and assigns x = 0 on
                // every layout pass, which overwrites an x binding here and
                // leaves the row narrow but still hugging the left edge. A
                // Translate is applied on top of the view's positioning, so it
                // survives.
                width: list.width - 24

                transform: Translate {
                    x: 12
                }

                height: 40

                // Rounded and quietly filled, like the rows in the battery
                // popup, instead of inverting to a solid accent bar.
                radius: Core.Theme.radiusRow

                color: row.selected ? Core.Theme.surfaceActive : "transparent"

                // The selected row grows past its slot, so it paints over its
                // neighbours.
                z: row.selected ? 2 : 0

                // Zoom on selection: 12px of gutter against 6.5px of growth at
                // 1.03, so it never reaches the edge.
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

                            // Not inverted any more: the row keeps its own
                            // surface, so the label keeps its own colour and
                            // just gains weight when selected.
                            color: Core.Theme.foreground
                            font.weight: row.selected ? Font.DemiBold : Font.Medium

                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSize
                        }

                        Text {
                            readonly property string subtitle: row.modelData.genericName && row.modelData.genericName.length > 0 ? row.modelData.genericName : (row.modelData.comment || "")

                            visible: subtitle.length > 0

                            text: subtitle
                            // The row is no longer accent-filled, so the muted
                            // greys read fine in both states.
                            color: row.selected ? Core.Theme.foregroundMuted : Core.Theme.foregroundFaint
                            font.family: Core.Theme.fontMono
                            font.pixelSize: Core.Theme.fontSizeSmall

                            width: row.width - 22 - Core.Theme.padding * 3
                            elide: Text.ElideRight
                        }
                    }
                }

                // Wheel and click only. Hover no longer moves the selection:
                // with the wheel driving the highlight, a pointer resting over
                // the list was just fighting it for control.
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
