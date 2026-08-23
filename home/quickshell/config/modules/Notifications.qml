import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import "../core" as Core
import "../services" as Services

// Aurora Notifications — transient toast overlay

PanelWindow {
    id: root

    anchors.top: true
    anchors.right: true

    // Reduced by exactly toastGutter, because the gutter added below carries
    // the shadow. The visible card therefore stays in the same place as before.
    margins.top: 40
    margins.right: 6

    readonly property var toasts: Services.NotificationServer.toasts

    readonly property int toastWidth: 356

    // Transparent room around each card for its drop shadow. Both the wrapper
    // and the card clip, so the shadow cannot be drawn past their edges.
    readonly property int toastGutter: 8

    // Adjacent gutters already supply the visual gap between cards.
    readonly property int toastSpacing: 0
    readonly property int maxHeight: 640

    implicitWidth: root.toastWidth + root.toastGutter * 2 + 14

    // Fixed on purpose. Binding this to the column made the layer-shell surface
    // resize on every animation frame, which is what caused the tearing and
    // jumping. The mask below already limits input to the actual cards.
    implicitHeight: root.maxHeight

    color: "transparent"

    WlrLayershell.namespace: "aurora-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    // A toast must never steal keyboard focus from whatever you are typing in.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    exclusionMode: ExclusionMode.Ignore

    visible: root.toasts.length > 0 && !Core.PopupManager.dnd && !Core.PopupManager.isOpen("notifications")

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

        // Cards glide when the stack reflows instead of snapping to a new
        // position, which is what looked broken when two arrived at once.
        //
        // Positioners support add/move/populate only. "displaced" belongs to
        // ListView/GridView and is rejected here; move covers the reflow.
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

                function activate() {
                    const n = wrapper.modelData;

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
                                    acts[i].invoke();
                                    break;
                                }
                            }
                        }
                    } catch (e) {
                        // No usable action.
                    }

                    wrapper.dismissFully();
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
                        script: Services.NotificationServer.hideToast(wrapper.modelData)
                    }
                }

                // Lifetime

                Timer {
                    id: tick

                    interval: 100
                    repeat: true

                    running: wrapper.lifetime > 0 && !cardHover.hovered && !wrapper.dismissing

                    onTriggered: {
                        wrapper.remaining -= interval;

                        if (wrapper.remaining <= 0)
                            wrapper.hide();
                    }
                }

                // Floating shadow
                //
                // A sibling of the card, because the card clips its own
                // children. It slides with the card so the shadow never
                // detaches during the exit animation.

                Item {
                    anchors.fill: card

                    z: -1

                    transform: Translate {
                        x: wrapper.slide * 44
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -root.toastGutter

                        radius: card.radius + root.toastGutter

                        color: "#000000"

                        opacity: Core.Theme.shellShadowOpacity * 0.16

                        antialiasing: true
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4

                        radius: card.radius + 4

                        color: "#000000"

                        opacity: Core.Theme.shellShadowOpacity * 0.30

                        antialiasing: true
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -2

                        radius: card.radius + 2

                        color: "#000000"

                        opacity: Core.Theme.shellShadowOpacity * 0.55

                        antialiasing: true
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

                    color: Core.Theme.backgroundSolid

                    border.width: Core.Theme.borderWidth

                    // Critical is the only state that gets colour, and only as a border.
                    border.color: wrapper.critical ? Core.Theme.danger : Core.Theme.borderActive

                    transform: Translate {
                        x: wrapper.slide * 44
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

                            color: Core.Theme.surface

                            // Resolve the notification icon.

                            readonly property string resolvedIcon: {
                                const n = wrapper.modelData;

                                // 1. Explicit notification image
                                try {
                                    if (n.image !== undefined && n.image !== null && String(n.image) !== "") {
                                        return String(n.image);
                                    }
                                } catch (e) {}

                                // 2. Explicit image path
                                try {
                                    if (n.imagePath !== undefined && n.imagePath !== null && String(n.imagePath) !== "") {
                                        return String(n.imagePath);
                                    }
                                } catch (e) {}

                                // 3. Desktop/application icon
                                try {
                                    if (n.appIcon !== undefined && n.appIcon !== null && String(n.appIcon) !== "") {
                                        return Quickshell.iconPath(String(n.appIcon), true);
                                    }
                                } catch (e) {}

                                return "";
                            }

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

                            Text {
                                anchors.centerIn: parent

                                visible: !notificationIcon.visible

                                text: "\udb80\udc7f"

                                font.family: Core.Theme.fontFamily

                                font.pixelSize: 19

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

                                text: {
                                    const n = wrapper.modelData;

                                    try {
                                        if (n.appName && n.appName !== "")
                                            return n.appName;
                                    } catch (e) {}

                                    try {
                                        if (n.desktopEntry && n.desktopEntry !== "")
                                            return n.desktopEntry;
                                    } catch (e) {}

                                    return "Notification";
                                }

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

                                font.pixelSize: Core.Theme.fontSizeBase

                                font.weight: Font.Medium

                                color: Core.Theme.text

                                elide: Text.ElideRight

                                maximumLineCount: 2
                            }

                            Text {
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

                                font.family: Core.Theme.fontFamily

                                font.pixelSize: 15

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
