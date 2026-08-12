import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.Pipewire

import "../core" as Core

Item {
    id: root

    implicitWidth: 58
    implicitHeight: Core.Theme.moduleHeight

    property var sink:
        Pipewire.defaultAudioSink

    PwObjectTracker {
        objects:
            root.sink ? [root.sink] : []
    }

    Rectangle {
        anchors.fill: parent

        radius: height / 2

        color:
            mouse.containsMouse
                ? Core.Theme.hover
                : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    RowLayout {
        anchors.centerIn: parent

        spacing: 5

        Text {
            text: {

                if (!root.sink ||
                    !root.sink.audio)
                    return "󰖁"

                if (root.sink.audio.muted)
                    return "󰖁"

                if (root.sink.audio.volume <= 0.01)
                    return "󰕿"

                if (root.sink.audio.volume < 0.5)
                    return "󰖀"

                return "󰕾"
            }

            font.family:
                Core.Theme.fontFamily

            font.pixelSize:
                Core.Theme.iconSize

            color:
                root.sink &&
                root.sink.audio &&
                root.sink.audio.muted
                    ? Core.Theme.foregroundMuted
                    : Core.Theme.foreground
        }

        Text {
            text: {

                if (!root.sink ||
                    !root.sink.audio)
                    return "0%"

                return Math.round(
                    root.sink.audio.volume * 100
                ) + "%"
            }

            font.family:
                Core.Theme.fontFamily

            font.pixelSize:
                Core.Theme.fontSize

            font.weight:
                Font.Medium

            color:
                Core.Theme.foreground
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor

        acceptedButtons:
            Qt.LeftButton |
            Qt.RightButton

        onClicked: function(event) {

            if (!root.sink ||
                !root.sink.audio)
                return

            if (event.button === Qt.LeftButton) {
                root.sink.audio.muted =
                    !root.sink.audio.muted
            }

            if (event.button === Qt.RightButton) {
                Quickshell.execDetached([
                    "pavucontrol"
                ])
            }
        }

        onWheel: function(event) {

            if (!root.sink ||
                !root.sink.audio)
                return

            const step = 0.05

            if (event.angleDelta.y > 0) {

                root.sink.audio.volume =
                    Math.min(
                        1.0,
                        root.sink.audio.volume + step
                    )

            } else {

                root.sink.audio.volume =
                    Math.max(
                        0.0,
                        root.sink.audio.volume - step
                    )
            }
        }
    }
}
