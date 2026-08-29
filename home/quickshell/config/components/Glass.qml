import QtQuick

import "../core" as Core

Item {
    id: glass

    property real radius: 0
    property real strength: 1.0
    property color tint: Core.Theme.accent
    property real tintAmount: Core.Theme.glassGradientOpacity
    property color edgeColor: Core.Theme.glassEdge

    function washed(base, amount) {
        return Qt.rgba(base.r + (glass.tint.r - base.r) * amount, base.g + (glass.tint.g - base.g) * amount, base.b + (glass.tint.b - base.b) * amount, base.a);
    }

    Rectangle {
        anchors.fill: parent

        radius: glass.radius

        antialiasing: true

        opacity: glass.strength

        border.width: 1
        border.color: glass.edgeColor

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: glass.washed(Core.Theme.glassTintTop, glass.tintAmount * 1.8)
            }

            GradientStop {
                position: 0.5
                color: glass.washed(Core.Theme.glassTintMid, glass.tintAmount * 1.0)
            }

            GradientStop {
                position: 1.0
                color: glass.washed(Core.Theme.glassTintBottom, glass.tintAmount * 0.35)
            }
        }
    }
}
