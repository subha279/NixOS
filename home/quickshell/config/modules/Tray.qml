import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.SystemTray

import "../core" as Core

Item {
    id: root

    property var barWindow: null

    implicitWidth: trayRow.implicitWidth
    implicitHeight: Core.Theme.moduleHeight

    // Hidden system tray applications

    function isHidden(item) {
        const id = String(item.id || "").toLowerCase();
        const title = String(item.title || "").toLowerCase();
        const tooltip = String(item.tooltip || "").toLowerCase();

        return (id.includes("nm-applet") || id.includes("networkmanager") || id.includes("blueman") || title.includes("networkmanager") || title.includes("blueman") || tooltip.includes("networkmanager") || tooltip.includes("blueman"));
    }

    RowLayout {
        id: trayRow

        anchors.centerIn: parent

        spacing: 2

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayItem

                required property var modelData

                // Hide NetworkManager and Blueman from the visual tray while keeping their processes alive.
                visible: !root.isHidden(modelData)

                implicitWidth: visible ? 26 : 0

                implicitHeight: Core.Theme.moduleHeight

                Rectangle {
                    anchors.fill: parent

                    radius: 14

                    color: mouse.containsMouse ? Core.Theme.hover : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                            easing.type: Easing.OutQuint
                        }
                    }
                }

                Image {
                    anchors.centerIn: parent

                    width: 17
                    height: 17

                    source: modelData.icon

                    fillMode: Image.PreserveAspectFit

                    smooth: true
                    mipmap: true
                }

                MouseArea {
                    id: mouse

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor

                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: function (event) {
                        if (event.button === Qt.LeftButton) {
                            if (modelData.onlyMenu || modelData.hasMenu) {
                                const p = trayItem.mapToItem(root.barWindow.contentItem, 0, trayItem.height);

                                modelData.display(root.barWindow, Math.round(p.x), Math.round(p.y));
                            } else {
                                modelData.activate();
                            }

                            return;
                        }

                        if (event.button === Qt.RightButton) {
                            if (modelData.hasMenu) {
                                const p = trayItem.mapToItem(root.barWindow.contentItem, 0, trayItem.height);

                                modelData.display(root.barWindow, Math.round(p.x), Math.round(p.y));
                            }

                            return;
                        }

                        if (event.button === Qt.MiddleButton) {
                            modelData.secondaryActivate();
                        }
                    }
                }
            }
        }
    }
}
