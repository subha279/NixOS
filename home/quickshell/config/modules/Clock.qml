import QtQuick

import Quickshell

import "../core" as Core

Item {
    id: root

    implicitWidth: 48
    implicitHeight:
        Core.Theme.moduleHeight

    SystemClock {
        id: systemClock

        precision:
            SystemClock.Minutes
    }

    Text {
        anchors.centerIn: parent

        text:
            Qt.formatDateTime(
                systemClock.date,
                "HH:mm"
            )

        color:
            Core.Theme.foreground

        font.family:
            Core.Theme.fontFamily

        font.pixelSize:
            Core.Theme.fontSize

        font.weight:
            Font.Medium

        renderType:
            Text.NativeRendering
    }
}
