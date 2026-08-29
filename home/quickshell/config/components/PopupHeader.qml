import QtQuick

import "../core" as Core

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string icon: ""

    property color tint: Core.Theme.accent

    property bool showToggle: false
    property bool toggled: false

    signal toggleRequested

    property var actions: []

    implicitHeight: 46

    Rectangle {
        id: chip

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        width: root.icon !== "" ? Core.Theme.chipSize : 0
        height: Core.Theme.chipSize

        radius: Core.Theme.chipRadius

        visible: root.icon !== ""

        color: Core.Theme.tinted(root.tint, Core.Theme.chipAlpha)

        Text {
            anchors.centerIn: parent

            text: root.icon

            font.family: Core.Theme.iconFont
            font.pixelSize: Core.Theme.iconSize

            renderType: Text.QtRendering

            color: root.tint
        }
    }

    Column {
        anchors.left: chip.right
        anchors.leftMargin: root.icon !== "" ? Core.Theme.space3 : 0
        anchors.right: actionRow.left
        anchors.rightMargin: Core.Theme.space2
        anchors.verticalCenter: parent.verticalCenter

        spacing: Core.Theme.gapTight

        Text {
            width: parent.width

            text: root.title

            elide: Text.ElideRight

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSizeHeading
            font.weight: Font.DemiBold
            font.letterSpacing: Core.Theme.trackingTight

            renderType: Text.QtRendering

            color: Core.Theme.foreground
        }

        Text {
            width: parent.width

            visible: root.subtitle !== ""

            text: root.subtitle

            elide: Text.ElideRight

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSizeSmall

            renderType: Text.QtRendering

            color: Core.Theme.foregroundMuted
        }
    }

    Row {
        id: actionRow

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        spacing: Core.Theme.space1

        Repeater {
            model: root.actions

            delegate: Rectangle {
                id: actionButton

                required property var modelData

                width: Core.Theme.chipSize
                height: Core.Theme.chipSize

                radius: Core.Theme.chipRadius

                color: btnMouse.containsMouse ? Core.Theme.tinted(root.tint, Core.Theme.chipAlphaHover) : Core.Theme.tinted(root.tint, 0.0)

                Behavior on color {
                    ColorAnimation {
                        duration: Core.Theme.durFast
                        easing.type: Easing.OutQuint
                    }
                }

                scale: btnMouse.pressed ? 0.9 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: Core.Theme.durFast
                        easing.type: Easing.OutQuint
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: actionButton.modelData.icon

                    font.family: Core.Theme.iconFont
                    font.pixelSize: Core.Theme.iconSizeSmall

                    renderType: Text.QtRendering

                    color: btnMouse.containsMouse ? root.tint : Core.Theme.foregroundMuted

                    Behavior on color {
                        ColorAnimation {
                            duration: Core.Theme.durFast
                            easing.type: Easing.OutQuint
                        }
                    }

                    RotationAnimator on rotation {
                        running: actionButton.modelData.spinning === true
                        loops: Animation.Infinite

                        from: 0
                        to: 360

                        duration: 1000
                    }
                }

                MouseArea {
                    id: btnMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (typeof actionButton.modelData.action === "function")
                            actionButton.modelData.action();
                    }
                }
            }
        }

        Item {
            visible: root.showToggle

            width: root.showToggle ? 42 : 0
            height: Core.Theme.chipSize

            Rectangle {
                id: track

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                width: 40
                height: 22

                radius: height / 2

                color: Core.Theme.surfaceSunken

                border.width: root.toggled ? 0 : 1
                border.color: Core.Theme.border

                Rectangle {
                    anchors.fill: parent

                    radius: parent.radius

                    antialiasing: true

                    opacity: root.toggled ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Core.Theme.durBase
                            easing.type: Easing.OutQuint
                        }
                    }

                    gradient: Gradient {
                        orientation: Gradient.Horizontal

                        GradientStop {
                            position: 0.0
                            color: root.tint
                        }

                        GradientStop {
                            position: 1.0
                            color: Core.Theme.accentActive
                        }
                    }
                }

                Rectangle {
                    width: 16
                    height: 16

                    radius: width / 2

                    anchors.verticalCenter: parent.verticalCenter

                    x: root.toggled ? track.width - width - 3 : 3

                    color: root.toggled ? Core.Theme.accentForeground : Core.Theme.foregroundFaint

                    Behavior on x {
                        NumberAnimation {
                            duration: Core.Theme.durBase
                            easing.type: Easing.OutQuint
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Core.Theme.durBase
                            easing.type: Easing.OutQuint
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.toggleRequested()
                }
            }
        }
    }
}
