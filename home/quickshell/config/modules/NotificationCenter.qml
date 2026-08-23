import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services

// Notification center bar module (leftmost slot)

Item {
    id: root

    implicitWidth: 30
    implicitHeight: Core.Theme.moduleHeight

    readonly property bool menuOpen: Core.PopupManager.isOpen("notifications")

    readonly property var list: Services.NotificationServer.notifications

    readonly property int count: (root.list && root.list.values) ? root.list.values.length : 0

    // Do-not-disturb is shared with the panel through PopupManager.
    readonly property bool dnd: Core.PopupManager.dnd

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

        // Resolved through Core.Icons rather than inlined surrogate pairs --
        // hand-written pairs here are exactly how a bus ended up in the bar.
        text: root.dnd ? Core.Icons.bellOff : root.count > 0 ? Core.Icons.bellRing : Core.Icons.bell

        font.family: Core.Theme.fontFamily
        font.pixelSize: Core.Theme.iconSize

        color: root.dnd ? Core.Theme.foregroundFaint : root.count > 0 ? Core.Theme.accent : Core.Theme.foreground

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutQuint
            }
        }

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

    // Unread count badge

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right

        anchors.topMargin: 2
        anchors.rightMargin: 0

        width: Math.max(13, badgeText.implicitWidth + 6)
        height: 13

        radius: 7

        color: Core.Theme.accent

        visible: root.count > 0 && !root.dnd

        scale: (root.count > 0 && !root.dnd) ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutQuint
            }
        }

        Text {
            id: badgeText

            anchors.centerIn: parent

            text: root.count > 9 ? "9+" : root.count

            font.family: Core.Theme.fontFamily
            font.pixelSize: 9
            font.weight: Font.DemiBold

            color: Core.Theme.accentForeground
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
                Core.PopupManager.dnd = !Core.PopupManager.dnd;
                return;
            }

            if (event.button === Qt.RightButton) {
                root.clearAll();
                return;
            }

            const p = root.mapToItem(null, 0, root.height);

            Core.PopupManager.toggle("notifications", p.x + root.width / 2, p.y + Core.Theme.barMarginTop);
        }
    }

    function dismiss(n) {
        if (!n)
            return;

        // Prefer dismiss(); fall back to expire() on older builds.
        if (typeof n.dismiss === "function")
            n.dismiss();
        else if (typeof n.expire === "function")
            n.expire();
    }

    function clearAll() {
        if (!root.list || !root.list.values)
            return;

        // Copy first — dismissing mutates the live model.
        const snapshot = root.list.values.slice();

        for (let i = 0; i < snapshot.length; i++)
            root.dismiss(snapshot[i]);
    }
}
