import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import "../core" as Core
import "../services" as Services

// ================================================================
// Notifications (toast overlay)
// ----------------------------------------------------------------
// Reads Services.NotificationServer.toasts, NOT the persistent
// history. Each card owns its own countdown and removes itself.
//
// Interaction map:
//   left click    invoke the default action, then dismiss
//   click the x   hide the toast, keep it in the panel
//   right click   dismiss entirely (also clears it from the panel)
//   middle click  hide every toast on screen
//   hover         pause and reset the countdown
// ================================================================

PanelWindow {
    id: root

    anchors.top: true
    anchors.right: true

    margins.top: 48
    margins.right: 14

    readonly property var toasts:
        Services.NotificationServer.toasts

    implicitWidth: 370

    implicitHeight: Math.max(
        1,
        Math.min(stack.implicitHeight, 640)
    )

    color: "transparent"

    WlrLayershell.namespace: "aurora-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    exclusionMode: ExclusionMode.Ignore

    visible: root.toasts.length > 0
            && !Core.PopupManager.dnd
            && !Core.PopupManager.isOpen("notifications")

    // Only the cards themselves may receive clicks. Without this
    // the full 370x640 window would swallow input over the empty
    // area beneath the stack.
    mask: Region { item: stack }

    ColumnLayout {
        id: stack

        anchors.right: parent.right
        anchors.top: parent.top

        width: 356

        spacing: 8

        Repeater {
            model: root.toasts

            delegate: Item {
                id: wrapper

                required property var modelData

                readonly property bool critical:
                    Services.NotificationServer.isCritical(wrapper.modelData)

                readonly property int lifetime:
                    Services.NotificationServer.lifetimeFor(wrapper.modelData)

                property real remaining: wrapper.lifetime

                property bool dismissing: false

                // Entrance and exit are driven by two plain reals
                // that the layout binds to. Animating Layout.*
                // attached properties directly is not reliable.
                property real slide: 1.0     // 1 = parked offscreen right
                property real collapse: 1.0  // 1 = full height

                readonly property real cardHeight: card.implicitHeight

                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 356

                Layout.preferredHeight: Math.max(
                    0,
                    Math.round(wrapper.cardHeight * wrapper.collapse)
                )

                clip: true

                opacity: 1.0 - wrapper.slide

                Component.onCompleted: enterAnim.start()

                // Timeout / x button: leaves the panel entry alone.
                function hide() {
                    if (wrapper.dismissing)
                        return

                    wrapper.dismissing = true
                    exitAnim.start()
                }

                // Right click: removes the panel entry too.
                function dismissFully() {
                    if (wrapper.dismissing)
                        return

                    wrapper.dismissing = true
                    Services.NotificationServer.dismiss(wrapper.modelData)
                }

                function activate() {
                    const n = wrapper.modelData

                    try {
                        const acts = n.actions

                        if (acts && acts.length > 0) {
                            for (var i = 0; i < acts.length; i++) {
                                var id = ""

                                try {
                                    if (acts[i].identifier !== undefined)
                                        id = String(acts[i].identifier)
                                } catch (e) {
                                    id = ""
                                }

                                if (id === "default") {
                                    acts[i].invoke()
                                    break
                                }
                            }
                        }
                    } catch (e) {
                        // No actions exposed; dismissing is enough.
                    }

                    wrapper.dismissFully()
                }

                NumberAnimation {
                    id: enterAnim

                    target: wrapper
                    property: "slide"

                    to: 0

                    duration: 180
                    easing.type: Easing.OutCubic
                }

                SequentialAnimation {
                    id: exitAnim

                    NumberAnimation {
                        target: wrapper
                        property: "slide"

                        to: 1

                        duration: 190
                        easing.type: Easing.InCubic
                    }

                    NumberAnimation {
                        target: wrapper
                        property: "collapse"

                        to: 0

                        duration: 170
                        easing.type: Easing.InCubic
                    }

                    ScriptAction {
                        script: Services.NotificationServer.hideToast(
                            wrapper.modelData
                        )
                    }
                }

                Timer {
                    id: tick

                    interval: 50
                    repeat: true

                    running: wrapper.lifetime > 0
                            && !cardHover.hovered
                            && !wrapper.dismissing

                    onTriggered: {
                        wrapper.remaining -= tick.interval

                        if (wrapper.remaining <= 0)
                            wrapper.hide()
                    }
                }

                Rectangle {
                    id: card

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    implicitHeight: Math.max(
                        72,
                        contentRow.implicitHeight + 24
                    )

                    height: card.implicitHeight

                    radius: 16

                    clip: true

                    color: Core.Theme.backgroundSolid

                    border.width: 1

                    border.color: wrapper.critical
                        ? Core.Theme.danger
                        : Core.Theme.border

                    transform: Translate {
                        x: wrapper.slide * 44
                    }

                    HoverHandler {
                        id: cardHover

                        // Re-arm the countdown so the card does not
                        // vanish the instant the pointer leaves.
                        onHoveredChanged: {
                            if (cardHover.hovered)
                                wrapper.remaining = wrapper.lifetime
                        }
                    }

                    // Declared before the content so the action and
                    // close buttons sit above it and win the click.
                    MouseArea {
                        anchors.fill: parent

                        acceptedButtons: Qt.LeftButton
                                | Qt.RightButton
                                | Qt.MiddleButton

                        cursorShape: Qt.PointingHandCursor

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

                    // Urgency stripe down the leading edge.
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        width: 3

                        color: wrapper.critical
                            ? Core.Theme.danger
                            : Core.Theme.accent

                        opacity: wrapper.critical ? 1.0 : 0.55
                    }

                    RowLayout {
                        id: contentRow

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top

                        anchors.leftMargin: 14
                        anchors.rightMargin: 12
                        anchors.topMargin: 12

                        spacing: 11

                        // ----------------------------------------
                        // Icon: real app icon when we can get one,
                        // glyph fallback when we cannot.
                        // ----------------------------------------
                        Rectangle {
                            Layout.alignment: Qt.AlignTop

                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 38

                            radius: 11

                            color: wrapper.critical
                                ? "#1fe58fa0"
                                : Core.Theme.surface

                            // Prefer the image the notification
                            // carries, then the themed icon name it
                            // advertises. Both are frequently absent.
                            readonly property string imageSource: {
                                const n = wrapper.modelData

                                try {
                                    if (n.image !== undefined
                                            && n.image !== null
                                            && String(n.image) !== "")
                                        return String(n.image)
                                } catch (e) {
                                    // fall through
                                }

                                try {
                                    if (n.appIcon !== undefined
                                            && n.appIcon !== null
                                            && String(n.appIcon) !== "")
                                        return Quickshell.iconPath(
                                            String(n.appIcon),
                                            true
                                        )
                                } catch (e) {
                                    // fall through
                                }

                                return ""
                            }

                            readonly property string appName: {
                                try {
                                    if (wrapper.modelData.appName !== undefined
                                            && wrapper.modelData.appName !== null)
                                        return String(wrapper.modelData.appName)
                                } catch (e) {
                                    return ""
                                }

                                return ""
                            }

                            Image {
                                id: appImage

                                anchors.centerIn: parent

                                width: 24
                                height: 24

                                source: parent.imageSource

                                visible: appImage.status === Image.Ready

                                fillMode: Image.PreserveAspectFit

                                asynchronous: true

                                smooth: true
                            }

                            Text {
                                anchors.centerIn: parent

                                visible: !appImage.visible

                                text: wrapper.critical
                                    ? Core.Icons.alert
                                    : Core.Icons.forApp(parent.appName)

                                font.family: Core.Theme.fontFamily
                                font.pixelSize: 19

                                color: wrapper.critical
                                    ? Core.Theme.danger
                                    : Core.Theme.accent
                            }
                        }

                        // ----------------------------------------
                        // Text block
                        // ----------------------------------------
                        ColumnLayout {
                            Layout.fillWidth: true

                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true

                                spacing: 6

                                Text {
                                    Layout.fillWidth: true

                                    text: {
                                        try {
                                            const a = wrapper.modelData.appName

                                            if (a !== undefined && a !== null
                                                    && String(a) !== "")
                                                return String(a)
                                        } catch (e) {
                                            return "Notification"
                                        }

                                        return "Notification"
                                    }

                                    font.family: Core.Theme.fontFamily
                                    font.pixelSize: Core.Theme.fontSizeSmall
                                    font.weight: Font.DemiBold

                                    color: wrapper.critical
                                        ? Core.Theme.danger
                                        : Core.Theme.foregroundFaint

                                    elide: Text.ElideRight
                                }

                                // Close button, revealed on hover.
                                Rectangle {
                                    Layout.preferredWidth: 18
                                    Layout.preferredHeight: 18

                                    radius: 9

                                    color: closeArea.containsMouse
                                        ? Core.Theme.surfaceHover
                                        : "transparent"

                                    opacity: cardHover.hovered ? 1.0 : 0.0

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 140
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent

                                        text: Core.Icons.close

                                        font.family: Core.Theme.fontFamily
                                        font.pixelSize: 11

                                        color: Core.Theme.foregroundMuted
                                    }

                                    MouseArea {
                                        id: closeArea

                                        anchors.fill: parent

                                        hoverEnabled: true

                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: wrapper.hide()
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true

                                text: {
                                    try {
                                        const s = wrapper.modelData.summary

                                        if (s !== undefined && s !== null)
                                            return String(s)
                                    } catch (e) {
                                        return ""
                                    }

                                    return ""
                                }

                                font.family: Core.Theme.fontFamily
                                font.pixelSize: Core.Theme.fontSizeLarge
                                font.weight: Font.DemiBold

                                color: Core.Theme.foreground

                                elide: Text.ElideRight

                                maximumLineCount: 2

                                wrapMode: Text.Wrap
                            }

                            Text {
                                id: bodyText

                                Layout.fillWidth: true

                                text: {
                                    try {
                                        const b = wrapper.modelData.body

                                        if (b !== undefined && b !== null)
                                            return String(b)
                                    } catch (e) {
                                        return ""
                                    }

                                    return ""
                                }

                                visible: bodyText.text !== ""

                                font.family: Core.Theme.fontFamily
                                font.pixelSize: Core.Theme.fontSize

                                color: Core.Theme.foregroundMuted

                                textFormat: Text.StyledText

                                maximumLineCount: 3

                                wrapMode: Text.Wrap

                                elide: Text.ElideRight
                            }

                            // ------------------------------------
                            // Action buttons
                            // ------------------------------------
                            Flow {
                                id: actionFlow

                                Layout.fillWidth: true
                                Layout.topMargin: actionFlow.visible ? 6 : 0

                                spacing: 6

                                readonly property var list: {
                                    var out = []

                                    try {
                                        const acts = wrapper.modelData.actions

                                        if (acts) {
                                            for (var i = 0; i < acts.length; i++) {
                                                var id = ""

                                                try {
                                                    if (acts[i].identifier !== undefined)
                                                        id = String(acts[i].identifier)
                                                } catch (e) {
                                                    id = ""
                                                }

                                                // "default" is the
                                                // whole-card click.
                                                if (id !== "default")
                                                    out.push(acts[i])
                                            }
                                        }
                                    } catch (e) {
                                        out = []
                                    }

                                    return out
                                }

                                visible: actionFlow.list.length > 0

                                Repeater {
                                    model: actionFlow.list

                                    delegate: Rectangle {
                                        id: actionButton

                                        required property var modelData

                                        implicitWidth: actionLabel.implicitWidth + 20
                                        implicitHeight: 24

                                        radius: 8

                                        color: actionArea.containsMouse
                                            ? Core.Theme.surfaceHover
                                            : Core.Theme.surface

                                        border.width: 1
                                        border.color: Core.Theme.separator

                                        Text {
                                            id: actionLabel

                                            anchors.centerIn: parent

                                            text: {
                                                try {
                                                    const t = actionButton.modelData.text

                                                    if (t !== undefined && t !== null)
                                                        return String(t)
                                                } catch (e) {
                                                    return "Action"
                                                }

                                                return "Action"
                                            }

                                            font.family: Core.Theme.fontFamily
                                            font.pixelSize: Core.Theme.fontSizeSmall
                                            font.weight: Font.DemiBold

                                            color: Core.Theme.foreground
                                        }

                                        MouseArea {
                                            id: actionArea

                                            anchors.fill: parent

                                            hoverEnabled: true

                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                try {
                                                    actionButton.modelData.invoke()
                                                } catch (e) {
                                                    // Sender went away.
                                                }

                                                wrapper.hide()
                                            }
                                        }

                                        scale: actionArea.pressed ? 0.94 : 1.0

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: 90
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ----------------------------------------
                    // Countdown bar. Absent on critical cards,
                    // which never expire on their own.
                    // ----------------------------------------
                    Rectangle {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom

                        height: 2

                        visible: wrapper.lifetime > 0

                        width: wrapper.lifetime <= 0
                            ? 0
                            : card.width * Math.max(
                                0,
                                Math.min(1, wrapper.remaining / wrapper.lifetime)
                            )

                        color: Core.Theme.accent

                        opacity: cardHover.hovered ? 0.25 : 0.7

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 160
                            }
                        }
                    }
                }
            }
        }
    }
}
