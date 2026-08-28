import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import "../components" as Components
import "../core" as Core
import "../services" as Services

// Aurora Notifications — transient toast overlay

PanelWindow {
    id: root

    anchors.top: true
    anchors.right: true

    margins.top: 40
    margins.right: 6

    readonly property var toasts: Services.NotificationServer.toasts

    readonly property int toastWidth: 356

    readonly property int toastGutter: 8

    readonly property int toastSpacing: 0

    // Headroom for maxVisible cards at their tallest. A card carrying action
    // buttons and an open reply field is roughly twice the height of a bare one,
    // and at 640 the fourth card in a full stack was clipped off the bottom.
    //
    // Costs nothing: the window is transparent and its input is masked to the
    // card stack, so the unused area is neither drawn nor clickable.
    readonly property int maxHeight: 900

    implicitWidth: root.toastWidth + root.toastGutter * 2 + 14

    implicitHeight: root.maxHeight

    color: "transparent"

    WlrLayershell.namespace: "aurora-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    // A toast must never steal keyboard focus from whatever you are typing in.
    //
    // The one exception is a reply field the user explicitly opened, and even then
    // it is OnDemand rather than Exclusive: focus moves when the field is clicked,
    // never because a notification arrived.
    WlrLayershell.keyboardFocus: Services.NotificationServer.replyTarget !== null ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    exclusionMode: ExclusionMode.Ignore

    // Deliberately not gated on do-not-disturb. Suppression happens in
    // NotificationServer.showToast, which lets critical alerts through, and
    // hiding the whole layer here would override that and silence them.
    visible: root.toasts.length > 0 && !Core.PopupManager.isOpen("notifications")

    // Only the actual toast stack receives input.
    mask: Region {
        item: column
    }

    Column {
        id: column

        anchors.top: parent.top
        anchors.right: parent.right

        width: root.toastWidth + root.toastGutter * 2

        spacing: root.toastSpacing

        move: Transition {
            NumberAnimation {
                property: "y"

                duration: 180

                easing.type: Easing.OutQuint
            }
        }

        Repeater {
            id: repeater

            model: root.toasts

            delegate: Item {
                id: wrapper

                required property var modelData

                readonly property bool critical: Services.NotificationServer.isCritical(wrapper.modelData)

                readonly property int lifetime: Services.NotificationServer.lifetimeFor(wrapper.modelData)

                readonly property real cardHeight: Math.max(72, card.implicitHeight)

                readonly property bool replying: Services.NotificationServer.isReplying(wrapper.modelData)

                property real remaining: wrapper.lifetime

                property bool dismissing: false

                // Transform-driven animation.
                //
                // 0 = visible
                // 1 = completely offscreen
                property real slide: 1.0

                // 1 = normal height
                // 0 = collapsed
                property real collapse: 1.0

                // Animation-driven only. Binding opacity to slide while the exit
                // animation also wrote to it broke the binding mid-flight.
                property real fade: 0.0

                width: root.toastWidth + root.toastGutter * 2

                // Positioned by the parent Column, which measures every card rather than assuming a fixed height.
                height: Math.max(0, (wrapper.cardHeight + root.toastGutter * 2) * wrapper.collapse)

                opacity: wrapper.fade

                clip: true

                Component.onCompleted: {
                    enterAnim.start();
                }

                // Toast lifecycle

                function hide() {
                    if (wrapper.dismissing)
                        return;
                    wrapper.dismissing = true;
                    exitAnim.start();
                }

                function dismissFully() {
                    if (wrapper.dismissing)
                        return;
                    wrapper.dismissing = true;

                    Services.NotificationServer.dismiss(wrapper.modelData);
                }

                // Clicking the card body triggers the sender's "default" action,
                // which is the convention for "open the thing this is about".
                //
                // If there is no default action the card is only dismissed. It is
                // NOT destroyed: any named actions it carries are rendered as
                // buttons below, and throwing the entry away would take those with
                // it before they could be used from the centre.
                function activate() {
                    const n = wrapper.modelData;

                    var invoked = false;

                    try {
                        const acts = n.actions;

                        if (acts && acts.length > 0) {
                            for (var i = 0; i < acts.length; i++) {
                                var actionId = "";

                                try {
                                    if (acts[i].identifier !== undefined)
                                        actionId = String(acts[i].identifier);
                                } catch (e) {
                                    actionId = "";
                                }

                                if (actionId === "default") {
                                    // invokeAction handles closing; a second
                                    // dismiss here would hit a destroyed object.
                                    Services.NotificationServer.invokeAction(n, acts[i]);
                                    invoked = true;
                                    break;
                                }
                            }
                        }
                    } catch (e) {
                        // No usable action.
                    }

                    if (!invoked)
                        wrapper.hide();
                }

                // Entrance

                ParallelAnimation {
                    id: enterAnim

                    NumberAnimation {
                        target: wrapper
                        property: "slide"

                        from: 1.0
                        to: 0.0

                        duration: 170

                        easing.type: Easing.OutQuint
                    }

                    NumberAnimation {
                        target: wrapper
                        property: "fade"

                        from: 0.0
                        to: 1.0

                        duration: 140

                        easing.type: Easing.OutQuint
                    }
                }

                // Exit

                SequentialAnimation {
                    id: exitAnim

                    ParallelAnimation {

                        NumberAnimation {
                            target: wrapper
                            property: "slide"

                            to: 1.0

                            duration: 150

                            easing.type: Easing.InQuint
                        }

                        NumberAnimation {
                            target: wrapper
                            property: "collapse"

                            to: 0.0

                            duration: 170

                            easing.type: Easing.InQuint
                        }

                        NumberAnimation {
                            target: wrapper
                            property: "fade"

                            to: 0.0

                            duration: 130

                            easing.type: Easing.InQuint
                        }
                    }

                    ScriptAction {
                        // expireToast, not hideToast: a notification the sender
                        // marked transient is discarded here instead of being
                        // filed in the centre, which is what transient means.
                        script: Services.NotificationServer.expireToast(wrapper.modelData)
                    }
                }

                Timer {
                    id: tick

                    interval: 250
                    repeat: true

                    // Also paused while a reply is being typed into this card, and
                    // while the notification centre is up. In the latter case the
                    // whole overlay is hidden, so a running timer would burn the
                    // card's lifetime somewhere the user cannot see it and it would
                    // be gone by the time they closed the panel.
                    running: wrapper.lifetime > 0 && !cardHover.hovered && !wrapper.dismissing && !wrapper.replying && !Core.PopupManager.isOpen("notifications")

                    onTriggered: {
                        wrapper.remaining -= interval;

                        if (wrapper.remaining <= 0)
                            wrapper.hide();
                    }
                }

                Item {
                    anchors.fill: card

                    z: -1

                    transform: Translate {
                        x: wrapper.slide * 44
                    }

                    Components.Elevation {
                        anchors.fill: parent

                        radius: card.radius

                        level: 0.92
                    }
                }

                // Card

                Rectangle {
                    id: card

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    anchors.leftMargin: root.toastGutter
                    anchors.rightMargin: root.toastGutter
                    anchors.topMargin: root.toastGutter

                    implicitHeight: Math.max(72, contentRow.implicitHeight + 24)

                    height: implicitHeight

                    radius: 16

                    clip: true

                    color: "transparent"

                    border.width: Core.Theme.borderWidth

                    // Critical is the only state that gets colour, and only as a border.
                    border.color: wrapper.critical ? Core.Theme.danger : Core.Theme.borderActive

                    transform: Translate {
                        x: wrapper.slide * 44
                    }

                    Components.Glass {
                        anchors.fill: parent

                        radius: parent.radius
                    }

                    // Hover

                    HoverHandler {
                        id: cardHover

                        onHoveredChanged: {
                            if (cardHover.hovered)
                                wrapper.remaining = wrapper.lifetime;
                        }
                    }

                    // Mouse interaction

                    MouseArea {
                        anchors.fill: parent

                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                        cursorShape: Qt.PointingHandCursor

                        onClicked: function (mouse) {
                            if (mouse.button === Qt.RightButton) {
                                wrapper.dismissFully();
                                return;
                            }

                            if (mouse.button === Qt.MiddleButton) {
                                Services.NotificationServer.clearToasts();
                                return;
                            }

                            wrapper.activate();
                        }
                    }

                    // Content

                    RowLayout {
                        id: contentRow

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top

                        anchors.leftMargin: 14
                        anchors.rightMargin: 12
                        anchors.topMargin: 12

                        spacing: 11

                        // Application icon
                        Rectangle {
                            Layout.alignment: Qt.AlignTop

                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 38

                            radius: 11

                            color: Core.Theme.surfaceGlass

                            // Shared with the notification centre so both surfaces
                            // resolve icons identically.
                            //
                            // This used to also check `n.imagePath`, which is not a
                            // property Quickshell exposes, so that branch could
                            // never fire. It was not needed: `image` already
                            // resolves image-data, image_data, icon_data AND
                            // image-path/image_path into one value.
                            readonly property string resolvedIcon: Services.NotificationServer.iconFor(wrapper.modelData)

                            Image {
                                id: notificationIcon

                                anchors.centerIn: parent

                                width: 26
                                height: 26

                                source: parent.resolvedIcon

                                visible: status === Image.Ready && source !== ""

                                asynchronous: true
                                cache: true
                                smooth: true

                                fillMode: Image.PreserveAspectFit

                                mipmap: true
                            }

                            // Nerd Font fallback

                            // Nerd Font fallback, picked from the app name.
                            //
                            // Was a hardcoded F007F, which is the 60%-battery
                            // glyph rather than a bell. Icons.forApp already maps
                            // senders to a sensible glyph, so a mail client gets an
                            // envelope instead of every app getting the same mark.
                            Text {
                                anchors.centerIn: parent

                                visible: !notificationIcon.visible

                                text: Core.Icons.forApp(Services.NotificationServer.appLabel(wrapper.modelData))

                                font.family: Core.Theme.iconFont

                                font.pixelSize: Core.Theme.iconSizeMedium

                                color: Core.Theme.textMuted

                                renderType: Text.NativeRendering
                            }
                        }

                        // Text

                        ColumnLayout {
                            Layout.fillWidth: true

                            spacing: 3

                            Text {
                                Layout.fillWidth: true

                                text: Services.NotificationServer.appLabel(wrapper.modelData)

                                font.family: Core.Theme.fontFamily

                                font.pixelSize: Core.Theme.fontSizeSmall

                                font.weight: Font.DemiBold

                                color: Core.Theme.text

                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true

                                text: {
                                    const n = wrapper.modelData;

                                    try {
                                        return n.summary || "";
                                    } catch (e) {
                                        return "";
                                    }
                                }

                                font.family: Core.Theme.fontFamily

                                font.pixelSize: Core.Theme.fontSize

                                font.weight: Font.Medium

                                color: Core.Theme.text

                                elide: Text.ElideRight

                                maximumLineCount: 2
                            }

                            Text {
                                id: bodyText

                                Layout.fillWidth: true

                                visible: text !== ""

                                text: {
                                    const n = wrapper.modelData;

                                    try {
                                        return n.body || "";
                                    } catch (e) {
                                        return "";
                                    }
                                }

                                font.family: Core.Theme.fontFamily

                                font.pixelSize: Core.Theme.fontSizeSmall

                                color: Core.Theme.textMuted

                                wrapMode: Text.Wrap

                                maximumLineCount: 3

                                elide: Text.ElideRight

                                // The server advertises body-markup and
                                // body-hyperlinks, so senders are entitled to send
                                // <b>, <i> and <a href>. StyledText renders exactly
                                // the subset the spec allows; RichText would also
                                // accept remote <img> and is not worth the exposure.
                                textFormat: Text.StyledText

                                linkColor: Core.Theme.accent

                                onLinkActivated: function (link) {
                                    Quickshell.execDetached(["xdg-open", link]);
                                }
                            }

                            // Named actions and the reply field.
                            //
                            // Previously the toast rendered none of these and only
                            // the "default" action was reachable, by clicking the
                            // card. Anything else had to be found in the centre.
                            Components.NotificationActions {
                                Layout.fillWidth: true

                                Layout.topMargin: visible ? 4 : 0

                                notification: wrapper.modelData
                            }
                        }

                        // Close

                        Rectangle {
                            Layout.alignment: Qt.AlignTop

                            width: 28
                            height: 28

                            radius: 9

                            color: closeMouse.containsMouse ? Core.Theme.surfaceHover : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: "\udb80\udc6f"

                                font.family: Core.Theme.iconFont

                                font.pixelSize: Core.Theme.iconSizeSmall

                                color: Core.Theme.textMuted
                            }

                            MouseArea {
                                id: closeMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                onClicked: {
                                    wrapper.hide();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
