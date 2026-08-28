import QtQuick
import Quickshell
import Quickshell.Wayland

import "../core" as Core

PanelWindow {
    id: root

    property string popupId: ""
    property int cardWidth: Core.Theme.popupWidth
    property int maxCardHeight: Core.Theme.popupMaxHeight
    property Component contentComponent: null

    readonly property bool open: Core.PopupManager.isOpen(root.popupId)
    readonly property bool menuOpen: menuLayer.active

    signal didOpen
    signal didClose

    function openMenu(x, y, items) {
        menuLayer.show(x, y, items);
    }

    function closeMenu() {
        menuLayer.close();
    }

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: root.maxCardHeight + 320

    color: "transparent"

    exclusionMode: ExclusionMode.Ignore

    // Only mapped while on screen; six always-mapped overlays get blurred by the
    // compositor for nothing. Tracks opacity so the close animation still plays.
    visible: root.open || visual.opacity > 0.01

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "aurora-popup"

    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    property Region noInput: Region {
        width: 0
        height: 0
    }

    mask: root.open ? null : root.noInput

    onOpenChanged: {
        if (root.open) {
            root.didOpen();
        } else {
            menuLayer.close();
            root.didClose();
        }
    }

    readonly property real barBottomY: Core.Theme.barMarginTop + 10 + Core.Theme.pillHeight + Core.Theme.borderWidth

    readonly property real naturalHeight: contentHost.implicitHeight + Core.Theme.padding * 2

    readonly property real targetHeight: Math.min(root.naturalHeight, root.maxCardHeight)

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

    Rectangle {
        id: card

        width: root.cardWidth

        x: Math.round(Math.max(Core.Theme.popupGap, Math.min(root.width - root.cardWidth - Core.Theme.popupGap, Core.PopupManager.anchorCenter - root.cardWidth / 2)))

        y: Math.round(root.barBottomY + Core.Theme.popupGap)

        height: root.targetHeight

        color: "transparent"

        antialiasing: true

        Item {
            id: visual

            anchors.fill: parent

            transformOrigin: Item.Top

            scale: root.open ? 1.0 : 0.98

            y: root.open ? 0 : -4

            opacity: root.open ? 1.0 : 0.0

            Behavior on scale {
                NumberAnimation {
                    duration: root.open ? Core.Theme.durShort : Core.Theme.durExitShort

                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Core.Theme.easeStandard
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: root.open ? Core.Theme.durShort : Core.Theme.durExitShort

                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Core.Theme.easeStandard
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: root.open ? Core.Theme.durInstant : Core.Theme.durExitShort

                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Core.Theme.easeStandard
                }
            }

            Rectangle {
                anchors.fill: parent

                radius: Core.Theme.radiusMenu

                color: "transparent"

                border.width: Core.Theme.borderWidth
                border.color: Core.Theme.borderActive

                antialiasing: true

                Glass {
                    anchors.fill: parent

                    radius: parent.radius

                    strength: 0.68
                }
            }

            Item {
                id: contentHost

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                anchors.margins: Core.Theme.padding

                implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight : 0

                height: implicitHeight

                opacity: root.open ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: root.open ? Core.Theme.durInstant : Core.Theme.durExitShort

                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Core.Theme.easeStandard
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
    }

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

            color: "transparent"

            border.width: Core.Theme.borderWidth
            border.color: Core.Theme.border

            antialiasing: true

            transformOrigin: Item.TopLeft

            scale: menuLayer.active ? 1.0 : 0.96

            opacity: menuLayer.active ? 1.0 : 0.0

            Behavior on scale {
                NumberAnimation {
                    duration: menuLayer.active ? Core.Theme.durInstant : Core.Theme.durExitShort

                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Core.Theme.easeStandard
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: menuLayer.active ? Core.Theme.durInstant : Core.Theme.durExitShort

                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Core.Theme.easeStandard
                }
            }

            Glass {
                anchors.fill: parent

                radius: parent.radius
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

                                        font.family: Core.Theme.iconFont

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
