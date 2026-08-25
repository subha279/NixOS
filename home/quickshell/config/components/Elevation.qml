import QtQuick

import "../core" as Core

// Stacked drop shadow: three rings, widest and faintest first, so the darkness
// builds towards the surface instead of ending in a hard edge.
//
// Use as a SIBLING of the surface, never a child -- surfaces that scale turn on
// layer caching, and a layer clips to its own bounds, shaving off the shadow.
//
// Levels: 0.6 chip on a panel, 1.0 resting widget, 1.6 floating panel, 2.2 modal.

Item {
    id: elevation

    property real level: 1.0

    property real radius: 0

    // One dial for the whole pass; per-surface `level` stays a relative weight.
    readonly property real depth: 0.9

    readonly property real spread: Core.Theme.shellShadowSpread * elevation.level * 0.8

    // Darkness saturates: past a point more opacity just reads as a black box.
    readonly property real strength: Math.min(1.8, elevation.level)

    readonly property real weight: elevation.strength * elevation.depth

    // Always behind its siblings, and no handlers, so clicks fall through.
    z: -1

    // Rings, not fills. Each rect is inflated past the surface by its own margin
    // and draws only that margin as a border, so the annulus outside is painted
    // and the surface's own footprint is left clear. Qt draws borders inwards, so
    // `radius - width` puts the inner corner exactly on the surface's radius.
    // Filled rects would show through translucent Glass as a black veil.

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Math.round(elevation.spread * 1.5)

        radius: elevation.radius + Math.round(elevation.spread * 1.5)

        color: "transparent"

        border.width: Math.round(elevation.spread * 1.5)
        border.color: "#000000"

        opacity: Core.Theme.shellShadowOpacity * 0.15 * elevation.weight

        antialiasing: true
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Math.round(elevation.spread * 0.85)

        radius: elevation.radius + Math.round(elevation.spread * 0.85)

        color: "transparent"

        border.width: Math.round(elevation.spread * 0.85)
        border.color: "#000000"

        opacity: Core.Theme.shellShadowOpacity * 0.30 * elevation.weight

        antialiasing: true
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Math.max(1, Math.round(elevation.spread * 0.4))

        radius: elevation.radius + Math.max(1, Math.round(elevation.spread * 0.4))

        color: "transparent"

        border.width: Math.max(1, Math.round(elevation.spread * 0.4))
        border.color: "#000000"

        opacity: Core.Theme.shellShadowOpacity * 0.55 * elevation.weight

        antialiasing: true
    }
}
