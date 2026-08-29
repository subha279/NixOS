import QtQuick
import Quickshell
import Quickshell.Io
import "../components" as Components
import "../core" as Core
import "../services" as Services

// Application Launcher

Components.LauncherView {
    id: launcher

    launcherId: "launcher"
    tint: Core.Theme.hueApps
    promptIcon: Core.Icons.search
    placeholder: "Search applications"

    cardWidth: 460
    rowHeight: 44

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

            spacing: 4

            interactive: false

            // Keep the selection off the very edge while scrolling.
            highlightRangeMode: ListView.ApplyRange
            preferredHighlightBegin: 40
            preferredHighlightEnd: height - 40

            Text {
                anchors.centerIn: parent
                visible: launcher.results.length === 0

                text: "No matching applications"
                color: Core.Theme.foregroundFaint
                font.family: Core.Theme.fontFamily
                font.pixelSize: Core.Theme.fontSize
                renderType: Text.QtRendering
            }

            delegate: Rectangle {
                id: row

                required property var modelData
                required property int index

                readonly property bool selected: row.index === launcher.selectedIndex

                width: list.width - Core.Theme.space3 * 2

                transform: Translate {
                    x: Core.Theme.space3
                }

                height: 44

                radius: Core.Theme.radiusRow

                color: row.selected ? Core.Theme.tinted(launcher.tint, Core.Theme.chipAlpha) : rowMouse.containsMouse ? Core.Theme.surfaceGlassHover : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Core.Theme.durFast
                        easing.type: Easing.OutQuint
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    width: 3
                    height: row.selected ? parent.height * 0.44 : 0

                    radius: 2

                    color: launcher.tint

                    Behavior on height {
                        NumberAnimation {
                            duration: Core.Theme.durBase
                            easing.type: Easing.OutQuint
                        }
                    }
                }

                Rectangle {
                    id: appChip

                    anchors.left: parent.left
                    anchors.leftMargin: Core.Theme.space2
                    anchors.verticalCenter: parent.verticalCenter

                    width: Core.Theme.chipSize
                    height: Core.Theme.chipSize

                    radius: Core.Theme.chipRadius

                    color: row.selected ? Core.Theme.tinted(launcher.tint, Core.Theme.chipAlphaActive) : Core.Theme.surfaceSunken

                    Behavior on color {
                        ColorAnimation {
                            duration: Core.Theme.durFast
                            easing.type: Easing.OutQuint
                        }
                    }

                    Image {
                        anchors.centerIn: parent

                        width: Core.Theme.iconSizeMedium
                        height: Core.Theme.iconSizeMedium

                        asynchronous: true
                        sourceSize.width: Core.Theme.iconSizeMedium * 2
                        sourceSize.height: Core.Theme.iconSizeMedium * 2

                        smooth: true
                        mipmap: true

                        fillMode: Image.PreserveAspectFit

                        source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                    }
                }

                Column {
                    anchors.left: appChip.right
                    anchors.leftMargin: Core.Theme.space3
                    anchors.right: parent.right
                    anchors.rightMargin: Core.Theme.padRow
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: Core.Theme.gapTight

                    Text {
                        width: parent.width

                        text: row.modelData.name

                        color: Core.Theme.foreground
                        font.weight: row.selected ? Font.DemiBold : Font.Medium

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: Core.Theme.fontSize

                        renderType: Text.QtRendering

                        elide: Text.ElideRight
                    }

                    Text {
                        readonly property string subtitle: row.modelData.genericName && row.modelData.genericName.length > 0 ? row.modelData.genericName : (row.modelData.comment || "")

                        width: parent.width

                        visible: subtitle.length > 0

                        text: subtitle

                        color: row.selected ? launcher.tint : Core.Theme.foregroundFaint

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: Core.Theme.fontSizeSmall

                        renderType: Text.QtRendering

                        elide: Text.ElideRight

                        Behavior on color {
                            ColorAnimation {
                                duration: Core.Theme.durBase
                                easing.type: Easing.OutQuint
                            }
                        }
                    }
                }

                MouseArea {
                    id: rowMouse

                    anchors.fill: parent

                    hoverEnabled: true

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
