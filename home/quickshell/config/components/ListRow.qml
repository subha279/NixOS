import QtQuick

import "../core" as Core

// ListRow

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property string trailing: ""

    property color iconColor: Core.Theme.foreground
    property color trailingColor: Core.Theme.foregroundMuted

    property bool active: false
    property bool busy: false
    property bool dimmed: false

    // Right-click gives window-space coordinates for the menu
    signal activated
    signal contextRequested(real mx, real my)

    implicitHeight: root.subtitle !== "" ? Core.Theme.rowHeight : 34

    radius: Core.Theme.radiusRow

    color: root.active ? Core.Theme.surfaceActive : mouse.containsMouse ? Core.Theme.surfaceHover : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 110
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

    // Active indicator bar

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        anchors.leftMargin: 3

        width: 3
        height: root.active ? parent.height * 0.5 : 0

        radius: 2

        color: Core.Theme.accent

        Behavior on height {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuint
            }
        }
    }

    // Leading icon

    Text {
        id: iconText

        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        width: 20

        text: root.icon

        font.family: Core.Theme.fontFamily
        font.pixelSize: Core.Theme.iconSize

        color: root.active ? Core.Theme.accent : root.iconColor

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutQuint
            }
        }

        opacity: root.busy ? 0.0 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuint
            }
        }
    }

    // Busy spinner (replaces the icon)

    Text {
        anchors.centerIn: iconText

        text: "\udb81\udd1e"

        font.family: Core.Theme.fontFamily
        font.pixelSize: Core.Theme.iconSize

        color: Core.Theme.accent

        opacity: root.busy ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
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

    // Title + subtitle

    Column {
        anchors.left: iconText.right
        anchors.leftMargin: 10
        anchors.right: trailingText.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        spacing: 1

        Text {
            width: parent.width

            text: root.title

            elide: Text.ElideRight

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize

            font.weight: root.active ? Font.DemiBold : Font.Medium

            color: Core.Theme.foreground
        }

        Text {
            width: parent.width

            visible: root.subtitle !== ""

            text: root.subtitle

            elide: Text.ElideRight

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSizeSmall

            color: root.active ? Core.Theme.accent : Core.Theme.foregroundMuted
        }
    }

    // Trailing badge

    Text {
        id: trailingText

        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        text: root.trailing

        font.family: Core.Theme.fontFamily
        font.pixelSize: Core.Theme.fontSizeSmall

        color: root.trailingColor
    }

    // Interaction

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

    // Press feedback

    scale: mouse.pressed ? 0.97 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 110
            easing.type: Easing.OutQuint
        }
    }
}
