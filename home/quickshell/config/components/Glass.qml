import QtQuick

import "../core" as Core

Item {
    id: glass

    property real radius: 0
    property real strength: 1.0
    property color tint: Core.Theme.accent
    property real tintAmount: Core.Theme.glassGradientOpacity
    property color edgeColor: Core.Theme.glassEdge

    Rectangle {
        anchors.fill: parent

        radius: glass.radius

        antialiasing: true

        opacity: glass.strength

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Core.Theme.glassTintTop
            }

            GradientStop {
                position: 0.5
                color: Core.Theme.glassTintMid
            }

            GradientStop {
                position: 1.0
                color: Core.Theme.glassTintBottom
            }
        }
    }

    Rectangle {
        anchors.fill: parent

        radius: glass.radius

        antialiasing: true

        opacity: glass.strength

        visible: glass.tintAmount > 0.001

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0.0
                color: Qt.rgba(glass.tint.r, glass.tint.g, glass.tint.b, glass.tintAmount)
            }

            GradientStop {
                position: 1.0
                color: Qt.rgba(glass.tint.r, glass.tint.g, glass.tint.b, 0.0)
            }
        }
    }

    Rectangle {
        anchors.fill: parent

        radius: glass.radius

        color: "transparent"

        border.width: 1
        border.color: glass.edgeColor

        antialiasing: true

        opacity: glass.strength
    }
}
