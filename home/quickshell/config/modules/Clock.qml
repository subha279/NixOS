import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services


Item {
    id: root

    implicitWidth: showSeconds ? 72 : 48
    implicitHeight: Core.Theme.moduleHeight

    property bool showSeconds: false

    property real reveal: 0

    readonly property bool menuOpen: Core.PopupManager.isOpen("calendar")


    readonly property bool nowPlayingShown: Services.MprisService.playing && root.reveal <= 0.012

    property real timeLift: root.nowPlayingShown ? -5 : 0

    Behavior on timeLift {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutQuint
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuint
        }
    }

    SystemClock {
        id: systemClock

        precision: root.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    Rectangle {
        anchors.fill: parent

        radius: height / 2

        color: root.menuOpen ? Core.Theme.surfaceGlass : (mouse.containsMouse ? Core.Theme.surfaceGlassHover : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: 120
                easing.type: Easing.OutQuint
            }
        }
    }

    Row {
        id: timeRow

        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.timeLift

        spacing: 0

        Text {
            text: Qt.formatDateTime(systemClock.date, "HH")

            color: root.menuOpen ? Core.Theme.accent : Core.Theme.clockHour

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            renderType: Text.QtRendering

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutQuint
                }
            }
        }

        Text {
            text: ":"

            color: root.menuOpen ? Core.Theme.accent : Core.Theme.clockSeparator

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            renderType: Text.QtRendering

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutQuint
                }
            }
        }

        Text {
            text: Qt.formatDateTime(systemClock.date, "mm")

            color: root.menuOpen ? Core.Theme.accent : Core.Theme.clockMinute

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            renderType: Text.QtRendering

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutQuint
                }
            }
        }

        Text {
            visible: root.showSeconds

            text: ":"

            color: Core.Theme.clockSeparator

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            renderType: Text.QtRendering
        }

        Text {
            visible: root.showSeconds

            text: Qt.formatDateTime(systemClock.date, "ss")

            color: Core.Theme.clockSecond

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            renderType: Text.QtRendering
        }
    }


    NowPlaying {
        anchors.top: timeRow.bottom
        anchors.topMargin: 2

        anchors.horizontalCenter: parent.horizontalCenter

        active: root.nowPlayingShown
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function (event) {
            if (event.button === Qt.RightButton) {
                root.showSeconds = !root.showSeconds;
                return;
            }

            const p = root.mapToItem(null, 0, root.height);

            Core.PopupManager.toggle("calendar", p.x + root.width / 2, p.y + Core.Theme.barMarginTop);
        }
    }
}
