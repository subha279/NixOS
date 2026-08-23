import QtQuick

import Quickshell

import "../core" as Core
import "../components" as Components

// CalendarPopup

Components.PopupSurface {
    id: popup

    popupId: "calendar"

    cardWidth: 320
    maxCardHeight: 420

    // Seconds precision is only worth the wakeups while visible.
    SystemClock {
        id: clock

        precision: popup.open ? SystemClock.Seconds : SystemClock.Minutes
    }

    readonly property date now: clock.date

    // Which month the grid is showing. 0 = current month.
    property int monthOffset: 0

    // Reset to today whenever the popup is dismissed, so it always opens on the current month.
    onDidClose: popup.monthOffset = 0

    readonly property date viewDate: {
        const d = new Date(popup.now);

        d.setDate(1);
        d.setMonth(d.getMonth() + popup.monthOffset);

        return d;
    }

    readonly property int viewYear: popup.viewDate.getFullYear()
    readonly property int viewMonth: popup.viewDate.getMonth()

    readonly property string monthLabel: Qt.formatDate(popup.viewDate, "MMMM yyyy")

    // Monday-first weekday index of the 1st of the shown month.
    readonly property int leadingBlanks: {
        const first = new Date(popup.viewYear, popup.viewMonth, 1);

        // getDay(): 0 = Sunday. Shift so Monday = 0.
        return (first.getDay() + 6) % 7;
    }

    readonly property int daysInMonth: new Date(popup.viewYear, popup.viewMonth + 1, 0).getDate()

    // Always render 6 rows so the card does not jitter in height as you page between months.
    readonly property int cellCount: 42

    function isToday(day) {
        if (day <= 0)
            return false;

        return popup.viewYear === popup.now.getFullYear() && popup.viewMonth === popup.now.getMonth() && day === popup.now.getDate();
    }

    function isWeekend(index) {
        const col = index % 7;

        return col === 5 || col === 6;
    }

    // Day number for a cell index, or 0 for a padding cell.
    function dayFor(index) {
        const day = index - popup.leadingBlanks + 1;

        if (day < 1 || day > popup.daysInMonth)
            return 0;

        return day;
    }

    contentComponent: Component {

        Column {
            id: body

            spacing: Core.Theme.spacing

            // Big clock

            Item {
                width: parent.width
                height: 68

                Column {
                    anchors.centerIn: parent

                    spacing: 2

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: Qt.formatDateTime(popup.now, "HH:mm")

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: 34
                        font.weight: Font.DemiBold

                        color: Core.Theme.foreground

                        renderType: Text.NativeRendering
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: Qt.formatDate(popup.now, "dddd, d MMMM yyyy")

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: Core.Theme.fontSizeSmall

                        color: Core.Theme.foregroundMuted
                    }
                }

                // Seconds ring in the corner, purely decorative.
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.top: parent.top
                    anchors.topMargin: 4

                    text: Qt.formatDateTime(popup.now, "ss")

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.foregroundFaint
                }
            }

            Rectangle {
                width: parent.width
                height: 1

                color: Core.Theme.separator
            }

            // Month navigation

            Item {
                id: monthBar

                width: parent.width
                height: 32

                Rectangle {
                    id: prevBtn

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    width: 28
                    height: 28

                    radius: 14

                    color: prevMouse.containsMouse ? Core.Theme.surfaceHover : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                            easing.type: Easing.OutQuint
                        }
                    }

                    scale: prevMouse.pressed ? 0.88 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 110
                            easing.type: Easing.OutQuint
                        }
                    }

                    Text {
                        anchors.centerIn: parent

                        text: "\udb80\udd41"

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: 14

                        color: Core.Theme.foregroundMuted
                    }

                    MouseArea {
                        id: prevMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor

                        onClicked: popup.monthOffset -= 1
                    }
                }

                Text {
                    id: monthText

                    anchors.centerIn: parent

                    text: popup.monthLabel

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeLarge
                    font.weight: Font.DemiBold

                    color: Core.Theme.foreground

                    // Little pop whenever the month changes.
                    onTextChanged: monthPop.restart()

                    SequentialAnimation {
                        id: monthPop

                        NumberAnimation {
                            target: monthText
                            property: "scale"
                            to: 1.08
                            duration: 90
                            easing.type: Easing.OutQuint
                        }

                        NumberAnimation {
                            target: monthText
                            property: "scale"
                            to: 1.0
                            duration: 160
                            easing.type: Easing.OutQuint
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8

                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor

                        // Click the month name to jump back to today.
                        onClicked: popup.monthOffset = 0
                    }
                }

                Rectangle {
                    id: nextBtn

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    width: 28
                    height: 28

                    radius: 14

                    color: nextMouse.containsMouse ? Core.Theme.surfaceHover : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                            easing.type: Easing.OutQuint
                        }
                    }

                    scale: nextMouse.pressed ? 0.88 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 110
                            easing.type: Easing.OutQuint
                        }
                    }

                    Text {
                        anchors.centerIn: parent

                        text: "\udb80\udd42"

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: 14

                        color: Core.Theme.foregroundMuted
                    }

                    MouseArea {
                        id: nextMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor

                        onClicked: popup.monthOffset += 1
                    }
                }

                // Scroll anywhere on the header to page months.
                MouseArea {
                    anchors.fill: parent

                    acceptedButtons: Qt.NoButton

                    onWheel: function (event) {
                        if (event.angleDelta.y > 0)
                            popup.monthOffset -= 1;
                        else
                            popup.monthOffset += 1;
                    }
                }
            }

            // Weekday labels

            Row {
                id: weekdayRow

                width: parent.width

                readonly property real cell: width / 7

                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                    delegate: Item {
                        required property string modelData
                        required property int index

                        width: weekdayRow.cell
                        height: 20

                        Text {
                            anchors.centerIn: parent

                            text: parent.modelData

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: Core.Theme.fontSizeSmall
                            font.weight: Font.DemiBold

                            color: (parent.index === 5 || parent.index === 6) ? Core.Theme.accentSoft : Core.Theme.foregroundFaint
                        }
                    }
                }
            }

            // Day grid

            Grid {
                id: dayGrid

                width: parent.width

                columns: 7

                readonly property real cell: width / 7

                Repeater {
                    model: popup.cellCount

                    delegate: Item {
                        id: dayCell

                        required property int index

                        readonly property int day: popup.dayFor(dayCell.index)

                        readonly property bool filled: dayCell.day > 0

                        readonly property bool today: popup.isToday(dayCell.day)

                        width: dayGrid.cell
                        height: 32

                        Rectangle {
                            id: dayBg

                            anchors.centerIn: parent

                            width: 28
                            height: 28

                            radius: 14

                            visible: dayCell.filled

                            color: dayCell.today ? Core.Theme.accent : (dayMouse.containsMouse ? Core.Theme.surfaceHover : "transparent")

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                    easing.type: Easing.OutQuint
                                }
                            }

                            // Today's marker springs in on open.
                            scale: dayCell.today ? 1.0 : 1.0

                            Component.onCompleted: {
                                if (!dayCell.today)
                                    return;
                                todayPop.restart();
                            }

                            SequentialAnimation {
                                id: todayPop

                                NumberAnimation {
                                    target: dayBg
                                    property: "scale"
                                    from: 0.0
                                    to: 1.0
                                    duration: 180
                                    easing.type: Easing.OutQuint
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            visible: dayCell.filled

                            text: dayCell.filled ? dayCell.day : ""

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: Core.Theme.fontSize

                            font.weight: dayCell.today ? Font.DemiBold : Font.Normal

                            color: dayCell.today ? Core.Theme.accentForeground : (popup.isWeekend(dayCell.index) ? Core.Theme.foregroundMuted : Core.Theme.foreground)
                        }

                        MouseArea {
                            id: dayMouse

                            anchors.fill: parent

                            enabled: dayCell.filled

                            hoverEnabled: true

                            cursorShape: dayCell.filled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }
            }

            // Footer

            Item {
                width: parent.width
                height: popup.monthOffset === 0 ? 0 : 30

                visible: height > 0

                Behavior on height {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutQuint
                    }
                }

                Rectangle {
                    anchors.centerIn: parent

                    width: 100
                    height: 26

                    radius: 13

                    color: todayMouse.containsMouse ? Core.Theme.surfaceHover : Core.Theme.surface

                    Text {
                        anchors.centerIn: parent

                        text: "\udb80\udced  Today"

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: Core.Theme.fontSizeSmall

                        color: Core.Theme.foreground
                    }

                    MouseArea {
                        id: todayMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor

                        onClicked: popup.monthOffset = 0
                    }
                }
            }
        }
    }
}
