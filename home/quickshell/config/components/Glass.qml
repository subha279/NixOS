import QtQuick

import "../core" as Core

Item {
    id: glass
    property real radius: 0
    property real strength: 1.0

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

        visible: Core.Theme.glassGradientOpacity > 0.001

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0.0
                color: Core.Theme.glassWash
            }

            GradientStop {
                position: 1.0
                color: Core.Theme.glassWashEnd
            }
        }
    }


    Image {
        anchors.fill: parent
        anchors.margins: Math.ceil(glass.radius * 0.30)

        source: Core.Theme.glassGrainSource

        fillMode: Image.Tile

        smooth: false

        cache: true

        asynchronous: true

        opacity: Core.Theme.glassGrainOpacity * glass.strength

        visible: Core.Theme.glassGrainOpacity > 0.001
    }


    Rectangle {
        anchors.fill: parent

        radius: glass.radius

        antialiasing: true

        opacity: glass.strength

        visible: Core.Theme.glassSpecularOpacity > 0.001

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Core.Theme.glassSpecular
            }

            GradientStop {
                position: 0.14
                color: Qt.rgba(1, 1, 1, Core.Theme.glassSpecular.a * 0.34)
            }

            GradientStop {
                position: 0.38
                color: Core.Theme.glassSpecularEnd
            }

            GradientStop {
                position: 1.0
                color: Core.Theme.glassSpecularEnd
            }
        }
    }


    Rectangle {
        anchors.fill: parent

        radius: glass.radius

        antialiasing: true

        opacity: glass.strength

        visible: Core.Theme.glassLensOpacity > 0.001

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Core.Theme.glassLensShadeEnd
            }

            GradientStop {
                position: 0.70
                color: Core.Theme.glassLensShadeEnd
            }

            GradientStop {
                position: 0.90
                color: Qt.rgba(0, 0, 0, Core.Theme.glassLensShade.a * 0.34)
            }

            GradientStop {
                position: 1.0
                color: Core.Theme.glassLensShade
            }
        }
    }


    Rectangle {
        anchors.fill: parent
        anchors.margins: 1

        radius: Math.max(0, glass.radius - 1)

        color: "transparent"

        border.width: 2
        border.color: Core.Theme.glassDepth

        antialiasing: true

        opacity: glass.strength

        visible: Core.Theme.glassDepthOpacity > 0.001
    }


    Rectangle {
        anchors.fill: parent

        radius: glass.radius

        color: "transparent"

        border.width: 1
        border.color: Core.Theme.glassRim

        antialiasing: true

        opacity: glass.strength

        visible: Core.Theme.glassRimOpacity > 0.001
    }
}
