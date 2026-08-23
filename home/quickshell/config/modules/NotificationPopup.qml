import QtQuick

import Quickshell
import Quickshell.Io

import "../core" as Core
import "../services" as Services
import "../components" as Components

// NotificationPopup

Components.PopupSurface {
    id: popup

    popupId: "notifications"

    cardWidth: 360
    maxCardHeight: 480

    readonly property var list: Services.NotificationServer.notifications

    readonly property int count: (popup.list && popup.list.values) ? popup.list.values.length : 0

    readonly property bool dnd: Core.PopupManager.dnd

    function setDnd(value) {
        Core.PopupManager.dnd = value;
    }

    function dismiss(n) {
        if (!n)
            return;
        if (typeof n.dismiss === "function")
            n.dismiss();
        else if (typeof n.expire === "function")
            n.expire();
    }

    function clearAll() {
        if (!popup.list || !popup.list.values)
            return;
        const snapshot = popup.list.values.slice();

        for (let i = 0; i < snapshot.length; i++)
            popup.dismiss(snapshot[i]);
    }

    function invoke(n, action) {
        if (!n || !action)
            return;
        try {
            if (typeof action.invoke === "function")
                action.invoke();
        } catch (e) {
            // Some senders drop off the bus before we get here.
        }

        popup.dismiss(n);
    }

    function copyText(text) {
        if (!text || text === "")
            return;
        try {
            Quickshell.clipboardText = text;
        } catch (e) {
            copyProc.command = ["sh", "-c", "printf %s " + JSON.stringify(text) + " | wl-copy"];
            copyProc.running = true;
        }
    }

    function appLabel(n) {
        if (!n)
            return "";

        if (n.appName && n.appName !== "")
            return n.appName;

        if (n.desktopEntry && n.desktopEntry !== "")
            return n.desktopEntry;

        return "Notification";
    }

    function isCritical(n) {
        if (!n)
            return false;

        // Urgency is an enum; 2 == Critical in the freedesktop spec.
        try {
            return Number(n.urgency) === 2;
        } catch (e) {
            return false;
        }
    }

    Process {
        id: copyProc

        running: false
    }

    // Content

    contentComponent: Component {

        Column {
            id: body

            spacing: Core.Theme.spacing

            // Header

            Components.PopupHeader {
                width: body.width

                title: "Notifications"

                subtitle: popup.dnd ? "Do not disturb" : popup.count === 0 ? "All caught up" : popup.count === 1 ? "1 notification" : popup.count + " notifications"

                showToggle: true

                // The toggle drives do-not-disturb; on means "allowed".
                toggled: !popup.dnd

                onToggleRequested: popup.setDnd(!popup.dnd)

                actions: [
                    {
                        icon: "\udb80\uddb4",
                        tooltip: "Clear all",
                        action: function () {
                            popup.clearAll();
                        }
                    }
                ]
            }

            // Do-not-disturb banner

            Rectangle {
                width: body.width

                height: popup.dnd ? 32 : 0

                visible: height > 1

                clip: true

                radius: Core.Theme.radiusRow

                color: Qt.alpha(Core.Theme.warning, 0.13)

                Behavior on height {
                    NumberAnimation {
                        duration: Core.Theme.durBase
                        easing.type: Easing.OutQuint
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    text: Core.Icons.bellOff + "  New alerts are being silenced"

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.warning
                }
            }

            // The list

            Item {
                id: listBox

                readonly property int maxListHeight: 330

                width: body.width

                height: Math.min(list.contentHeight, listBox.maxListHeight)

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

                    spacing: 4

                    clip: true

                    boundsBehavior: Flickable.StopAtBounds

                    model: popup.list

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

                    delegate: Rectangle {
                        id: noteRow

                        required property var modelData

                        width: list.width

                        implicitHeight: noteLayout.implicitHeight + 20
                        height: implicitHeight

                        radius: Core.Theme.radiusRow

                        color: noteMouse.containsMouse ? Core.Theme.surfaceHover : Core.Theme.surface

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                                easing.type: Easing.OutQuint
                            }
                        }

                        scale: noteMouse.pressed ? 0.97 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 110
                                easing.type: Easing.OutQuint
                            }
                        }

                        // Urgency stripe
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.margins: 6

                            width: 3

                            radius: 2

                            color: popup.isCritical(noteRow.modelData) ? Core.Theme.danger : Core.Theme.accent

                            opacity: popup.isCritical(noteRow.modelData) ? 1.0 : 0.55
                        }

                        Column {
                            id: noteLayout

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top

                            anchors.leftMargin: 18
                            anchors.rightMargin: 34
                            anchors.topMargin: 10

                            spacing: 3

                            Text {
                                width: parent.width

                                text: popup.appLabel(noteRow.modelData).toUpperCase()

                                elide: Text.ElideRight

                                font.family: Core.Theme.fontFamily
                                font.pixelSize: Core.Theme.fontSizeSmall
                                font.letterSpacing: 0.8

                                color: Core.Theme.foregroundFaint
                            }

                            Text {
                                width: parent.width

                                text: noteRow.modelData.summary ? noteRow.modelData.summary : ""

                                visible: text !== ""

                                elide: Text.ElideRight

                                font.family: Core.Theme.fontFamily
                                font.pixelSize: Core.Theme.fontSize
                                font.weight: Font.DemiBold

                                color: Core.Theme.foreground
                            }

                            Text {
                                width: parent.width

                                text: noteRow.modelData.body ? noteRow.modelData.body : ""

                                visible: text !== ""

                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight

                                textFormat: Text.PlainText

                                font.family: Core.Theme.fontFamily
                                font.pixelSize: Core.Theme.fontSizeSmall

                                color: Core.Theme.foregroundMuted
                            }

                            // Inline action buttons
                            Row {
                                spacing: 6

                                topPadding: 4

                                visible: actionRepeater.count > 0

                                Repeater {
                                    id: actionRepeater

                                    model: noteRow.modelData.actions ? noteRow.modelData.actions : []

                                    delegate: Rectangle {
                                        id: actionChip

                                        required property var modelData

                                        height: 22

                                        width: chipText.implicitWidth + 18

                                        radius: 11

                                        color: chipMouse.containsMouse ? Core.Theme.surfaceActive : Core.Theme.hover

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 120
                                                easing.type: Easing.OutQuint
                                            }
                                        }

                                        Text {
                                            id: chipText

                                            anchors.centerIn: parent

                                            text: actionChip.modelData.text ? actionChip.modelData.text : "Open"

                                            font.family: Core.Theme.fontFamily

                                            font.pixelSize: Core.Theme.fontSizeSmall

                                            color: Core.Theme.foreground
                                        }

                                        MouseArea {
                                            id: chipMouse

                                            anchors.fill: parent

                                            hoverEnabled: true

                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: popup.invoke(noteRow.modelData, actionChip.modelData)
                                        }
                                    }
                                }
                            }
                        }

                        // Per-notification close button
                        Rectangle {
                            id: closeBtn

                            anchors.right: parent.right
                            anchors.top: parent.top

                            anchors.rightMargin: 6
                            anchors.topMargin: 6

                            width: 22
                            height: 22

                            radius: 11

                            color: closeMouse.containsMouse ? Core.Theme.surfaceHover : "transparent"

                            opacity: noteMouse.containsMouse || closeMouse.containsMouse ? 1.0 : 0.0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 140
                                    easing.type: Easing.OutQuint
                                }
                            }

                            Text {
                                anchors.centerIn: parent

                                text: Core.Icons.close

                                font.family: Core.Theme.fontFamily
                                font.pixelSize: 12

                                color: Core.Theme.foregroundMuted
                            }

                            MouseArea {
                                id: closeMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape: Qt.PointingHandCursor

                                onClicked: popup.dismiss(noteRow.modelData)
                            }
                        }

                        MouseArea {
                            id: noteMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            cursorShape: Qt.PointingHandCursor

                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            z: -1

                            onClicked: function (event) {
                                if (event.button === Qt.LeftButton) {
                                    popup.dismiss(noteRow.modelData);
                                    return;
                                }

                                // Capture values now — the delegate is recycled and modelData can change before the menu action runs.
                                const note = noteRow.modelData;

                                const summary = note.summary ? String(note.summary) : "";

                                const bodyText = note.body ? String(note.body) : "";

                                const app = popup.appLabel(note);

                                const point = noteRow.mapToItem(null, event.x, event.y);

                                popup.openMenu(point.x, point.y, [
                                    {
                                        icon: Core.Icons.close,
                                        label: "Dismiss",
                                        action: function () {
                                            popup.dismiss(note);
                                        }
                                    },
                                    {
                                        icon: "\udb81\udcd6",
                                        label: "Copy text",
                                        action: function () {
                                            popup.copyText(summary + (bodyText !== "" ? "\n" + bodyText : ""));
                                        }
                                    },
                                    {
                                        icon: "\udb80\udd7c",
                                        label: "Copy app name",
                                        action: function () {
                                            popup.copyText(app);
                                        }
                                    },
                                    {
                                        separator: true
                                    },
                                    {
                                        icon: Core.Icons.bellOff,
                                        label: popup.dnd ? "Turn off do not disturb" : "Turn on do not disturb",
                                        action: function () {
                                            popup.setDnd(!popup.dnd);
                                        }
                                    },
                                    {
                                        icon: "\udb80\uddb4",
                                        label: "Clear all",
                                        danger: true,
                                        action: function () {
                                            popup.clearAll();
                                        }
                                    }
                                ]);
                            }
                        }
                    }
                }
            }

            // Empty state

            Item {
                width: body.width

                height: popup.count === 0 ? 96 : 0

                visible: height > 1

                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: Core.Theme.durBase
                        easing.type: Easing.OutQuint
                    }
                }

                Column {
                    anchors.centerIn: parent

                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: "\udb80\udc9c"

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: 20

                        color: Core.Theme.foregroundFaint
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: "Nothing to catch up on"

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: Core.Theme.fontSizeSmall

                        color: Core.Theme.foregroundMuted
                    }
                }
            }
        }
    }
}
