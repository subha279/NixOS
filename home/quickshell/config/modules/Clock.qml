import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services

// Clock (bar module)

Item {
    id: root

    implicitWidth: showSeconds ? 72 : 48
    implicitHeight: Core.Theme.moduleHeight

    property bool showSeconds: false

    // Mirrors the bar's reveal: 0 while narrow, 1 while wide. Set by Bar.qml.
    property real reveal: 0

    readonly property bool menuOpen: Core.PopupManager.isOpen("calendar")

    // Now playing
    //
    // The equalizer tucks in underneath the time, inside the pill, and exists
    // only while audio is playing AND the bar is narrow -- so it is absent
    // almost all of the time, and never once the bar expands.
    //
    // The pill is not made taller and the clock is not made wider to fit it.
    // The time lifts a few pixels instead and the indicator uses the slack,
    // which keeps the bar exactly the size it has always been.

    readonly property bool nowPlayingShown: Services.MprisService.playing && root.reveal <= 0.012

    // Half the vertical space the indicator occupies, so the time and the bars
    // stay optically centred in the module as a pair.
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

        color: root.menuOpen ? Core.Theme.surfaceActive : (mouse.containsMouse ? Core.Theme.hover : "transparent")

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

    // Now playing equalizer, tucked under the time.
    //
    // Deliberately has no MouseArea of its own: the clock's existing click
    // target still covers this strip, so clicking here opens the calendar
    // exactly as it did before.

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
