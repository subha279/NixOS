import QtQuick

import "../core" as Core

// Elevation
//
// The stacked drop shadow that lifts a surface off the desktop. Three rings,
// widest and faintest first, so the darkness builds up towards the surface
// instead of ending in a hard edge. Quickshell has no blur primitive, so
// stacked translucent rounded rectangles are the cheap way to fake one -- no
// shader, no offscreen pass.
//
// Use it as a SIBLING of the surface, never as a child. Surfaces that scale
// turn on layer caching, and a layer clips to the item's own bounds, which
// would shave off any shadow drawn past the edge.
//
//     Elevation {
//         anchors.fill: card
//         radius: card.radius
//         level: 1.6
//     }
//
// Levels roughly: 0.6 a chip sitting on a panel, 1.0 a resting widget,
// 1.6 a floating panel, 2.2 something modal.

Item {
    id: elevation

    property real level: 1.0

    property real radius: 0

    // One dial for every shadow in the shell
    //
    // Same idea as Bevel.depth: turn the whole 3D pass up or down from one
    // place, leaving the per-surface levels as relative weights. 1.0 is the
    // full-strength pass; 0.55 is the toned-down one in use.
    readonly property real depth: 0.55

    // Tightened along with the opacity. A wide, faint shadow still reads as a
    // big soft halo; pulling the footprint in is most of what makes the effect
    // subtle rather than merely fainter.
    readonly property real spread: Core.Theme.shellShadowSpread * elevation.level * 0.8

    // Darkness saturates: past a point more opacity just reads as a black box.
    readonly property real strength: Math.min(1.8, elevation.level)

    readonly property real weight: elevation.strength * elevation.depth

    // Always behind its siblings, wherever it gets used.
    z: -1

    // Decoration only -- no handlers, so clicks fall through to whatever is
    // underneath.

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Math.round(elevation.spread * 1.5)

        radius: elevation.radius + Math.round(elevation.spread * 1.5)

        color: "#000000"

        opacity: Core.Theme.shellShadowOpacity * 0.15 * elevation.weight

        antialiasing: true
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Math.round(elevation.spread * 0.85)

        radius: elevation.radius + Math.round(elevation.spread * 0.85)

        color: "#000000"

        opacity: Core.Theme.shellShadowOpacity * 0.30 * elevation.weight

        antialiasing: true
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Math.max(1, Math.round(elevation.spread * 0.4))

        radius: elevation.radius + Math.max(1, Math.round(elevation.spread * 0.4))

        color: "#000000"

        opacity: Core.Theme.shellShadowOpacity * 0.55 * elevation.weight

        antialiasing: true
    }
}
