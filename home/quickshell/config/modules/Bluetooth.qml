import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services

// Bluetooth bar module

Item {
    id: root

    implicitWidth: 30
    implicitHeight: Core.Theme.moduleHeight

    readonly property bool menuOpen: Core.PopupManager.isOpen("bluetooth")

    readonly property bool powered: Services.BluetoothService.powered

    readonly property int connectedCount: Services.BluetoothService.connectedCount

    Rectangle {
        anchors.fill: parent

        radius: height / 2

        color: root.menuOpen ? Core.Theme.surfaceActive : mouse.containsMouse ? Core.Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 120
                easing.type: Easing.OutQuint
            }
        }
    }

    Text {
        id: icon

        anchors.centerIn: parent

        text: !root.powered ? "\udb80\udcb2" : root.connectedCount > 0 ? "\udb80\udcb1" : "\udb80\udcaf"

        font.family: Core.Theme.fontFamily
        font.pixelSize: Core.Theme.iconSize

        color: !root.powered ? Core.Theme.foregroundMuted : root.connectedCount > 0 ? Core.Theme.accent : Core.Theme.foreground

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutQuint
            }
        }

        // Little pop whenever the icon changes
        onTextChanged: popAnim.restart()

        SequentialAnimation {
            id: popAnim

            NumberAnimation {
                target: icon
                property: "scale"
                to: 1.22
                duration: 110
                easing.type: Easing.OutQuint
            }

            NumberAnimation {
                target: icon
                property: "scale"
                to: 1.0
                duration: 160
                easing.type: Easing.OutQuint
            }
        }
    }

    // Scanning pulse

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right

        anchors.topMargin: 5
        anchors.rightMargin: 4

        width: 5
        height: 5

        radius: 3

        color: Core.Theme.accent

        opacity: Services.BluetoothService.discovering ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutQuint
            }
        }

        SequentialAnimation on scale {
            running: Services.BluetoothService.discovering
            loops: Animation.Infinite

            NumberAnimation {
                to: 1.6
                duration: 480
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                to: 1.0
                duration: 480
                easing.type: Easing.InOutSine
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: function (event) {
            if (event.button === Qt.MiddleButton) {
                Services.BluetoothService.togglePowered();
                return;
            }

            if (event.button === Qt.RightButton) {
                Services.BluetoothService.openManager();
                return;
            }

            const p = root.mapToItem(null, 0, root.height);

            Core.PopupManager.toggle("bluetooth", p.x + root.width / 2, p.y + Core.Theme.barMarginTop);
        }

        onWheel: function (event) {
            if (event.angleDelta.y === 0)
                return;
            Services.BluetoothService.togglePowered();
        }
    }

    Binding {
        target: Services.BluetoothService
        property: "fastPoll"
        value: root.menuOpen
    }

    // Stop scanning when the menu closes — saves battery
    onMenuOpenChanged: {
        if (!root.menuOpen && Services.BluetoothService.discovering)
            Services.BluetoothService.setDiscovering(false);
    }
}
