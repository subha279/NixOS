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
    property color tint: Core.Theme.accent

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

    visible: root.open

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

    readonly property real naturalHeight: contentHost.implicitHeight + Core.Theme.padCard * 2

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

        Elevation {
            anchors.fill: parent

            radius: Core.Theme.radiusMenu

            level: 1.7

            opacity: root.open ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: Core.Theme.durOpen
                    easing.type: Easing.OutCubic
                }
            }
        }

        Item {
            id: visual

            anchors.fill: parent

            opacity: root.open ? 1.0 : 0.0

            Rectangle {
                anchors.fill: parent

                radius: Core.Theme.radiusMenu

                color: "transparent"

                border.width: Core.Theme.borderWidth
                border.color: Core.Theme.tinted(root.tint, 0.45)

                antialiasing: true

                Glass {
                    anchors.fill: parent

                    radius: parent.radius

                    strength: 0.72

                    tint: root.tint

                    tintAmount: Core.Theme.glassGradientOpacity * 1.6
                }
            }

            Item {
                id: contentHost

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                anchors.margins: Core.Theme.padCard

                implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight : 0

                height: implicitHeight

                opacity: root.open ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: root.open ? 150 : 100
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

            width: 216

            height: menuColumn.implicitHeight + Core.Theme.space2

            x: Math.round(Math.max(Core.Theme.space2, Math.min(menuLayer.width - width - Core.Theme.space2, menuLayer.targetX)))

            y: Math.round(Math.max(Core.Theme.space2, Math.min(menuLayer.height - height - Core.Theme.space2, menuLayer.targetY)))

            radius: Core.Theme.radius + 4

            color: "transparent"

            border.width: Core.Theme.borderWidth
            border.color: Core.Theme.tinted(root.tint, 0.35)

            antialiasing: true

            opacity: menuLayer.active ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: menuLayer.active ? 120 : 90

                    easing.type: Easing.OutCubic
                }
            }

            Elevation {
                anchors.fill: parent

                radius: parent.radius

                level: 2.0
            }

            Glass {
                anchors.fill: parent

                radius: parent.radius

                tint: root.tint

                tintAmount: Core.Theme.glassGradientOpacity
            }

            Column {
                id: menuColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                anchors.margins: Core.Theme.space1

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
                                height: 32

                                radius: Core.Theme.radius

                                readonly property color entryTint: entryLoader.modelData.danger === true ? Core.Theme.danger : root.tint

                                color: entryMouse.containsMouse ? Core.Theme.tinted(entryTint, Core.Theme.chipAlpha) : "transparent"

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Core.Theme.durFast
                                        easing.type: Easing.OutQuint
                                    }
                                }

                                Row {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter

                                    anchors.leftMargin: Core.Theme.space3
                                    anchors.rightMargin: Core.Theme.space3

                                    spacing: Core.Theme.space3

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter

                                        width: 16

                                        text: entryLoader.modelData.icon ? entryLoader.modelData.icon : ""

                                        font.family: Core.Theme.iconFont

                                        font.pixelSize: Core.Theme.iconSizeSmall

                                        renderType: Core.Theme.textRender

                                        color: entryLoader.modelData.danger === true ? Core.Theme.danger : entryMouse.containsMouse ? root.tint : Core.Theme.foregroundMuted

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: Core.Theme.durFast
                                                easing.type: Easing.OutQuint
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter

                                        text: entryLoader.modelData.label

                                        font.families: Core.Theme.textFamilies

                                        font.pixelSize: Core.Theme.fontSize

                                        renderType: Core.Theme.textRender

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
