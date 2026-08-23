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
//   * The card's height is driven by a NumberAnimation, so growing
//     and shrinking eases smoothly without overshoot — soft, not
//     robotic.
//   * The card scales subtly from the top with a cubic curve on open
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

    // Public API

    property string popupId: ""

    property int cardWidth: Core.Theme.popupWidth
    property int maxCardHeight: Core.Theme.popupMaxHeight

    // The card's body. Give its root item an implicitHeight; the
    // card sizes (and springs) to match.
    property Component contentComponent: null

    readonly property bool open: Core.PopupManager.isOpen(root.popupId)

    readonly property bool menuOpen: menuLayer.active

    // NOTE: these are deliberately NOT called opened()/closed().
    signal didOpen
    signal didClose

    function openMenu(x, y, items) {
        menuLayer.show(x, y, items);
    }

    function closeMenu() {
        menuLayer.close();
    }

    // Window setup

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: root.maxCardHeight + 320

    color: "transparent"

    // Ignore mode already implies a zero exclusive zone.
    exclusionMode: ExclusionMode.Ignore

    visible: root.open || root.rendering

    WlrLayershell.layer: WlrLayer.Overlay

    WlrLayershell.namespace: "aurora-popup"

    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

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
            closeTimer.stop();
            root.rendering = true;
            root.didOpen();
        } else {
            menuLayer.close();
            closeTimer.restart();
            root.didClose();
        }
    }

    Timer {
        id: closeTimer

        interval: Core.Theme.durClose + 420
        repeat: false

        onTriggered: root.rendering = false
    }

    // Geometry driven by the content

    // Screen-space Y of the bottom edge of the bar pill.
    readonly property real barBottomY: Core.Theme.barMarginTop + 10 + Core.Theme.pillHeight + Core.Theme.borderWidth

    readonly property real naturalHeight: contentHost.implicitHeight + Core.Theme.padding * 2

    readonly property real targetHeight: Math.min(root.naturalHeight, root.maxCardHeight)

    // Click outside to dismiss

    MouseArea {
        anchors.fill: parent

        enabled: root.open

        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onPressed: {
            if (menuLayer.active) {
                menuLayer.close();
                return;
            }

            Core.PopupManager.close();
        }
    }

    // Escape to dismiss

    Item {
        anchors.fill: parent

        focus: root.open

        Keys.onEscapePressed: {
            if (menuLayer.active)
                menuLayer.close();
            else
                Core.PopupManager.close();
        }
    }

    // Floating shadow
    //
    // A sibling of the card rather than a child: the card turns on layer
    // caching while it scales, and a layer clips to the item's own bounds,
    // which would cut off any shadow drawn past the edge. Widest layer first
    // so darkness builds up towards the card.

    Item {
        anchors.fill: card

        z: -1

        opacity: card.opacity

        scale: card.scale

        transformOrigin: card.transformOrigin

        visible: card.height > 0

        Rectangle {
            anchors.fill: parent
            anchors.margins: -10

            radius: card.radius + 10

            color: "#000000"

            opacity: Core.Theme.shellShadowOpacity * 0.15

            antialiasing: true
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -6

            radius: card.radius + 6

            color: "#000000"

            opacity: Core.Theme.shellShadowOpacity * 0.30

            antialiasing: true
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -3

            radius: card.radius + 3

            color: "#000000"

            opacity: Core.Theme.shellShadowOpacity * 0.55

            antialiasing: true
        }
    }

    // The card

    Rectangle {
        id: card

        width: root.cardWidth

        // Horizontally centred on the bar module that opened us, clamped so it never runs off screen.
        x: Math.round(Math.max(Core.Theme.popupGap, Math.min(root.width - root.cardWidth - Core.Theme.popupGap, Core.PopupManager.anchorCenter - root.cardWidth / 2)))

        // Every module lives in the same pill, so the vertical anchor is always the same number.
        y: Math.round(root.barBottomY + Core.Theme.popupGap)

        // The soft part: a single cubic animation drives the height.

        height: root.open ? root.targetHeight : 0

        Behavior on height {
            NumberAnimation {
                duration: root.open ? Core.Theme.durOpen : Core.Theme.durClose
                easing.type: Easing.OutQuint
            }
        }

        transformOrigin: Item.Top

        scale: root.open ? 1.0 : 0.96

        opacity: root.open ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: root.open ? Core.Theme.durOpen : Core.Theme.durClose
                easing.type: root.open ? Easing.OutQuint : Easing.InQuint
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.open ? Core.Theme.durBase : Core.Theme.durClose

                easing.type: Easing.OutQuint
            }
        }

        radius: Core.Theme.radiusMenu

        color: Core.Theme.backgroundSolid

        border.width: Core.Theme.borderWidth
        border.color: Core.Theme.borderActive

        antialiasing: true

        // Cache the card while it is being scaled/faded.
        layer.enabled: root.open || root.rendering
        layer.smooth: true

        // Swallow clicks so the outside-click handler doesn't fire
        MouseArea {
            anchors.fill: parent

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed: function (mouse) {
                if (menuLayer.active) {
                    menuLayer.close();
                    mouse.accepted = true;
                    return;
                }

                mouse.accepted = false;
            }
        }

        // Content host — fades and slides behind the geometry

        Item {
            id: contentHost

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.margins: Core.Theme.padding

            implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight : 0

            height: implicitHeight

            opacity: root.open ? 1.0 : 0.0

            transform: Translate {
                y: root.open ? 0 : -6

                Behavior on y {
                    NumberAnimation {
                        duration: Core.Theme.durSlow
                        easing.type: Easing.OutQuint
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: root.open ? Core.Theme.durSlow : Core.Theme.durFast

                    easing.type: Easing.OutQuint
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

    // Shared right-click context menu

    Item {
        id: menuLayer

        anchors.fill: parent

        z: 999

        property bool active: false
        property var items: []

        property real targetX: 0
        property real targetY: 0

        function show(x, y, list) {
            menuLayer.items = list;
            menuLayer.targetX = x;
            menuLayer.targetY = y;
            menuLayer.active = true;

            Core.PopupManager.contextMenuOpen = true;
        }

        function close() {
            menuLayer.active = false;
            Core.PopupManager.contextMenuOpen = false;
        }

        visible: menuLayer.active || menuBox.opacity > 0.01

        Rectangle {
            id: menuBox

            width: 200

            height: menuColumn.implicitHeight + 10

            x: Math.round(Math.max(6, Math.min(menuLayer.width - width - 6, menuLayer.targetX)))

            y: Math.round(Math.max(6, Math.min(menuLayer.height - height - 6, menuLayer.targetY)))

            radius: 14

            color: Core.Theme.backgroundSolid

            border.width: Core.Theme.borderWidth
            border.color: Core.Theme.border

            antialiasing: true

            layer.enabled: menuLayer.active || menuBox.opacity > 0.01
            layer.smooth: true

            transformOrigin: Item.TopLeft

            scale: menuLayer.active ? 1.0 : 0.96
            opacity: menuLayer.active ? 1.0 : 0.0

            Behavior on scale {
                NumberAnimation {
                    duration: menuLayer.active ? 180 : 120
                    easing.type: menuLayer.active ? Easing.OutQuint : Easing.InQuint
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: menuLayer.active ? 150 : 110
                    easing.type: Easing.OutQuint
                }
            }

            Behavior on height {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutQuint
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

                        sourceComponent: entryLoader.modelData.separator === true ? separatorComp : entryComp

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

                                color: entryMouse.containsMouse ? Core.Theme.surfaceHover : "transparent"

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 90
                                        easing.type: Easing.OutQuint
                                    }
                                }

                                Row {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter

                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10

                                    spacing: 9

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter

                                        width: 16

                                        text: entryLoader.modelData.icon ? entryLoader.modelData.icon : ""

                                        font.family: Core.Theme.fontFamily

                                        font.pixelSize: 13

                                        color: entryLoader.modelData.danger === true ? Core.Theme.danger : Core.Theme.foregroundMuted
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter

                                        text: entryLoader.modelData.label

                                        font.family: Core.Theme.fontFamily

                                        font.pixelSize: Core.Theme.fontSize

                                        color: entryLoader.modelData.danger === true ? Core.Theme.danger : Core.Theme.foreground
                                    }
                                }

                                MouseArea {
                                    id: entryMouse

                                    anchors.fill: parent

                                    hoverEnabled: true

                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        const act = entryLoader.modelData.action;

                                        menuLayer.close();

                                        if (typeof act === "function")
                                            act();
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
