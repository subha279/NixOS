import QtQuick

import "../core" as Core

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property string trailing: ""

    property color iconColor: Core.Theme.foregroundMuted
    property color trailingColor: Core.Theme.foregroundMuted
    property color tint: Core.Theme.accent

    property bool active: false
    property bool glassActive: false
    property bool busy: false
    property bool dimmed: false
    property bool chip: true

    signal activated
    signal contextRequested(real mx, real my)

    readonly property color effectiveTint: root.active ? root.tint : root.iconColor

    implicitHeight: root.subtitle !== "" ? Core.Theme.rowHeight + 6 : Core.Theme.rowHeightCompact

    radius: Core.Theme.radiusRow

    color: root.active ? Core.Theme.tinted(root.tint, Core.Theme.chipAlpha) : mouse.containsMouse ? Core.Theme.surfaceGlassHover : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Core.Theme.durFast
            easing.type: Easing.OutQuint
        }
    }

    opacity: root.dimmed ? 0.45 : 1.0

    Behavior on opacity {
        NumberAnimation {
            duration: Core.Theme.durFast
            easing.type: Easing.OutQuint
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        width: 3
        height: root.active ? parent.height * 0.44 : 0

        radius: 2

        color: root.tint

        Behavior on height {
            NumberAnimation {
                duration: Core.Theme.durBase
                easing.type: Easing.OutQuint
            }
        }
    }

    Rectangle {
        id: iconChip

        anchors.left: parent.left
        anchors.leftMargin: Core.Theme.space2
        anchors.verticalCenter: parent.verticalCenter

        width: root.icon !== "" ? Core.Theme.chipSize : 0
        height: Core.Theme.chipSize

        radius: Core.Theme.chipRadius

        visible: root.icon !== ""

        color: !root.chip ? "transparent" : root.active ? Core.Theme.tinted(root.tint, Core.Theme.chipAlphaActive) : mouse.containsMouse ? Core.Theme.tinted(root.effectiveTint, Core.Theme.chipAlphaHover) : Core.Theme.tinted(root.effectiveTint, Core.Theme.chipAlpha)

        Behavior on color {
            ColorAnimation {
                duration: Core.Theme.durFast
                easing.type: Easing.OutQuint
            }
        }

        Text {
            id: iconText

            anchors.centerIn: parent

            text: root.icon

            font.family: Core.Theme.iconFont
            font.pixelSize: Core.Theme.iconSize

            renderType: Core.Theme.textRender

            color: root.effectiveTint

            opacity: root.busy ? 0.0 : 1.0

            Behavior on color {
                ColorAnimation {
                    duration: Core.Theme.durBase
                    easing.type: Easing.OutQuint
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Core.Theme.durFast
                    easing.type: Easing.OutQuint
                }
            }
        }

        Text {
            anchors.centerIn: parent

            text: "\udb81\udd1e"

            font.family: Core.Theme.iconFont
            font.pixelSize: Core.Theme.iconSize

            renderType: Core.Theme.textRender

            color: root.tint

            opacity: root.busy ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: Core.Theme.durFast
                    easing.type: Easing.OutQuint
                }
            }

            RotationAnimator on rotation {
                running: root.busy
                loops: Animation.Infinite

                from: 0
                to: 360

                duration: 900
            }
        }
    }

    Column {
        anchors.left: iconChip.right
        anchors.leftMargin: root.icon !== "" ? Core.Theme.space3 : Core.Theme.padRow
        anchors.right: trailingText.left
        anchors.rightMargin: Core.Theme.space2
        anchors.verticalCenter: parent.verticalCenter

        spacing: Core.Theme.gapTight

        Text {
            width: parent.width

            text: root.title

            elide: Text.ElideRight

            font.families: Core.Theme.textFamilies
            font.pixelSize: Core.Theme.fontSize
            font.weight: root.active ? Font.DemiBold : Font.Medium

            renderType: Core.Theme.textRender

            color: Core.Theme.foreground
        }

        Text {
            width: parent.width

            visible: root.subtitle !== ""

            text: root.subtitle

            elide: Text.ElideRight

            font.families: Core.Theme.textFamilies
            font.pixelSize: Core.Theme.fontSizeSmall

            renderType: Core.Theme.textRender

            color: root.active ? root.tint : Core.Theme.foregroundMuted

            Behavior on color {
                ColorAnimation {
                    duration: Core.Theme.durBase
                    easing.type: Easing.OutQuint
                }
            }
        }
    }

    Text {
        id: trailingText

        anchors.right: parent.right
        anchors.rightMargin: Core.Theme.padRow
        anchors.verticalCenter: parent.verticalCenter

        text: root.trailing

        font.families: Core.Theme.monoFamilies
        font.pixelSize: Core.Theme.fontSizeSmall

        renderType: Core.Theme.textRender

        color: root.trailingColor
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function (event) {
            if (event.button === Qt.RightButton) {
                const p = mouse.mapToItem(null, event.x, event.y);

                root.contextRequested(p.x, p.y);
                return;
            }

            root.activated();
        }
    }

    scale: mouse.pressed ? 0.985 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: Core.Theme.durFast
            easing.type: Easing.OutQuint
        }
    }
}
