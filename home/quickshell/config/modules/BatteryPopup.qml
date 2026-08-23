import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services
import "../components" as Components

// BatteryPopup

Components.PopupSurface {
    id: popup

    popupId: "battery"

    cardWidth: 340
    maxCardHeight: 460

    readonly property var svc: Services.BatteryService

    // Whether the peripheral section is expanded
    property bool showPeripherals: true

    contentComponent: Component {

        Column {
            id: body

            spacing: Core.Theme.spacing

            // Header

            Components.PopupHeader {
                width: body.width

                title: "Battery"

                subtitle: popup.svc.stateLabel

                actions: [
                    {
                        icon: popup.svc.profileIcon(popup.svc.profile),
                        tooltip: "Power profile",
                        action: function () {
                            const max = popup.svc.hasPerformance ? 2 : 1;

                            let next = popup.svc.profile + 1;

                            if (next > max)
                                next = 0;

                            popup.svc.setProfile(next);
                        }
                    },
                    {
                        icon: Core.Icons.gear,
                        tooltip: "Power settings",
                        action: function () {
                            popup.svc.openPowerSettings();
                            popup.closeMenu();
                            Core.PopupManager.close();
                        }
                    }
                ]
            }

            // Big charge gauge

            Rectangle {
                id: gauge

                width: body.width

                height: 92

                radius: Core.Theme.radiusRow + 2

                color: Core.Theme.surface

                border.width: Core.Theme.borderWidth
                border.color: Core.Theme.border

                // Percentage + state

                Text {
                    id: bigIcon

                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.top: parent.top
                    anchors.topMargin: 14

                    text: popup.svc.icon

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: 26

                    color: popup.svc.color

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.OutQuint
                        }
                    }
                }

                Text {
                    id: bigPercent

                    anchors.left: bigIcon.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: bigIcon.verticalCenter

                    text: popup.svc.percentInt + "%"

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: 24
                    font.weight: Font.DemiBold

                    color: Core.Theme.foreground
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: bigIcon.verticalCenter

                    text: popup.svc.changeRate > 0 ? popup.svc.changeRate.toFixed(1) + " W" : ""

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.foregroundMuted
                }

                // Springy fill bar

                Rectangle {
                    id: barTrack

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    anchors.bottomMargin: 26

                    height: 8

                    radius: 4

                    color: Core.Theme.separator

                    Rectangle {
                        id: barFill

                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        width: barTrack.width * Math.max(0.02, Math.min(1.0, popup.svc.percent / 100))

                        radius: 4

                        color: popup.svc.color

                        Behavior on width {
                            NumberAnimation {
                                duration: Core.Theme.durBase
                                easing.type: Easing.OutQuint
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 160
                                easing.type: Easing.OutQuint
                            }
                        }
                    }

                    // Charging shimmer
                    Rectangle {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        width: 40

                        radius: 4

                        color: Core.Theme.text

                        opacity: popup.svc.charging ? 0.18 : 0.0

                        visible: opacity > 0.01

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutQuint
                            }
                        }

                        NumberAnimation on x {
                            running: popup.svc.charging
                            loops: Animation.Infinite

                            from: -40
                            to: barTrack.width

                            duration: 1600
                            easing.type: Easing.InOutSine
                        }
                    }
                }

                // Footnote: health

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8

                    text: popup.svc.health >= 0 ? popup.svc.healthIcon + "  Health " + Math.round(popup.svc.health) + "%" : popup.svc.stateLabel

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.foregroundMuted
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8

                    text: popup.svc.profileLabel

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.accent
                }

                // Right-click the gauge

                MouseArea {
                    anchors.fill: parent

                    acceptedButtons: Qt.RightButton

                    onClicked: function (event) {
                        const p = gauge.mapToItem(null, event.x, event.y);

                        popup.openMenu(p.x, p.y, [
                            {
                                label: "Copy status",
                                icon: "\udb81\udcd6",
                                action: function () {
                                    popup.svc.copySummary();
                                }
                            },
                            {
                                separator: true
                            },
                            {
                                label: "Power settings",
                                icon: Core.Icons.gear,
                                action: function () {
                                    popup.svc.openPowerSettings();
                                    Core.PopupManager.close();
                                }
                            }
                        ]);
                    }
                }
            }

            // Power profiles

            Text {
                width: body.width

                visible: popup.svc.profilesAvailable

                text: "POWER PROFILE"

                font.family: Core.Theme.fontFamily
                font.pixelSize: Core.Theme.fontSizeSmall
                font.letterSpacing: 1
                font.weight: Font.DemiBold

                color: Core.Theme.foregroundFaint

                leftPadding: 6
                topPadding: 4
            }

            Column {
                id: profileColumn

                width: body.width

                spacing: 2

                visible: popup.svc.profilesAvailable

                Repeater {
                    model: popup.svc.hasPerformance ? [0, 1, 2] : [0, 1]

                    delegate: Components.ListRow {
                        id: profileRow

                        required property var modelData

                        width: profileColumn.width

                        icon: popup.svc.profileIcon(profileRow.modelData)

                        title: profileRow.modelData === 0 ? "Power saver" : profileRow.modelData === 2 ? "Performance" : "Balanced"

                        subtitle: profileRow.modelData === 0 ? "Longest battery life" : profileRow.modelData === 2 ? "Maximum speed, more heat" : "Default — good all round"

                        active: popup.svc.profile === profileRow.modelData

                        trailing: (popup.svc.profile === profileRow.modelData) ? "\udb80\udd34" : ""

                        trailingColor: Core.Theme.success

                        onActivated: {
                            popup.svc.setProfile(profileRow.modelData);
                        }

                        onContextRequested: function (mx, my) {
                            const value = profileRow.modelData;

                            popup.openMenu(mx, my, [
                                {
                                    label: "Apply profile",
                                    icon: "\udb80\udc93",
                                    action: function () {
                                        popup.svc.setProfile(value);
                                    }
                                },
                                {
                                    separator: true
                                },
                                {
                                    label: "Power settings",
                                    icon: Core.Icons.gear,
                                    action: function () {
                                        popup.svc.openPowerSettings();
                                        Core.PopupManager.close();
                                    }
                                }
                            ]);
                        }
                    }
                }
            }

            // Degradation warning

            Rectangle {
                width: body.width

                visible: popup.svc.degradationReason !== ""

                height: visible ? 34 : 0

                radius: Core.Theme.radiusRow

                color: Qt.alpha(Core.Theme.warning, 0.13)

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    verticalAlignment: Text.AlignVCenter

                    text: "\udb80\udd7c  Performance limited: " + popup.svc.degradationReason

                    elide: Text.ElideRight

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.warning
                }
            }

            // Peripherals

            Item {
                width: body.width

                visible: popup.svc.peripheralModel.count > 0

                height: visible ? 22 : 0

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter

                    text: "DEVICES"

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall
                    font.letterSpacing: 1
                    font.weight: Font.DemiBold

                    color: Core.Theme.foregroundFaint
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter

                    text: popup.svc.peripheralModel.count + (popup.svc.peripheralModel.count === 1 ? " device" : " devices")

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.foregroundFaint
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: popup.showPeripherals = !popup.showPeripherals
                }
            }

            // The clipped, spring-sized list container.
            Item {
                id: listBox

                width: body.width

                readonly property int maxListHeight: 180

                height: (popup.showPeripherals && popup.svc.peripheralModel.count > 0) ? Math.min(peripheralList.contentHeight, listBox.maxListHeight) : 0

                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: Core.Theme.durBase
                        easing.type: Easing.OutQuint
                    }
                }

                opacity: listBox.height > 2 ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Core.Theme.durFast
                        easing.type: Easing.OutQuint
                    }
                }

                ListView {
                    id: peripheralList

                    anchors.fill: parent

                    clip: true

                    spacing: 2

                    boundsBehavior: Flickable.StopAtBounds

                    model: popup.svc.peripheralModel

                    delegate: Components.ListRow {
                        id: devRow

                        required property string label
                        required property string deviceIcon
                        required property int percent
                        required property bool charging

                        width: peripheralList.width

                        icon: devRow.deviceIcon

                        title: devRow.label

                        subtitle: devRow.charging ? "Charging" : devRow.percent <= 20 ? "Low battery" : "On battery"

                        trailing: devRow.percent + "%"

                        trailingColor: devRow.percent <= 20 ? Core.Theme.danger : devRow.percent <= 40 ? Core.Theme.warning : Core.Theme.foregroundMuted

                        iconColor: devRow.percent <= 20 ? Core.Theme.danger : Core.Theme.foreground

                        onContextRequested: function (mx, my) {
                            const name = devRow.label;
                            const pct = devRow.percent;

                            popup.openMenu(mx, my, [
                                {
                                    label: "Copy \"" + name + "\"",
                                    icon: "\udb81\udcd6",
                                    action: function () {
                                        popup.copyText(name + " — " + pct + "%");
                                    }
                                },
                                {
                                    separator: true
                                },
                                {
                                    label: "Refresh devices",
                                    icon: Core.Icons.refresh,
                                    action: function () {
                                        popup.svc.rebuildPeripherals();
                                    }
                                }
                            ]);
                        }
                    }

                    // Rubbery list transitions

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
                }
            }

            // Empty state

            Text {
                width: body.width

                visible: !popup.svc.available

                text: "No battery detected on this machine."

                horizontalAlignment: Text.AlignHCenter

                topPadding: 10
                bottomPadding: 10

                font.family: Core.Theme.fontFamily
                font.pixelSize: Core.Theme.fontSizeSmall

                color: Core.Theme.foregroundFaint
            }
        }
    }

    // Clipboard helper (kept on the popup so delegates can reach

    function copyText(text) {
        try {
            Quickshell.clipboardText = text;
        } catch (e) {
            // Silently ignore — clipboard is a nice-to-have.
        }
    }
}
