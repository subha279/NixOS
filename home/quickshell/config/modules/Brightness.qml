import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import "../core" as Core

Item {
    id: root

    implicitWidth: 58
    implicitHeight: Core.Theme.moduleHeight

    property int level: 0

    Process {
        id: getBrightness

        command: [
            "brightnessctl",
            "-m"
        ]

        stdout: StdioCollector {
            onStreamFinished: {

                const output =
                    text.trim()

                const match =
                    output.match(/,(\d+)%/)

                if (match) {
                    root.level =
                        parseInt(match[1])
                }
            }
        }
    }

    function refresh() {
        getBrightness.running = false
        getBrightness.running = true
    }

    function change(amount) {

        Quickshell.execDetached([
            "brightnessctl",
            "-e4",
            "-n2",
            "set",
            amount
        ])

        refresh()
    }

    Component.onCompleted:
        refresh()

    Timer {
        interval: 500

        running: true
        repeat: true

        onTriggered:
            root.refresh()
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
            text: "󰃠"

            font.family:
                Core.Theme.fontFamily

            font.pixelSize:
                Core.Theme.iconSize

            color:
                Core.Theme.accent
        }

        Text {
            text:
                root.level + "%"

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
            Qt.LeftButton

        onWheel: function(event) {

            if (event.angleDelta.y > 0)
                root.change("5%+")
            else
                root.change("5%-")
        }

        onClicked:
            root.change("5%+")
    }
}
