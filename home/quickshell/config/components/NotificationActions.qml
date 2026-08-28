import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services

// Action buttons and the inline reply field for one notification.
//
// Shared by the toast overlay and the notification centre, so the two surfaces
// cannot drift on what a notification is allowed to do. The server advertises
// `actions`, `action-icons` and `inline-reply` to clients, and this is what makes
// good on all three.
//
// The parent must give this a width; the chips wrap inside it.

Item {
    id: root

    property var notification: null

    property int chipHeight: 24

    readonly property var actionList: {
        try {
            const list = root.notification ? root.notification.actions : null;

            return list ? list : [];
        } catch (e) {
            return [];
        }
    }

    // When the sender set the action-icons hint, each action's `identifier` is a
    // freedesktop icon name rather than an opaque key.
    readonly property bool iconActions: Services.NotificationServer.hasActionIcons(root.notification)

    readonly property bool canReply: Services.NotificationServer.hasInlineReply(root.notification)

    readonly property bool replying: Services.NotificationServer.isReplying(root.notification)

    implicitHeight: layout.implicitHeight

    height: root.implicitHeight

    visible: root.actionList.length > 0 || root.canReply

    function focusReply() {
        if (root.replying)
            replyInput.forceActiveFocus();
    }

    onReplyingChanged: {
        if (root.replying) {
            replyInput.text = "";

            // Deferred: the field is made visible by this same change, and an
            // invisible item cannot take focus.
            Qt.callLater(root.focusReply);
        }
    }

    // Absorbs clicks that land in the gaps between chips.
    //
    // Declared first so it sits under the controls. Without it those clicks reach
    // the toast card underneath, whose handler fires the notification's default
    // action and takes the card away mid-interaction.
    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: {}
    }

    Column {
        id: layout

        width: parent.width

        spacing: 6

        // ACTION CHIPS

        Flow {
            width: parent.width

            spacing: 6

            Repeater {
                model: root.actionList

                delegate: Rectangle {
                    id: chip

                    required property var modelData

                    readonly property string label: {
                        try {
                            if (chip.modelData.text && String(chip.modelData.text) !== "")
                                return String(chip.modelData.text);
                        } catch (e) {}

                        return "Open";
                    }

                    readonly property string iconSource: {
                        if (!root.iconActions)
                            return "";

                        try {
                            if (chip.modelData.identifier && String(chip.modelData.identifier) !== "")
                                return Quickshell.iconPath(String(chip.modelData.identifier), true);
                        } catch (e) {}

                        return "";
                    }

                    height: root.chipHeight

                    width: chipIcon.visible ? root.chipHeight + 12 : chipText.implicitWidth + 20

                    radius: height / 2

                    color: chipMouse.containsMouse ? Core.Theme.surfaceGlassHover : Core.Theme.surfaceGlass

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                            easing.type: Easing.OutQuint
                        }
                    }

                    Image {
                        id: chipIcon

                        anchors.centerIn: parent

                        width: Core.Theme.iconSizeSmall
                        height: Core.Theme.iconSizeSmall

                        source: chip.iconSource

                        visible: chip.iconSource !== "" && status === Image.Ready

                        asynchronous: true
                        cache: true
                        smooth: true
                        mipmap: true

                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        id: chipText

                        anchors.centerIn: parent

                        visible: !chipIcon.visible

                        text: chip.label

                        font.family: Core.Theme.fontFamily

                        font.pixelSize: Core.Theme.fontSizeSmall

                        color: Core.Theme.foreground
                    }

                    MouseArea {
                        id: chipMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor

                        onClicked: Services.NotificationServer.invokeAction(root.notification, chip.modelData)
                    }
                }
            }

            // Opens the reply field. Kept separate from the action list because
            // inline reply is not an action in the spec, it is a capability.
            Rectangle {
                visible: root.canReply && !root.replying

                height: root.chipHeight

                width: replyChipText.implicitWidth + 26

                radius: height / 2

                color: replyChipMouse.containsMouse ? Core.Theme.surfaceGlassHover : Core.Theme.surfaceGlass

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                        easing.type: Easing.OutQuint
                    }
                }

                Text {
                    id: replyChipText

                    anchors.centerIn: parent

                    text: Core.Icons.send + "  " + Services.NotificationServer.replyPlaceholder(root.notification)

                    font.family: Core.Theme.iconFont

                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.accent
                }

                MouseArea {
                    id: replyChipMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor

                    onClicked: Services.NotificationServer.beginReply(root.notification)
                }
            }
        }

        // REPLY FIELD

        Rectangle {
            id: replyBox

            width: parent.width

            height: root.replying ? 30 : 0

            visible: root.replying

            radius: 9

            clip: true

            color: Core.Theme.surfaceGlass

            border.width: Core.Theme.borderWidth
            border.color: Core.Theme.borderActive

            TextInput {
                id: replyInput

                anchors.left: parent.left
                anchors.right: sendButton.left
                anchors.verticalCenter: parent.verticalCenter

                anchors.leftMargin: 10
                anchors.rightMargin: 6

                clip: true

                selectByMouse: true

                selectionColor: Core.Theme.accentMuted

                color: Core.Theme.foreground

                font.family: Core.Theme.fontFamily

                font.pixelSize: Core.Theme.fontSizeSmall

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    visible: replyInput.text.length === 0

                    text: Services.NotificationServer.replyPlaceholder(root.notification)

                    font.family: Core.Theme.fontFamily

                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.foregroundFaint
                }

                Keys.onPressed: function (event) {
                    if (event.key === Qt.Key_Escape) {
                        Services.NotificationServer.cancelReply();
                        event.accepted = true;
                        return;
                    }

                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        Services.NotificationServer.sendReply(root.notification, replyInput.text);
                        event.accepted = true;
                    }
                }
            }

            Rectangle {
                id: sendButton

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                anchors.rightMargin: 4

                width: 24
                height: 24

                radius: 12

                color: sendMouse.containsMouse ? Core.Theme.surfaceHover : "transparent"

                Text {
                    anchors.centerIn: parent

                    text: Core.Icons.send

                    font.family: Core.Theme.iconFont

                    font.pixelSize: Core.Theme.iconSizeSmall

                    color: replyInput.text.length > 0 ? Core.Theme.accent : Core.Theme.foregroundFaint
                }

                MouseArea {
                    id: sendMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor

                    onClicked: Services.NotificationServer.sendReply(root.notification, replyInput.text)
                }
            }
        }
    }
}
