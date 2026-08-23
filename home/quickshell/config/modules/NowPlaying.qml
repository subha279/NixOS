import QtQuick

import "../core" as Core
import "../services" as Services

// Now playing indicator -- CAVA style
//
// A miniature spectrum analyser: eleven uniform 2px bars separated by 1px
// gutters, flat topped, packed tight. Uniform width is the whole point of the
// look -- the earlier mix of 1px and 2px bars read as a hand-drawn squiggle
// rather than a spectrum. The two accent tints now sweep ACROSS the strip
// instead of alternating, which is where cava's colour gradient comes from.
//
// 32px wide, 7px tall: long and low, under a 48px clock module, so it still
// cannot change the size of the bar pill.
//
// Not a chip and not a panel: no background, no shadow, no click target. It is
// a bare strip that lives inside an existing module -- see Clock.qml.

Item {
    id: root

    // Set by the host module. Clock.qml gates this on "audio is playing AND the
    // bar is narrow", so the indicator is absent the rest of the time.
    property bool active: false

    readonly property var svc: Services.MprisService

    // The real playback state, which drives the motion.
    readonly property bool playing: root.svc.playing

    readonly property bool shown: root.active && root.svc.available

    // Bar profile
    //
    // Heights lean left, the way a real spectrum sits when the bass is loudest,
    // and the tallest bar is deliberately the SECOND one rather than the middle
    // one. A peak in the exact centre made the strip read as a symmetrical
    // hill, which looks like a decoration rather than a meter.
    //
    // The durations are all different and share no tidy common multiple, so the
    // bars drift permanently out of phase instead of falling into a marching
    // pattern -- no phase bookkeeping and no driving timer, just eleven loops
    // of different lengths.

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

    // Geometry

    readonly property int barWidth: 2

    readonly property int barSpacing: 1

    readonly property int eqHeight: 7

    readonly property int barCount: root.bars.length

    // 11 bars of 2px plus 10 gutters of 1px = 32px.
    width: (root.barCount * root.barWidth) + ((root.barCount - 1) * root.barSpacing)

    height: root.eqHeight

    // Colour sweep
    //
    // Interpolates the two theme accents from one end of the strip to the
    // other. Reading Theme inside the function still registers the dependency,
    // so the whole strip recolours when you switch themes.
    function barColor(i) {
        const t = root.barCount > 1 ? i / (root.barCount - 1) : 0;

        const a = Core.Theme.accent;
        const b = Core.Theme.accentActive;

        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1.0);
    }

    // Reveal

    opacity: root.shown ? 1.0 : 0.0

    visible: root.opacity > 0.01

    Behavior on opacity {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutQuint
        }
    }

    // Rises into place instead of blinking on. Pausing and resuming reads as a
    // soft pulse rather than a flicker, which also covers the players that dip
    // to Paused for a moment while loading the next track.
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

            // Bars grow upward off a shared baseline.
            y: root.eqHeight - bar.height

            // Square tops on purpose. Rounding a 2px bar turns the cap into a
            // semicircle and loses the spectrum-analyser read entirely.
            radius: 0

            color: root.playing ? root.barColor(bar.index) : Core.Theme.foregroundFaint

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuint
                }
            }

            // Runs only while audio is actually playing.
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

            // Paused: settle into a flat, dim line rather than freezing
            // mid-bounce, so the fade-out never catches it at full height.
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
