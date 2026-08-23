import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services
import "../components" as Components

// BluetoothPopup

Components.PopupSurface {
    id: popup

    popupId: "bluetooth"

    cardWidth: 340
    maxCardHeight: 470

    readonly property var svc: Services.BluetoothService

    // Start discovering as soon as the menu opens
    onDidOpen: {
        if (popup.svc.powered)
            popup.svc.setDiscovering(true);
    }

    onDidClose: {
        if (popup.svc.discovering)
            popup.svc.setDiscovering(false);
    }

    // Content

    contentComponent: Component {

        Column {
            id: body

            spacing: Core.Theme.spacing

            // Header

            Components.PopupHeader {
                width: parent.width

                title: "Bluetooth"

                subtitle: popup.svc.primaryLabel

                showToggle: true
                toggled: popup.svc.powered

                onToggleRequested: popup.svc.togglePowered()

                actions: [
                    {
                        icon: popup.svc.discovering ? Core.Icons.refresh : "\udb80\udd6c",
                        spinning: popup.svc.discovering,
                        action: function () {
                            if (!popup.svc.powered)
                                popup.svc.setPowered(true);

                            popup.svc.toggleDiscovering();
                        }
                    },
                    {
                        icon: Core.Icons.gear,
                        action: function () {
                            popup.svc.openManager();
                            Core.PopupManager.close();
                        }
                    }
                ]
            }

            Rectangle {
                width: parent.width
                height: 1

                color: Core.Theme.separator
            }

            // Section label

            Item {
                width: parent.width
                height: 16

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    text: "DEVICES"

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1

                    color: Core.Theme.foregroundFaint
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    text: popup.svc.discovering ? "scanning…" : popup.svc.deviceModel.count + " found"

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.foregroundFaint

                    opacity: popup.svc.powered ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutQuint
                        }
                    }
                }
            }

            // Device list

            Item {
                width: parent.width

                readonly property int maxListHeight: 300

                height: popup.svc.powered ? Math.min(list.contentHeight, maxListHeight) : 0

                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: Core.Theme.durBase
                        easing.type: Easing.OutQuint
                    }
                }

                ListView {
                    id: list

                    anchors.fill: parent

                    clip: true

                    spacing: 1

                    boundsBehavior: Flickable.StopAtBounds

                    model: popup.svc.deviceModel

                    add: Transition {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 160
                            easing.type: Easing.OutQuint
                        }

                        NumberAnimation {
                            property: "scale"
                            from: 0.86
                            to: 1
                            duration: 180
                            easing.type: Easing.OutQuint
                        }
                    }

                    remove: Transition {
                        NumberAnimation {
                            property: "opacity"
                            to: 0
                            duration: 160
                            easing.type: Easing.InQuint
                        }

                        NumberAnimation {
                            property: "scale"
                            to: 0.8
                            duration: 160
                            easing.type: Easing.InQuint
                        }
                    }

                    displaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 170
                            easing.type: Easing.OutQuint
                        }
                    }

                    addDisplaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 170
                            easing.type: Easing.OutQuint
                        }
                    }

                    removeDisplaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 160
                            easing.type: Easing.OutQuint
                        }
                    }

                    delegate: Components.ListRow {
                        id: devRow

                        // These roles are prefixed because `name`, `icon` and `state` collide with ListRow's own properties, which produces a self-referential
                        required property string address
                        required property string deviceName
                        required property string deviceIcon
                        required property string stateText
                        required property bool connected
                        required property bool paired
                        required property bool trusted
                        required property bool blocked
                        required property int battery

                        width: list.width

                        icon: devRow.deviceIcon

                        title: devRow.deviceName

                        subtitle: devRow.stateText

                        trailing: devRow.battery >= 0 ? devRow.battery + "%" : devRow.connected ? "\udb80\udd34" : ""

                        trailingColor: devRow.battery >= 0 ? (devRow.battery < 20 ? Core.Theme.danger : Core.Theme.foregroundMuted) : Core.Theme.success

                        active: devRow.connected

                        dimmed: devRow.blocked

                        busy: popup.svc.pendingAddress === devRow.address

                        // Left click: connect / disconnect

                        onActivated: {
                            if (!devRow.paired && !devRow.connected) {
                                popup.svc.pairDevice(devRow.address);
                                return;
                            }

                            popup.svc.toggleDevice(devRow.address);
                        }

                        // Right click: full device menu

                        onContextRequested: function (mx, my) {
                            const items = [];

                            items.push({
                                icon: devRow.connected ? "\udb80\udcb2" : "\udb80\udcb1",
                                label: devRow.connected ? "Disconnect" : "Connect",
                                action: function () {
                                    popup.svc.toggleDevice(devRow.address);
                                }
                            });

                            if (!devRow.paired) {
                                items.push({
                                    icon: "\udb80\udd7f",
                                    label: "Pair",
                                    action: function () {
                                        popup.svc.pairDevice(devRow.address);
                                    }
                                });
                            }

                            if (devRow.paired) {
                                items.push({
                                    icon: devRow.trusted ? Core.Icons.close : "\udb80\udc93",
                                    label: devRow.trusted ? "Untrust device" : "Trust device",
                                    action: function () {
                                        popup.svc.setTrusted(devRow.address, !devRow.trusted);
                                    }
                                });
                            }

                            items.push({
                                icon: devRow.blocked ? "\udb80\udd34" : Core.Icons.closeCircle,
                                label: devRow.blocked ? "Unblock" : "Block",
                                action: function () {
                                    popup.svc.setBlocked(devRow.address, !devRow.blocked);
                                }
                            });

                            items.push({
                                separator: true
                            });

                            items.push({
                                icon: "\udb81\udcd6",
                                label: "Copy address",
                                action: function () {
                                    Quickshell.clipboardText = devRow.address;
                                }
                            });

                            items.push({
                                icon: "\udb80\udd7c",
                                label: "Open Blueman",
                                action: function () {
                                    popup.svc.openManager();
                                    Core.PopupManager.close();
                                }
                            });

                            if (devRow.paired) {
                                items.push({
                                    separator: true
                                });

                                items.push({
                                    icon: "\udb80\uddb4",
                                    label: "Forget device",
                                    danger: true,
                                    action: function () {
                                        popup.svc.forgetDevice(devRow.address);
                                    }
                                });
                            }

                            popup.openMenu(mx, my, items);
                        }
                    }
                }
            }

            // Empty / off state

            Item {
                width: parent.width

                clip: true

                readonly property bool showEmpty: !popup.svc.powered || popup.svc.deviceModel.count === 0

                height: showEmpty ? 56 : 0

                opacity: showEmpty ? 1.0 : 0.0

                Behavior on height {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutQuint
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuint
                    }
                }

                Column {
                    anchors.centerIn: parent

                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: popup.svc.powered ? "\udb80\udcaf" : "\udb80\udcb2"

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: 20

                        color: Core.Theme.foregroundFaint
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: popup.svc.powered ? "No devices yet — hit scan" : "Bluetooth is turned off"

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: Core.Theme.fontSizeSmall

                        color: Core.Theme.foregroundMuted
                    }
                }
            }
        }
    }
}
