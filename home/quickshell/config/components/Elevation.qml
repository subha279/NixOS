import QtQuick

import "../core" as Core


Item {
    id: elevation

    property real level: 1.0

    property real radius: 0

    readonly property real depth: 0.9

    readonly property real spread: Core.Theme.shellShadowSpread * elevation.level * 0.8

    readonly property real strength: Math.min(1.8, elevation.level)

    readonly property real weight: elevation.strength * elevation.depth

    z: -1


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
