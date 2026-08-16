import QtQuick

import Quickshell
import Quickshell.Wayland

import "../core" as Core

// ================================================================
// PopupSurface
// ----------------------------------------------------------------
// A full-width overlay layer that hosts ONE animated glass card.
//
// Motion design:
//   * The card's height is driven by a SpringAnimation, so growing
//     and shrinking overshoots slightly and settles — rubbery, not
//     robotic.
//   * The card scales from the top with an OutBack curve on open
//     and collapses with an InCubic curve on close.
//   * Inner content fades + slides, slightly behind the geometry,
//     so text appears to "arrive" as the card grows and to leave
//     before it collapses.
//
// Usage:
//   PopupSurface {
//       popupId: "network"
//       contentComponent: Component { Column { ... } }
//   }
//
// It also provides a shared right-click context menu through
// `openMenu(x, y, items)`.
// ================================================================

PanelWindow {
    id: root

    // ------------------------------------------------------------
    // Public API
    // ------------------------------------------------------------

    property string popupId: ""

    property int cardWidth: Core.Theme.popupWidth
    property int maxCardHeight: Core.Theme.popupMaxHeight

    // The card's body. Give its root item an implicitHeight; the
    // card sizes (and springs) to match.
    property Component contentComponent: null

    readonly property bool open:
        Core.PopupManager.isOpen(root.popupId)

    readonly property bool menuOpen: menuLayer.active

    // NOTE: these are deliberately NOT called opened()/closed().
    // Quickshell's window base class already defines a `closed`
    // signal, and QML rejects the override with
    // "Duplicate signal name".
    signal didOpen()
    signal didClose()

    function openMenu(x, y, items) {
        menuLayer.show(x, y, items)
    }

    function closeMenu() {
        menuLayer.close()
    }

    // ------------------------------------------------------------
    // Window setup
    // ------------------------------------------------------------

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: root.maxCardHeight + 320

    color: "transparent"

    // Ignore mode already implies a zero exclusive zone. Do NOT
    // also set exclusiveZone here — assigning it flips
    // exclusionMode back to Normal and the bar's reserved strip
    // pushes this whole window down.
    exclusionMode: ExclusionMode.Ignore

    visible: root.open || root.rendering

    WlrLayershell.layer: WlrLayer.Overlay

    WlrLayershell.namespace: "aurora-popup"

    WlrLayershell.keyboardFocus:
        root.open
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

    // Keeps the window alive until the close animation finishes
    property bool rendering: false

    // While closed we must not steal clicks from the desktop
    property Region noInput: Region {
        width: 0
        height: 0
    }

    mask: root.open ? null : root.noInput

    onOpenChanged: {
        if (root.open) {
            closeTimer.stop()
            root.rendering = true
            root.didOpen()
        } else {
            menuLayer.close()
            closeTimer.restart()
            root.didClose()
        }
    }

    Timer {
        id: closeTimer

        interval: Core.Theme.durClose + 420
        repeat: false

        onTriggered: root.rendering = false
    }

    // ------------------------------------------------------------
    // Geometry driven by the content
    // ------------------------------------------------------------

    // Screen-space Y of the bottom edge of the bar pill.
    //
    // Bar window: margins.top = barMarginTop, implicitHeight =
    // pillHeight + 20, and the pill is vertically centred, so it
    // starts 10px into the window.
    //
    // Computed from constants that definitely exist so a missing
    // Theme property can never turn this into NaN.
    readonly property real barBottomY:
        Core.Theme.barMarginTop + 10 + Core.Theme.pillHeight

    readonly property real naturalHeight:
        contentHost.implicitHeight + Core.Theme.padding * 2

    readonly property real targetHeight:
        Math.min(root.naturalHeight, root.maxCardHeight)

    // ------------------------------------------------------------
    // Click outside to dismiss
    // ------------------------------------------------------------

    MouseArea {
        anchors.fill: parent

        enabled: root.open

        acceptedButtons:
            Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onPressed: {
            if (menuLayer.active) {
                menuLayer.close()
                return
            }

            Core.PopupManager.close()
        }
    }

    // ------------------------------------------------------------
    // Escape to dismiss
    // ------------------------------------------------------------

    Item {
        anchors.fill: parent

        focus: root.open

        Keys.onEscapePressed: {
            if (menuLayer.active)
                menuLayer.close()
            else
                Core.PopupManager.close()
        }
    }

    // ============================================================
    // The card
    // ============================================================

    Rectangle {
        id: card

        width: root.cardWidth

        // Horizontally centred on the bar module that opened us,
        // clamped so it never runs off screen.
        x: Math.round(
            Math.max(
                Core.Theme.popupGap,
                Math.min(
                    root.width - root.cardWidth - Core.Theme.popupGap,
                    Core.PopupManager.anchorCenter - root.cardWidth / 2
                )
            )
        )

        // Every module lives in the same pill, so the vertical
        // anchor is always the same number. Deriving it per-click
        // from mapToItem was the source of all the drift.
        y: Math.round(root.barBottomY + Core.Theme.popupGap)

        // --------------------------------------------------------
        // The rubbery part: a spring drives the height, so any
        // change in the number of rows overshoots and settles.
        // --------------------------------------------------------

        height: root.open ? root.targetHeight : 0

        Behavior on height {
            SpringAnimation {
                spring: Core.Theme.springStiffness
                damping: Core.Theme.springDamping
                mass: Core.Theme.springMass
                epsilon: Core.Theme.springEpsilon
            }
        }

        transformOrigin: Item.Top

        scale: root.open ? 1.0 : 0.9

        opacity: root.open ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: root.open
                    ? Core.Theme.durOpen
                    : Core.Theme.durClose

                easing.type: root.open
                    ? Easing.OutBack
                    : Easing.InCubic

                easing.overshoot: Core.Theme.overshoot
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.open
                    ? Core.Theme.durBase
                    : Core.Theme.durClose

                easing.type: Easing.OutCubic
            }
        }

        radius: Core.Theme.radiusMenu

        color: Core.Theme.backgroundSolid

        border.width: 1
        border.color: Core.Theme.border

        antialiasing: true

        // Clipping is what makes the content look like it is being
        // revealed by the growing card.
        clip: true

        // Soft drop shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4

            z: -1

            radius: card.radius + 4
            color: "#000000"

            opacity: Core.Theme.shadowOpacity
        }

        // Swallow clicks so the outside-click handler doesn't fire
        MouseArea {
            anchors.fill: parent

            acceptedButtons:
                Qt.LeftButton | Qt.RightButton

            onPressed: function(mouse) {
                if (menuLayer.active) {
                    menuLayer.close()
                    mouse.accepted = true
                    return
                }

                mouse.accepted = false
            }
        }

        // --------------------------------------------------------
        // Content host — fades and slides behind the geometry
        // --------------------------------------------------------

        Item {
            id: contentHost

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.margins: Core.Theme.padding

            implicitHeight: contentLoader.item
                ? contentLoader.item.implicitHeight
                : 0

            height: implicitHeight

            opacity: root.open ? 1.0 : 0.0

            transform: Translate {
                y: root.open ? 0 : -10

                Behavior on y {
                    NumberAnimation {
                        duration: Core.Theme.durSlow
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: root.open
                        ? Core.Theme.durSlow
                        : Core.Theme.durFast

                    easing.type: Easing.OutCubic
                }
            }

            Loader {
                id: contentLoader

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                sourceComponent: root.contentComponent
            }
        }
    }

    // ============================================================
    // Shared right-click context menu
    // ============================================================
    //
    // items: [{ label, icon, danger, separator, action }]
    //
    // Lives outside the card so it is never clipped by it.
    // ============================================================

    Item {
        id: menuLayer

        anchors.fill: parent

        z: 999

        property bool active: false
        property var items: []

        property real targetX: 0
        property real targetY: 0

        function show(x, y, list) {
            menuLayer.items = list
            menuLayer.targetX = x
            menuLayer.targetY = y
            menuLayer.active = true

            Core.PopupManager.contextMenuOpen = true
        }

        function close() {
            menuLayer.active = false
            Core.PopupManager.contextMenuOpen = false
        }

        visible: menuLayer.active || menuBox.opacity > 0.01

        Rectangle {
            id: menuBox

            width: 200

            height: menuColumn.implicitHeight + 10

            x: Math.round(
                Math.max(
                    6,
                    Math.min(
                        menuLayer.width - width - 6,
                        menuLayer.targetX
                    )
                )
            )

            y: Math.round(
                Math.max(
                    6,
                    Math.min(
                        menuLayer.height - height - 6,
                        menuLayer.targetY
                    )
                )
            )

            radius: 14

            color: Core.Theme.backgroundSolid

            border.width: 1
            border.color: Core.Theme.border

            antialiasing: true

            transformOrigin: Item.TopLeft

            scale: menuLayer.active ? 1.0 : 0.85
            opacity: menuLayer.active ? 1.0 : 0.0

            Behavior on scale {
                NumberAnimation {
                    duration: menuLayer.active ? 220 : 120

                    easing.type: menuLayer.active
                        ? Easing.OutBack
                        : Easing.InCubic

                    easing.overshoot: 1.8
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: menuLayer.active ? 150 : 110
                }
            }

            Behavior on height {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: -3

                z: -1

                radius: parent.radius + 3
                color: "#000000"
                opacity: 0.18
            }

            Column {
                id: menuColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                anchors.margins: 5

                spacing: 1

                Repeater {
                    model: menuLayer.items

                    delegate: Loader {
                        id: entryLoader

                        required property var modelData

                        width: menuColumn.width

                        sourceComponent:
                            entryLoader.modelData.separator === true
                                ? separatorComp
                                : entryComp

                        Component {
                            id: separatorComp

                            Item {
                                height: 7

                                Rectangle {
                                    anchors.centerIn: parent

                                    width: parent.width - 12
                                    height: 1

                                    color: Core.Theme.separator
                                }
                            }
                        }

                        Component {
                            id: entryComp

                            Rectangle {
                                height: 30

                                radius: 9

                                color: entryMouse.containsMouse
                                    ? Core.Theme.surfaceHover
                                    : "transparent"

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 90
                                    }
                                }

                                Row {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10

                                    spacing: 9

                                    Text {
                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        width: 16

                                        text: entryLoader.modelData.icon
                                            ? entryLoader.modelData.icon
                                            : ""

                                        font.family:
                                            Core.Theme.fontFamily

                                        font.pixelSize: 13

                                        color: entryLoader.modelData.danger
                                                === true
                                            ? Core.Theme.danger
                                            : Core.Theme.foregroundMuted
                                    }

                                    Text {
                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        text: entryLoader.modelData.label

                                        font.family:
                                            Core.Theme.fontFamily

                                        font.pixelSize:
                                            Core.Theme.fontSize

                                        color: entryLoader.modelData.danger
                                                === true
                                            ? Core.Theme.danger
                                            : Core.Theme.foreground
                                    }
                                }

                                MouseArea {
                                    id: entryMouse

                                    anchors.fill: parent

                                    hoverEnabled: true

                                    cursorShape:
                                        Qt.PointingHandCursor

                                    onClicked: {
                                        const act =
                                            entryLoader.modelData.action

                                        menuLayer.close()

                                        if (typeof act === "function")
                                            act()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
