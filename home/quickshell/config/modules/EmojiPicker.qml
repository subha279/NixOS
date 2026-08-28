import QtQuick
import Quickshell
import Quickshell.Io

import "../components" as Components
import "../core" as Core
import "../services" as Services

Components.LauncherView {
    id: picker

    launcherId: "emoji"

    promptIcon: Core.Icons.emoji
    placeholder: "Search emoji"

    cardWidth: 560
    cellHeight: 70

    contentMargins: 24

    columns: 6

    readonly property var results: {
        const result = Services.EmojiService.search(picker.query);
        return result || [];
    }

    itemCount: picker.results.length

    counterText: picker.query.length === 0 ? picker.results.length + " emoji" : picker.results.length + " matches"

    onAccepted: {
        insertSelected();
    }

    function insertSelected() {
        if (results.length === 0)
            return;

        const item = results[selectedIndex];

        if (!item || !item.emoji)
            return;

        picker.dismiss();

        copyProcess.command = ["wl-copy", "--", item.emoji];

        copyProcess.running = true;
    }

    IpcHandler {
        target: "emoji"

        function toggle(): void {
            picker.toggle();
        }

        function open(): void {
            picker.show();
        }

        function close(): void {
            picker.dismiss();
        }
    }

    Process {
        id: copyProcess

        command: []
    }

    contentComponent: Component {
        Item {
            width: parent.width
            height: parent.height

            GridView {
                id: grid

                anchors.fill: parent

                anchors.leftMargin: 12
                anchors.rightMargin: 12
                anchors.topMargin: 12
                anchors.bottomMargin: 12

                model: picker.results

                currentIndex: picker.selectedIndex

                cellWidth: Math.floor(width / picker.columns)

                cellHeight: 70

                clip: true

                interactive: false

                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: cell

                    required property var modelData
                    required property int index

                    readonly property bool selected: cell.index === picker.selectedIndex

                    width: grid.cellWidth
                    height: grid.cellHeight

                    radius: Core.Theme.radiusRow

                    color: cell.selected ? Core.Theme.surfaceGlass : "transparent"

                    scale: cell.selected ? 1.05 : 1.0

                    z: cell.selected ? 2 : 0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutQuint
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Core.Theme.durFast
                            easing.type: Easing.OutQuint
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        anchors.top: parent.top

                        anchors.topMargin: 7

                        text: cell.modelData.emoji || ""

                        font.family: Core.Theme.emojiFont

                        font.pixelSize: 28

                        renderType: Text.NativeRendering
                    }

                    Text {
                        anchors.left: parent.left

                        anchors.right: parent.right

                        anchors.bottom: parent.bottom

                        anchors.bottomMargin: 6

                        horizontalAlignment: Text.AlignHCenter

                        text: cell.modelData.name || ""

                        color: cell.selected ? Core.Theme.foreground : Core.Theme.foregroundFaint

                        font.family: Core.Theme.fontFamily

                        font.pixelSize: 8

                        elide: Text.ElideRight

                        maximumLineCount: 1
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            picker.selectedIndex = cell.index;

                            picker.insertSelected();
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent

                    visible: Services.EmojiService.ready && picker.results.length === 0

                    text: picker.query.length > 0 ? "No matching emoji" : "No emoji available"

                    color: Core.Theme.foregroundFaint

                    font.family: Core.Theme.fontFamily

                    font.pixelSize: Core.Theme.fontSize
                }

                Text {
                    anchors.centerIn: parent

                    visible: !Services.EmojiService.ready

                    text: "Loading emoji…"

                    color: Core.Theme.foregroundFaint

                    font.family: Core.Theme.fontFamily

                    font.pixelSize: Core.Theme.fontSize
                }
            }
        }
    }
}
