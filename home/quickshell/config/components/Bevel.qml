import QtQuick

import "../core" as Core

// Bevel
//
// The other half of the 3D pass. Elevation puts a surface above the desktop;
// Bevel makes the surface itself look like a moulded object rather than a flat
// patch of colour:
//
//   * a vertical sheen -- light collects on the top face, shadow pools at the
//     bottom, which is what tells the eye where the light is coming from,
//   * a faint inner rim so the edge has thickness,
//   * a catch-light along the top edge and a dark line along the bottom.
//
// Drop it over any Rectangle:
//
//     Bevel {
//         anchors.fill: parent
//         radius: parent.radius
//     }
//
// Set `sunken: true` to flip the light for pressed or recessed surfaces --
// same object, lit from the other side, which is how a widget reads as pushed
// in rather than merely darker.

Item {
    id: bevel

    property real radius: 0

    // Scales the whole effect. Large surfaces want less: a full-size sheen on
    // a big card reads as a gradient background rather than as a highlight.
    property real strength: 1.0

    property bool sunken: false

    // One dial for the entire 3D pass
    //
    // Every alpha below is multiplied by this, so a single number takes the
    // effect up or down across every surface that uses Bevel -- the bar, the
    // popups, the rows, the tiles -- without disturbing their strengths
    // relative to each other. The literals below are the full-strength pass;
    // 0.5 is the toned-down one actually in use. Raise towards 1.0 for more
    // moulding, drop towards 0.25 for nearly flat.
    readonly property real depth: 0.5

    readonly property real weight: bevel.strength * bevel.depth

    // Decoration only: no handlers at all, so this never eats a click even
    // when it is declared after the item's own MouseArea.

    // Sheen
    //
    // Four stops rather than two: fading white straight into black would cross
    // through grey in the middle, which dirties the surface colour. Each half
    // fades out to its own fully transparent colour instead.
    Rectangle {
        anchors.fill: parent

        radius: bevel.radius

        antialiasing: true

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: bevel.sunken ? Qt.rgba(0, 0, 0, 0.20 * bevel.weight) : Qt.rgba(1, 1, 1, 0.10 * bevel.weight)
            }

            GradientStop {
                position: 0.45
                color: bevel.sunken ? Qt.rgba(0, 0, 0, 0) : Qt.rgba(1, 1, 1, 0)
            }

            GradientStop {
                position: 0.55
                color: bevel.sunken ? Qt.rgba(1, 1, 1, 0) : Qt.rgba(0, 0, 0, 0)
            }

            GradientStop {
                position: 1.0
                color: bevel.sunken ? Qt.rgba(1, 1, 1, 0.07 * bevel.weight) : Qt.rgba(0, 0, 0, 0.17 * bevel.weight)
            }
        }
    }

    // Inner rim: gives the edge some thickness.
    Rectangle {
        anchors.fill: parent

        radius: bevel.radius

        color: "transparent"

        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.05 * bevel.weight)

        antialiasing: true
    }

    // Top catch-light
    //
    // A straight hairline inset from the corners by most of the radius, so it
    // stops before the curve starts instead of poking outside it.
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.leftMargin: Math.round(bevel.radius * 0.7) + 1
        anchors.rightMargin: Math.round(bevel.radius * 0.7) + 1

        height: 1

        color: bevel.sunken ? Qt.rgba(0, 0, 0, 0.22 * bevel.weight) : Qt.rgba(1, 1, 1, 0.15 * bevel.weight)
    }

    // Bottom edge
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.leftMargin: Math.round(bevel.radius * 0.7) + 1
        anchors.rightMargin: Math.round(bevel.radius * 0.7) + 1

        height: 1

        color: bevel.sunken ? Qt.rgba(1, 1, 1, 0.10 * bevel.weight) : Qt.rgba(0, 0, 0, 0.20 * bevel.weight)
    }
}
