import QtQuick

import "../core" as Core

Item {
    id: glass

    property real radius: 0
    property real strength: 1.0
    property color tint: Core.Theme.accent
    property real tintAmount: Core.Theme.glassGradientOpacity

    function washed(base, amount) {
        return Qt.rgba(base.r + (glass.tint.r - base.r) * amount, base.g + (glass.tint.g - base.g) * amount, base.b + (glass.tint.b - base.b) * amount, base.a);
    }

    layer.enabled: true
    layer.smooth: true
    layer.textureSize: Qt.size(Math.max(1, Math.round(glass.width * 2)), Math.max(1, Math.round(glass.height * 2)))

    Rectangle {
        anchors.fill: parent

        radius: glass.radius

        antialiasing: true

        opacity: glass.strength

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
