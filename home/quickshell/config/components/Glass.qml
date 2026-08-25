import QtQuick

import "../core" as Core

// Liquid-glass surface: the fill for every shell window (bar pill, launchers,
// popups, context menu, toasts).
//
// The blur is NOT ours -- a QML item cannot sample behind a Wayland layer
// surface, so it comes from Hyprland's layer rules (hyprland/config/layerules.lua).
// All this does is stay translucent enough to let that blur through, tint it, and
// shape how the edge catches light. An opaque fill here does not cover the blur,
// it just makes the compositor compute one nobody can see.
//
// Seven layers, back to front: tinted ramp, accent wash, grain, specular,
// lens shade, depth, rim. Colours all come from Core.Theme, so every theme
// retints for free. Layers 3-7 each carry a `visible: knob > 0.001` guard, so
// zeroing a knob drops the node instead of drawing a no-op.
//
// Use as a CHILD of the surface, with the surface set to `color: "transparent"`.
// Elevation is the opposite -- it must be a SIBLING, it draws outside the bounds.

Item {
    id: glass

    // Must match the surface's radius or the gradient corners will not line up.
    property real radius: 0

    // Master fade, so a surface that comes and goes fades as one object rather
    // than as seven layers.
    property real strength: 1.0

    // No handlers anywhere: decoration only, never eats a click.

    // 1. BODY
    //
    // Theme.glassOpacity decides how much wallpaper shows. The middle stop is
    // the colour midpoint of the two ends thinned by Theme.glassClarity, so the
    // slab is clearest through its centre -- at clarity 0 it renders identically
    // to a plain two-stop ramp.

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

    // 2. COLOUR WASH
    //
    // Accent bleeding in from the left. Crossed with the vertical ramp above,
    // the pair reads as one diagonal gradient -- a Qt6 Gradient is only ever
    // vertical or horizontal.

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
