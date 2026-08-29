import QtQuick
import Quickshell
import Quickshell.Wayland

import "../core" as Core

PanelWindow {
    id: root

    property string popupId: ""
    property int cardWidth: Core.Theme.popupWidth

    readonly property int maxCardHeight: root.height > 0 ? Math.max(240, Math.round(root.height - root.barBottomY - Core.Theme.popupGap * 3)) : Core.Theme.popupMaxHeight
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
        bottom: true
    }

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

    readonly property real naturalHeight: Math.round(contentHost.implicitHeight) + Core.Theme.padCard * 2

    readonly property real targetHeight: Math.round(Math.min(root.naturalHeight, root.maxCardHeight))

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

            opacity: root.open ? 1.0 : 0.0

            Glass {
                anchors.fill: parent

                radius: Core.Theme.radiusMenu

                tint: root.tint

                tintAmount: Core.Theme.glassGradientOpacity * 1.6
            }

            Item {
                id: contentHost

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                anchors.margins: Core.Theme.padCard

                implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight : 0

                height: Math.max(0, Math.min(Math.round(contentHost.implicitHeight), card.height - Core.Theme.padCard * 2))

                clip: true

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

        readonly property real chromeWidth: Core.Theme.space1 * 2 + Core.Theme.space3 * 3 + 16

        readonly property real labelWidth: {
            if (typeof menuMetrics.advanceWidth !== "function")
                return 0;

            let widest = 0;

            for (let i = 0; i < menuLayer.items.length; i++) {
                const entry = menuLayer.items[i];

                if (!entry || entry.separator === true)
                    continue;

                widest = Math.max(widest, menuMetrics.advanceWidth(String(entry.label)));
            }

            return widest;
        }

        FontMetrics {
            id: menuMetrics

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
        }

        Rectangle {
            x: card.x
            y: card.y

            width: card.width
            height: card.height

            radius: Core.Theme.radiusMenu

            color: Core.Theme.scrim

            antialiasing: true

            opacity: menuLayer.active ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: menuLayer.active ? 120 : 90

                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            id: menuBox

            width: Math.round(Math.max(184, Math.min(card.width - Core.Theme.space2 * 2, menuLayer.labelWidth + menuLayer.chromeWidth + Core.Theme.space2)))

            height: Math.round(menuColumn.implicitHeight) + Core.Theme.space2

            readonly property real minX: card.x + Core.Theme.space2
            readonly property real maxX: card.x + card.width - menuBox.width - Core.Theme.space2

            readonly property real minY: card.y + Core.Theme.space2
            readonly property real maxY: card.y + card.height - menuBox.height - Core.Theme.space2

            x: Math.round(menuBox.maxX < menuBox.minX ? menuBox.minX : Math.max(menuBox.minX, Math.min(menuBox.maxX, menuLayer.targetX)))

            y: Math.round(menuBox.maxY < menuBox.minY ? menuBox.minY : Math.max(menuBox.minY, Math.min(menuBox.maxY, menuLayer.targetY)))

            radius: Core.Theme.radius + 4

            color: "transparent"

            antialiasing: true

            opacity: menuLayer.active ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: menuLayer.active ? 120 : 90

                    easing.type: Easing.OutCubic
                }
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
                                height: Core.Theme.space2

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter

                                    anchors.leftMargin: Core.Theme.space3
                                    anchors.rightMargin: Core.Theme.space3

                                    height: 1

                                    color: Core.Theme.tinted(Core.Theme.foreground, 0.12)
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

                                        horizontalAlignment: Text.AlignHCenter

                                        text: entryLoader.modelData.icon ? entryLoader.modelData.icon : ""

                                        font.family: Core.Theme.iconFont

                                        font.pixelSize: Core.Theme.iconSizeSmall

                                        renderType: Text.QtRendering

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

                                        width: menuBox.width - menuLayer.chromeWidth

                                        text: entryLoader.modelData.label

                                        font.family: Core.Theme.fontFamily

                                        font.pixelSize: Core.Theme.fontSize

                                        elide: Text.ElideRight

                                        renderType: Text.QtRendering

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
