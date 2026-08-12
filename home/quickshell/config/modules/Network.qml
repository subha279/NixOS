import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import "../core" as Core

Item {
    id: root

    implicitWidth: 30
    implicitHeight: Core.Theme.moduleHeight

    property bool connected: false
    property int signal: 0
    property bool wifiEnabled: true

    // ============================================================
    // Network state
    // ============================================================

    Process {
        id: networkStatus

        command: [
            "nmcli",
            "-t",
            "-f",
            "TYPE,STATE",
            "device"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")

                root.connected = false

                for (const line of lines) {
                    if (line.startsWith("wifi:connected")) {
                        root.connected = true
                        break
                    }
                }
            }
        }
    }

    // ============================================================
    // Wi-Fi signal
    // ============================================================

    Process {
        id: wifiSignal

        command: [
            "nmcli",
            "-t",
            "-f",
            "IN-USE,SIGNAL",
            "device",
            "wifi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")

                root.signal = 0

                for (const line of lines) {
                    if (line.startsWith("*:")) {
                        const parts = line.split(":")

                        if (parts.length >= 2) {
                            root.signal =
                                parseInt(parts[1]) || 0
                        }

                        break
                    }
                }
            }
        }
    }

    // ============================================================
    // Wi-Fi radio
    // ============================================================

    Process {
        id: wifiRadio

        command: [
            "nmcli",
            "radio",
            "wifi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled =
                    text.trim() === "enabled"
            }
        }
    }

    function refresh() {
        networkStatus.running = false
        networkStatus.running = true

        wifiSignal.running = false
        wifiSignal.running = true

        wifiRadio.running = false
        wifiRadio.running = true
    }

    Component.onCompleted:
        refresh()

    Timer {
        interval: 2000

        running: true
        repeat: true

        onTriggered:
            root.refresh()
    }

    // ============================================================
    // UI
    // ============================================================

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

    Text {
        anchors.centerIn: parent

        text: {

            if (!root.wifiEnabled)
                return "󰤭"

            if (!root.connected)
                return "󰤯"

            if (root.signal >= 75)
                return "󰤨"

            if (root.signal >= 50)
                return "󰤥"

            if (root.signal >= 25)
                return "󰤢"

            return "󰤟"
        }

        font.family:
            Core.Theme.fontFamily

        font.pixelSize:
            Core.Theme.iconSize

        color:
            !root.wifiEnabled ||
            !root.connected
                ? Core.Theme.foregroundMuted
                : Core.Theme.foreground

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor

        onClicked: {

            // Keep nm-applet as the actual
            // network management interface.
            Quickshell.execDetached([
                "nm-connection-editor"
            ])
        }
    }
}
