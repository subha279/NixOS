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

    // 3. GRAIN
    //
    // A 96x96 mid-grey noise tile, centred on mid-grey so it perturbs without
    // tinting. At 0.010 it is a sub-LSB dither against banding in the wide
    // gradients, not a texture you are meant to see.
    //
    // The inset is what keeps square corners off the card's curve: radius does
    // not clip children and `clip: true` only clips to the bounding box. At
    // 0.30r the tile is provably inscribed (r*(1 - 1/sqrt(2)) = 0.293r), so no
    // mask and no offscreen pass. The cost is a narrow ungrained edge band,
    // which Hyprland's own blur noise covers.

    Image {
        anchors.fill: parent
        anchors.margins: Math.ceil(glass.radius * 0.30)

        source: Core.Theme.glassGrainSource

        fillMode: Image.Tile

        // Smoothing would average the specks towards their mean.
        smooth: false

        cache: true

        asynchronous: true

        opacity: Core.Theme.glassGrainOpacity * glass.strength

        visible: Core.Theme.glassGrainOpacity > 0.001
    }

    // 4. SPECULAR
    //
    // The catch-light. This layer is what decides whether the surface reads as
    // glossy glass or matte frost.
    //
    // A full-size rect, not a top strip: the ramp reaches fully transparent by
    // 38%, so the corners follow `radius` for free and there is no hard edge to
    // hide -- which matters because Rectangle.border.color cannot be a gradient.
    // The middle stop puts a knee in the falloff so the light hugs the edge, and
    // takes its alpha from glassSpecular.a so it inherits the light-theme
    // polarity scaling.

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

    // 5. LENS SHADE
    //
    // Mirror of layer 4: the bottom edge, thickest and refracting most, goes
    // darker. Carries the whole convex read on light themes, where a white
    // catch-light has nothing to brighten.

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

    // 6. DEPTH
    //
    // Inner shading, so layers 4 and 5 read as light wrapping something thick
    // rather than painted on a flat sheet. radius - 1 keeps it concentric with
    // the rim, which otherwise drifts apart at the corners.

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

    // 7. RIM
    //
    // The cut face of the glass, drawn last so it stays crisp over the soft
    // band beneath it.

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
