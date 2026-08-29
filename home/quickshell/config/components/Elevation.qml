import QtQuick

import "../core" as Core

Item {
    id: elevation

    property real level: 1.0
    property real radius: 0

    readonly property real spread: Core.Theme.shellShadowSpread * Math.min(2.0, elevation.level)

    readonly property real weight: Core.Theme.shellShadowOpacity * Math.min(1.6, elevation.level)

    z: -1

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Math.round(elevation.spread)

        radius: elevation.radius + Math.round(elevation.spread)

        color: "transparent"

        border.width: Math.round(elevation.spread)
        border.color: "#000000"

        opacity: elevation.weight * 0.20

        antialiasing: true
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Math.round(elevation.spread * 0.5)

        radius: elevation.radius + Math.round(elevation.spread * 0.5)

        color: "transparent"

        border.width: Math.round(elevation.spread * 0.5)
        border.color: "#000000"

        opacity: elevation.weight * 0.45

        antialiasing: true
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Math.max(1, Math.round(elevation.spread * 0.2))

        radius: elevation.radius + Math.max(1, Math.round(elevation.spread * 0.2))

        color: "transparent"

        border.width: Math.max(1, Math.round(elevation.spread * 0.2))
        border.color: "#000000"

        opacity: elevation.weight * 0.70

        antialiasing: true
    }
}
