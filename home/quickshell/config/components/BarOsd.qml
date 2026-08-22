import QtQuick

import "../core" as Core

// ================================================================
// BarOsd
// ----------------------------------------------------------------
// The readout the bar shows while it is acting as an OSD. It sits
// in the same slot as the module row and only one of the two is
// ever visible.
//
// Every part has a FIXED width. The pill sizes itself from this
// item, so a label that grew from "9%" to "100%" would make the
// whole bar jitter mid-drag. Fixed widths mean the pill takes one
// shape when the OSD appears and holds it until it leaves.
// ================================================================

Item {
    id: root

    readonly property string kind: Core.OsdController.kind

    readonly property real value: Core.OsdController.value

    readonly property bool muted: Core.OsdController.muted

    implicitWidth: row.implicitWidth
    implicitHeight: Core.Theme.moduleHeight

    // ------------------------------------------------------------
    // Colour + glyph per kind
    // ------------------------------------------------------------

    readonly property color tint: root.muted ? Core.Theme.danger : Core.Theme.accent

    readonly property string glyph: {
        if (root.kind === "brightness")
            return Core.Icons.forBrightness(root.value);

        if (root.kind === "mic")
            return root.muted ? Core.Icons.micOff : Core.Icons.mic;

        if (root.muted)
            return Core.Icons.volumeOff;

        if (root.value >= 0.66)
            return Core.Icons.volumeHigh;

        if (root.value >= 0.33)
            return Core.Icons.volumeMedium;

        return Core.Icons.volumeLow;
    }

    Row {
        id: row

        anchors.centerIn: parent

        spacing: 8

        // --------------------------------------------------------
        // Icon
        // --------------------------------------------------------

        Text {
            width: 20

            anchors.verticalCenter: parent.verticalCenter

            horizontalAlignment: Text.AlignHCenter

            text: root.glyph

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.iconSize

            color: root.tint

            Behavior on color {
                ColorAnimation {
                    duration: Core.Theme.durFast
                }
            }
        }

        // --------------------------------------------------------
        // Track
        // --------------------------------------------------------

        Rectangle {
            id: track

            width: 96
            height: 4

            anchors.verticalCenter: parent.verticalCenter

            radius: 2

            color: Core.Theme.surface

            Rectangle {
                id: fill

                height: parent.height

                radius: parent.radius

                width: Math.round(track.width * root.value)

                color: root.tint

                antialiasing: true

                // The one animated thing in here. Holding a volume
                // key sends a burst of small changes and this is
                // what turns them into one continuous slide.
                Behavior on width {
                    NumberAnimation {
                        duration: Core.Theme.durBase
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Core.Theme.durFast
                    }
                }
            }
        }

        // --------------------------------------------------------
        // Readout
        // --------------------------------------------------------

        Text {
            width: 34

            anchors.verticalCenter: parent.verticalCenter

            horizontalAlignment: Text.AlignRight

            text: root.muted && root.kind !== "brightness" ? "off" : Math.round(root.value * 100) + "%"

            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize
            font.weight: Font.Medium

            color: Core.Theme.foreground

            renderType: Text.QtRendering
        }
    }
}
