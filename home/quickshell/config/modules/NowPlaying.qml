import QtQuick

import "../core" as Core
import "../services" as Services


Item {
    id: root

    // Set by the host module. Clock.qml gates this on "audio is playing AND the
    // bar is narrow", so the indicator is absent the rest of the time.
    property bool active: false

    readonly property var svc: Services.MprisService

    // The real playback state, which drives the motion.
    readonly property bool playing: root.svc.playing

    readonly property bool shown: root.active && root.svc.available

    // Geometry

    readonly property int barWidth: 2

    readonly property int barSpacing: 1

    readonly property int eqHeight: 7

    // Idle size. Equal to barWidth so a silent bar is a dot rather than a
    // sliver, which is what keeps the rounded cap reading as a cap.
    readonly property int barMin: root.barWidth

    readonly property int barCount: Services.CavaService.barCount

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

    // cava only decodes while the strip is on screen.
    Binding {
        target: Services.CavaService
        property: "enabled"
        value: root.shown
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
        model: root.barCount

        delegate: Rectangle {
            id: bar

            required property int index

            // Paused collapses to silence rather than freezing mid-frame, so
            // the fade-out never catches the strip at full height.
            readonly property real level: root.playing ? Services.CavaService.level(bar.index) : 0.0

            x: bar.index * (root.barWidth + root.barSpacing)

            width: root.barWidth

            height: root.barMin + ((root.eqHeight - root.barMin) * bar.level)

            // Grows from the centre line in both directions instead of off a
            // baseline, so the strip is mirrored top to bottom.
            y: (root.eqHeight - bar.height) / 2

            // Full pill caps. At 2px wide the radius is 1, which is the whole
            // width, so both ends are semicircles.
            radius: root.barWidth / 2

            antialiasing: true

            color: root.playing ? root.barColor(bar.index) : Core.Theme.foregroundFaint

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuint
                }
            }

            // Settling to silence is animated; rising is not. cava's own
            // noise_reduction already smooths the incoming frames, and a
            // Behavior on the way up would queue an animation per frame at
            // 60fps and lag behind the audio.
            Behavior on height {
                enabled: !root.playing

                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutQuint
                }
            }
        }
    }
}
