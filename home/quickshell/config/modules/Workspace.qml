import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services

// Workspace (bar module)
//
// Shows only the workspace you are on, not the whole set. No popup: scrolling
// over it steps to the next occupied workspace, matching the wheel-to-step
// convention the volume and brightness modules already use.

Item {
    id: root

    readonly property var svc: Services.HyprlandService

    // Wide enough for two digits at the default font size, and grows if a
    // workspace has been given a name. Bar.qml multiplies this by reveal.
    implicitWidth: Math.max(30, label.implicitWidth + root.markerSize + 19)

    implicitHeight: Core.Theme.moduleHeight

    readonly property int markerSize: 4

    Rectangle {
        anchors.fill: parent

        radius: height / 2

        color: mouse.containsMouse ? Core.Theme.surfaceGlassHover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 100
                easing.type: Easing.OutQuint
            }
        }
    }

    Row {
        anchors.centerIn: parent

        spacing: 5

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter

            width: root.markerSize
            height: root.markerSize

            radius: root.markerSize / 2

            antialiasing: true

            color: root.svc.urgent ? Core.Theme.warning : Core.Theme.workspaceMarker

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutQuint
                }
            }
        }

        Text {
            id: label

            anchors.verticalCenter: parent.verticalCenter

            text: root.svc.label

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            renderType: Text.QtRendering

            color: Core.Theme.workspaceLabel

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutQuint
                }
            }

            // Same glyph-change pop the volume and battery icons use, so
            // switching workspace registers even though nothing moves.
            onTextChanged: popAnim.restart()

            SequentialAnimation {
                id: popAnim

                NumberAnimation {
                    target: label
                    property: "opacity"
                    to: 0.55
                    duration: 90
                    easing.type: Easing.OutQuint
                }

                NumberAnimation {
                    target: label
                    property: "opacity"
                    to: 1.0
                    duration: 150
                    easing.type: Easing.OutQuint
                }
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onWheel: function (wheel) {
            root.svc.step(wheel.angleDelta.y > 0 ? 1 : -1);
        }
    }
}
