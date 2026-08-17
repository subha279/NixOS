import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import "../core" as Core
import "../services" as Services

// ================================================================
// Aurora Notifications — transient toast overlay
//
// Design goals:
//   • reliable dynamic sizing
//   • no animated Layout attached properties
//   • compositor-friendly transforms
//   • smooth 180 Hz-style motion
//   • independent toast lifetime
//   • critical notifications remain until dismissed
// ================================================================

PanelWindow {
    id: root

    anchors.top: true
    anchors.right: true

    margins.top: 48
    margins.right: 14

    readonly property var toasts:
        Services.NotificationServer.toasts

    readonly property int toastWidth: 356
    readonly property int toastSpacing: 8
    readonly property int maxHeight: 640

    // Calculate the actual content height ourselves.
    //
    // This avoids relying on ColumnLayout/Reapeater implicitHeight,
    // which can collapse the PanelWindow to almost zero height.
    readonly property int contentHeight: {
        if (!root.toasts || root.toasts.length === 0)
            return 1

        var total = 0

        for (var i = 0; i < root.toasts.length; i++) {
            var n = root.toasts[i]

            // Conservative height used by the delegates.
            // The actual card may be slightly taller depending
            // on the notification body.
            total += 96

            if (i < root.toasts.length - 1)
                total += root.toastSpacing
        }

        return Math.min(total, root.maxHeight)
    }

    implicitWidth: root.toastWidth + 14
    implicitHeight: root.contentHeight

    color: "transparent"

    WlrLayershell.namespace: "aurora-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    exclusionMode: ExclusionMode.Ignore

    visible:
        root.toasts.length > 0
        && !Core.PopupManager.dnd
        && !Core.PopupManager.isOpen("notifications")

    // Only the actual toast stack receives input.
    mask: Region {
        item: stack
    }

    Item {
        id: stack

        anchors.top: parent.top
        anchors.right: parent.right

        width: root.toastWidth
        height: Math.min(
            root.contentHeight,
            root.maxHeight
        )

        Repeater {
            id: repeater

            model: root.toasts

            delegate: Item {
                id: wrapper

                required property var modelData

                readonly property bool critical:
                    Services.NotificationServer.isCritical(
                        wrapper.modelData
                    )

                readonly property int lifetime:
                    Services.NotificationServer.lifetimeFor(
                        wrapper.modelData
                    )

                readonly property real cardHeight:
                    Math.max(
                        72,
                        card.implicitHeight
                    )

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

                width: root.toastWidth

                // Every delegate is positioned explicitly.
                // This prevents Layout animations from fighting
                // with the compositor.
                y: {
                    var result = 0

                    for (var i = 0; i < index; i++) {
                        result += 96 + root.toastSpacing
                    }

                    return result
                }

                height: Math.max(
                    0,
                    wrapper.cardHeight * wrapper.collapse
                )

                opacity:
                    1.0 - (wrapper.slide * 0.35)

                clip: true

                Component.onCompleted: {
                    enterAnim.start()
                }

                // ------------------------------------------------
                // Toast lifecycle
                // ------------------------------------------------

                function hide() {
                    if (wrapper.dismissing)
                        return

                    wrapper.dismissing = true
                    exitAnim.start()
                }

                function dismissFully() {
                    if (wrapper.dismissing)
                        return

                    wrapper.dismissing = true

                    Services.NotificationServer.dismiss(
                        wrapper.modelData
                    )
                }

                function activate() {
                    const n = wrapper.modelData

                    try {
                        const acts = n.actions

                        if (acts && acts.length > 0) {
                            for (var i = 0; i < acts.length; i++) {
                                var actionId = ""

                                try {
                                    if (acts[i].identifier !== undefined)
                                        actionId =
                                            String(
                                                acts[i].identifier
                                            )
                                } catch (e) {
                                    actionId = ""
                                }

                                if (actionId === "default") {
                                    acts[i].invoke()
                                    break
                                }
                            }
                        }
                    } catch (e) {
                        // No usable action.
                    }

                    wrapper.dismissFully()
                }

                // ------------------------------------------------
                // Entrance
                // ------------------------------------------------

                NumberAnimation {
                    id: enterAnim

                    target: wrapper
                    property: "slide"

                    from: 1.0
                    to: 0.0

                    duration: 220

                    easing.type: Easing.OutCubic
                }

                // ------------------------------------------------
                // Exit
                // ------------------------------------------------

                SequentialAnimation {
                    id: exitAnim

                    ParallelAnimation {

                        NumberAnimation {
                            target: wrapper
                            property: "slide"

                            to: 1.0

                            duration: 190

                            easing.type: Easing.InCubic
                        }

                        NumberAnimation {
                            target: wrapper
                            property: "collapse"

                            to: 0.0

                            duration: 210

                            easing.type: Easing.InCubic
                        }

                        NumberAnimation {
                            target: wrapper
                            property: "opacity"

                            to: 0.0

                            duration: 160

                            easing.type: Easing.InCubic
                        }
                    }

                    ScriptAction {
                        script:
                            Services.NotificationServer.hideToast(
                                wrapper.modelData
                            )
                    }
                }

                // ------------------------------------------------
                // Lifetime
                // ------------------------------------------------

                Timer {
                    id: tick

                    interval: 50
                    repeat: true

                    running:
                        wrapper.lifetime > 0
                        && !cardHover.hovered
                        && !wrapper.dismissing

                    onTriggered: {
                        wrapper.remaining -= interval

                        if (wrapper.remaining <= 0)
                            wrapper.hide()
                    }
                }

                // ------------------------------------------------
                // Card
                // ------------------------------------------------

                Rectangle {
                    id: card

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    implicitHeight:
                        Math.max(
                            72,
                            contentRow.implicitHeight + 24
                        )

                    height: implicitHeight

                    radius: 16

                    clip: true

                    color:
                        Core.Theme.backgroundSolid

                    border.width:
                        Core.Theme.borderWidth

                    border.color:
                        Core.Theme.borderActive

                    transform: Translate {
                        x: wrapper.slide * 44
                    }

                    // ------------------------------------------------
                    // Hover
                    // ------------------------------------------------

                    HoverHandler {
                        id: cardHover

                        onHoveredChanged: {
                            if (cardHover.hovered)
                                wrapper.remaining =
                                    wrapper.lifetime
                        }
                    }

                    // ------------------------------------------------
                    // Mouse interaction
                    // ------------------------------------------------

                    MouseArea {
                        anchors.fill: parent

                        acceptedButtons:
                            Qt.LeftButton
                            | Qt.RightButton
                            | Qt.MiddleButton

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: function(mouse) {

                            if (mouse.button === Qt.RightButton) {
                                wrapper.dismissFully()
                                return
                            }

                            if (mouse.button === Qt.MiddleButton) {
                                Services.NotificationServer.clearToasts()
                                return
                            }

                            wrapper.activate()
                        }
                    }

                    // ------------------------------------------------
                    // Urgency stripe
                    // ------------------------------------------------

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        width: 3

                        color:
                            wrapper.critical
                                ? Core.Theme.danger
                                : Core.Theme.accent

                        opacity:
                            wrapper.critical
                                ? 1.0
                                : 0.55
                    }

                    // ------------------------------------------------
                    // Content
                    // ------------------------------------------------

                    RowLayout {
                        id: contentRow

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top

                        anchors.leftMargin: 14
                        anchors.rightMargin: 12
                        anchors.topMargin: 12

                        spacing: 11

                        // --------------------------------------------
                        // Application icon
                        // --------------------------------------------
                        Rectangle {
    Layout.alignment: Qt.AlignTop

    Layout.preferredWidth: 38
    Layout.preferredHeight: 38

    radius: 11

    color: wrapper.critical
        ? "#1fe58fa0"
        : Core.Theme.surface

    // ------------------------------------------------------------
    // Resolve the notification icon.
    //
    // Different applications use different notification fields:
    //
    //   image
    //   imagePath
    //   appIcon
    //
    // We try them in that order.
    // ------------------------------------------------------------

    readonly property string resolvedIcon: {
        const n = wrapper.modelData

        // 1. Explicit notification image
        try {
            if (
                n.image !== undefined
                && n.image !== null
                && String(n.image) !== ""
            ) {
                return String(n.image)
            }
        } catch (e) {}

        // 2. Explicit image path
        try {
            if (
                n.imagePath !== undefined
                && n.imagePath !== null
                && String(n.imagePath) !== ""
            ) {
                return String(n.imagePath)
            }
        } catch (e) {}

        // 3. Desktop/application icon
        try {
            if (
                n.appIcon !== undefined
                && n.appIcon !== null
                && String(n.appIcon) !== ""
            ) {
                return Quickshell.iconPath(
                    String(n.appIcon),
                    true
                )
            }
        } catch (e) {}

        return ""
    }

    Image {
        id: notificationIcon

        anchors.centerIn: parent

        width: 26
        height: 26

        source: parent.resolvedIcon

        visible:
            status === Image.Ready
            && source !== ""

        asynchronous: true
        cache: true
        smooth: true

        fillMode:
            Image.PreserveAspectFit

        mipmap: true
    }

    // ------------------------------------------------------------
    // Nerd Font fallback
    // ------------------------------------------------------------

    Text {
        anchors.centerIn: parent

        visible:
            !notificationIcon.visible

        text: "\udb80\udc7f"

        font.family:
            Core.Theme.fontFamily

        font.pixelSize: 19

        color:
            wrapper.critical
                ? Core.Theme.danger
                : Core.Theme.accent

        renderType:
            Text.NativeRendering
    }
}

                        // --------------------------------------------
                        // Text
                        // --------------------------------------------

                        ColumnLayout {
                            Layout.fillWidth: true

                            spacing: 3

                            Text {
                                Layout.fillWidth: true

                                text: {
                                    const n =
                                        wrapper.modelData

                                    try {
                                        if (
                                            n.appName
                                            && n.appName !== ""
                                        )
                                            return n.appName
                                    } catch (e) {}

                                    try {
                                        if (
                                            n.desktopEntry
                                            && n.desktopEntry !== ""
                                        )
                                            return n.desktopEntry
                                    } catch (e) {}

                                    return "Notification"
                                }

                                font.family:
                                    Core.Theme.fontFamily

                                font.pixelSize:
                                    Core.Theme.fontSizeSmall

                                font.weight:
                                    Font.DemiBold

                                color:
                                    Core.Theme.text

                                elide:
                                    Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true

                                text: {
                                    const n =
                                        wrapper.modelData

                                    try {
                                        return n.summary || ""
                                    } catch (e) {
                                        return ""
                                    }
                                }

                                font.family:
                                    Core.Theme.fontFamily

                                font.pixelSize:
                                    Core.Theme.fontSizeBase

                                font.weight:
                                    Font.Medium

                                color:
                                    Core.Theme.text

                                elide:
                                    Text.ElideRight

                                maximumLineCount: 2
                            }

                            Text {
                                Layout.fillWidth: true

                                visible:
                                    text !== ""

                                text: {
                                    const n =
                                        wrapper.modelData

                                    try {
                                        return n.body || ""
                                    } catch (e) {
                                        return ""
                                    }
                                }

                                font.family:
                                    Core.Theme.fontFamily

                                font.pixelSize:
                                    Core.Theme.fontSizeSmall

                                color:
                                    Core.Theme.textMuted

                                wrapMode:
                                    Text.Wrap

                                maximumLineCount: 3

                                elide:
                                    Text.ElideRight
                            }
                        }

                        // --------------------------------------------
                        // Close
                        // --------------------------------------------

                        Rectangle {
                            Layout.alignment:
                                Qt.AlignTop

                            width: 28
                            height: 28

                            radius: 9

                            color:
                                closeMouse.containsMouse
                                    ? Core.Theme.surfaceHover
                                    : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: "\udb80\udc6f"

                                font.family:
                                    Core.Theme.fontFamily

                                font.pixelSize: 15

                                color:
                                    Core.Theme.textMuted
                            }

                            MouseArea {
                                id: closeMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                onClicked: {
                                    wrapper.hide()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
