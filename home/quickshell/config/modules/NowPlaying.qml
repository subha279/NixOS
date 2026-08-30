import QtQuick

import "../core" as Core
import "../services" as Services

Item {
    id: root

    // Set by Clock.qml when audio is playing and the bar is narrow.
    property bool active: false

    readonly property var svc: Services.MprisService

    readonly property bool playing: root.svc.playing

    readonly property bool shown: root.active && root.svc.available

    // --------------------------------------------------
    // Equalizer
    // --------------------------------------------------

    readonly property int visualBarCount: 7

    readonly property int barWidth: 2

    readonly property int barSpacing: 1

    readonly property int eqHeight: 10

    readonly property int barMin: 2

    // 7 × 2px + 6 × 1px = 20px
    readonly property int visualWidth: (root.visualBarCount * root.barWidth) + ((root.visualBarCount - 1) * root.barSpacing)

    width: root.visualWidth

    height: root.eqHeight

    // --------------------------------------------------
    // Cava sampling
    // --------------------------------------------------

    // Pick evenly distributed values from the existing
    // 11-band Cava spectrum.
    //
    // This means Cava still runs at 11 bands, while the
    // UI stays compact.
    function cavaIndex(i) {
        const sourceCount = Services.CavaService.barCount;

        if (sourceCount <= 1)
            return 0;

        return Math.round(i * (sourceCount - 1) / (root.visualBarCount - 1));
    }

    function barLevel(i) {
        return root.playing ? Services.CavaService.level(root.cavaIndex(i)) : 0.0;
    }

    // --------------------------------------------------
    // Theme
    // --------------------------------------------------

    function barColor(i) {
        const t = root.visualBarCount > 1 ? i / (root.visualBarCount - 1) : 0;

        const a = Core.Theme.accent;
        const b = Core.Theme.accentActive;

        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1.0);
    }

    // --------------------------------------------------
    // Cava lifecycle
    // --------------------------------------------------

    Binding {
        target: Services.CavaService
        property: "enabled"
        value: root.shown
    }

    // --------------------------------------------------
    // Reveal
    // --------------------------------------------------

    opacity: root.shown ? 1.0 : 0.0

    visible: root.opacity > 0.01

    Behavior on opacity {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutQuint
        }
    }

    transform: Translate {
        y: root.shown ? 0 : -2

        Behavior on y {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutQuint
            }
        }
    }

    // --------------------------------------------------
    // Bars
    // --------------------------------------------------

    Repeater {
        model: root.visualBarCount

        delegate: Rectangle {
            id: bar

            required property int index

            readonly property real level: root.barLevel(bar.index)

            x: bar.index * (root.barWidth + root.barSpacing)

            width: root.barWidth

            height: root.barMin + ((root.eqHeight - root.barMin) * bar.level)

            // Center vertically.
            // The bars grow/shrink from the middle.
            y: (root.eqHeight - bar.height) / 2

            // Rounded/pill ends.
            radius: width / 2

            antialiasing: true

            color: root.playing ? root.barColor(bar.index) : Core.Theme.foregroundFaint

            Behavior on color {
                ColorAnimation {
                    duration: 180
                    easing.type: Easing.OutQuint
                }
            }

            // Only animate the collapse.
            // During playback Cava itself updates at 60 FPS.
            Behavior on height {
                enabled: !root.playing

                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutQuint
                }
            }
        }
    }
}
