import QtQuick

import "../core" as Core

// ================================================================
// VolumeSlider
// ----------------------------------------------------------------
// A compact, draggable level bar.
//
// The value is NOT written back to itself on drag. The owner is
// expected to handle `moved(value)` and push the new value into
// Pipewire, which then flows back down through `value`. That keeps
// a single source of truth and avoids feedback loops.
// ================================================================

Item {
    id: root

    // 0.0 .. 1.0
    property real value: 0

    property bool muted: false
    property bool enabled: true

    property color fillColor: Core.Theme.accent

    // Emitted continuously while dragging and on click.
    signal moved(real value)

    // Emitted once when the drag finishes.
    signal released(real value)

    implicitHeight: 24

    readonly property bool dragging: sliderMouse.pressed

    readonly property real shown:
        Math.max(0, Math.min(1, root.value))

    opacity: root.enabled ? 1.0 : 0.45

    Behavior on opacity {
        NumberAnimation {
            duration: Core.Theme.durFast
        }
    }

    Rectangle {
        id: track

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        height: root.dragging ? 10 : 8

        radius: height / 2

        color: Core.Theme.surface

        Behavior on height {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutBack
                easing.overshoot: 2.0
            }
        }

        Rectangle {
            id: fill

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: parent.width * root.shown

            radius: parent.radius

            color: root.muted
                ? Core.Theme.foregroundFaint
                : root.fillColor

            Behavior on color {
                ColorAnimation {
                    duration: Core.Theme.durFast
                }
            }

            // Only spring the width when the change came from
            // somewhere else. While dragging we want it to track
            // the pointer exactly, with no lag.
            Behavior on width {
                enabled: !root.dragging

                SpringAnimation {
                    spring: 4.0
                    damping: 0.45
                    mass: 0.9
                    epsilon: 0.25
                }
            }
        }

        Rectangle {
            id: knob

            width: root.dragging ? 16 : 13
            height: width

            radius: width / 2

            anchors.verticalCenter: parent.verticalCenter

            x: Math.max(
                0,
                Math.min(
                    track.width - width,
                    fill.width - width / 2
                )
            )

            color: root.muted
                ? Core.Theme.foregroundMuted
                : Core.Theme.foreground

            border.width: 2
            border.color: Core.Theme.onAccent

            Behavior on width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutBack
                    easing.overshoot: 2.4
                }
            }

            Behavior on x {
                enabled: !root.dragging

                SpringAnimation {
                    spring: 4.0
                    damping: 0.45
                    mass: 0.9
                    epsilon: 0.25
                }
            }
        }
    }

    MouseArea {
        id: sliderMouse

        anchors.fill: parent
        anchors.topMargin: -6
        anchors.bottomMargin: -6

        enabled: root.enabled

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        preventStealing: true

        function apply(mx) {

            if (track.width <= 0)
                return 0

            const ratio =
                Math.max(0, Math.min(1, mx / track.width))

            root.moved(ratio)

            return ratio
        }

        onPressed: function(event) {
            sliderMouse.apply(event.x)
        }

        onPositionChanged: function(event) {

            if (!sliderMouse.pressed)
                return

            sliderMouse.apply(event.x)
        }

        onReleased: function(event) {
            root.released(sliderMouse.apply(event.x))
        }

        onWheel: function(event) {

            const step = 0.05

            const next = event.angleDelta.y > 0
                ? root.value + step
                : root.value - step

            root.moved(Math.max(0, Math.min(1, next)))
        }
    }
}
