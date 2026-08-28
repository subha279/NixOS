import QtQuick

import "../core" as Core
import "../services" as Services


Item {
    id: root

    property bool active: false

    readonly property var svc: Services.MprisService

    readonly property bool playing: root.svc.playing

    readonly property bool shown: root.active && root.svc.available


    readonly property var bars: [
        {
            "min": 3,
            "max": 6,
            "dur": 620
        },
        {
            "min": 4,
            "max": 7,
            "dur": 540
        },
        {
            "min": 2,
            "max": 6,
            "dur": 710
        },
        {
            "min": 3,
            "max": 5,
            "dur": 460
        },
        {
            "min": 1,
            "max": 5,
            "dur": 660
        },
        {
            "min": 2,
            "max": 4,
            "dur": 580
        },
        {
            "min": 1,
            "max": 4,
            "dur": 500
        },
        {
            "min": 1,
            "max": 3,
            "dur": 690
        },
        {
            "min": 2,
            "max": 3,
            "dur": 430
        },
        {
            "min": 1,
            "max": 2,
            "dur": 610
        },
        {
            "min": 1,
            "max": 2,
            "dur": 530
        }
    ]


    readonly property int barWidth: 2

    readonly property int barSpacing: 1

    readonly property int eqHeight: 7

    readonly property int barCount: root.bars.length

    width: (root.barCount * root.barWidth) + ((root.barCount - 1) * root.barSpacing)

    height: root.eqHeight

    function barColor(i) {
        const t = root.barCount > 1 ? i / (root.barCount - 1) : 0;

        const a = Core.Theme.accent;
        const b = Core.Theme.accentActive;

        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1.0);
    }


    opacity: root.shown ? 1.0 : 0.0

    visible: root.opacity > 0.01

    Behavior on opacity {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutQuint
        }
    }

    transform: Translate {
        y: root.shown ? 0 : -3

        Behavior on y {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutQuint
            }
        }
    }

    Repeater {
        model: root.bars

        delegate: Rectangle {
            id: bar

            required property int index

            required property var modelData

            x: bar.index * (root.barWidth + root.barSpacing)

            width: root.barWidth

            height: bar.modelData.min

            y: root.eqHeight - bar.height

            radius: 0

            color: root.playing ? root.barColor(bar.index) : Core.Theme.foregroundFaint

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuint
                }
            }

            SequentialAnimation {
                running: root.playing

                loops: Animation.Infinite

                NumberAnimation {
                    target: bar
                    property: "height"
                    to: bar.modelData.max
                    duration: bar.modelData.dur
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    target: bar
                    property: "height"
                    to: bar.modelData.min
                    duration: bar.modelData.dur
                    easing.type: Easing.InOutSine
                }
            }

            NumberAnimation {
                running: !root.playing

                target: bar
                property: "height"
                to: 1
                duration: 260
                easing.type: Easing.OutQuint
            }
        }
    }
}
