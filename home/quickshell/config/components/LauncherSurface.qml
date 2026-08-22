import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core" as Core

// ============================================================
// Launcher Surface
// ============================================================
//
// Shared dmenu chrome: fullscreen scrim, centred card, prompt,
// search field and keyboard navigation. The three launchers
// (apps, wallpaper, colorscheme) supply only a content component
// and a result count.
//
// Deliberately NOT built on PopupSurface. That component anchors
// under the bar and takes OnDemand keyboard focus, which cannot
// reliably receive typed text. A launcher needs Exclusive focus
// and its own centred geometry, so it is a separate surface.
//
// ============================================================

PanelWindow {
    id: root

    // --------------------------------------------------------
    // API for subclasses
    // --------------------------------------------------------

    property string launcherId: ""
    property string promptIcon: Core.Icons.search
    property string placeholder: "Search"
    property string counterText: ""

    property int cardWidth: 620
    property int cardHeight: 460

    property int itemCount: 0

    readonly property int headerHeight: 46
    readonly property int separatorHeight: 1
    readonly property int rowHeight: 40

    readonly property int listMaxRows: 10
    readonly property int gridMaxRows: 4

    readonly property int cardMinHeight: 110
    readonly property int cardMaxHeight: 620

    readonly property int visibleRows: root.columns > 1 ? Math.min(root.gridMaxRows, Math.max(1, Math.ceil(root.itemCount / root.columns))) : Math.min(root.listMaxRows, Math.max(1, root.itemCount))

    readonly property int targetCardHeight: root.columns > 1 ? root.headerHeight + root.separatorHeight + root.visibleRows * Math.round((root.cardWidth / root.columns) * 0.70) : root.headerHeight + root.separatorHeight + root.visibleRows * root.rowHeight

    // Grid launchers set this so Left/Right and Up/Down move by a
    // row rather than by one item.
    property int columns: 1

    property int selectedIndex: 0

    property Component contentComponent: null

    property alias query: input.text

    signal accepted
    signal didOpen
    signal didClose

    readonly property bool open: Core.PopupManager.isOpen(root.launcherId)

    // --------------------------------------------------------
    // Open / close
    //
    // PopupManager is the single source of truth, so opening a
    // launcher closes any bar popup for free.
    // --------------------------------------------------------

    function show() {
        Core.PopupManager.open(root.launcherId, 0, 0);
    }

    function toggle() {
        Core.PopupManager.toggle(root.launcherId, 0, 0);
    }

    function dismiss() {
        if (root.open)
            Core.PopupManager.close();
    }

    function move(delta) {
        if (root.itemCount <= 0)
            return;

        let next = root.selectedIndex + delta;

        // Wrap, so holding Down cycles instead of sticking.
        while (next < 0)
            next += root.itemCount;

        root.selectedIndex = next % root.itemCount;
    }

    onItemCountChanged: {
        if (root.selectedIndex >= root.itemCount)
            root.selectedIndex = Math.max(0, root.itemCount - 1);
    }

    onOpenChanged: {
        if (root.open) {
            input.text = "";
            root.selectedIndex = 0;
            input.forceActiveFocus();
            root.didOpen();
        } else {
            root.didClose();
        }
    }

    // --------------------------------------------------------
    // Surface
    // --------------------------------------------------------

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "aurora-launcher"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    exclusionMode: ExclusionMode.Ignore

    // Driving everything from one animated value keeps the close
    // animation visible: the window stays mapped until reveal
    // has actually reached zero.
    property real reveal: root.open ? 1.0 : 0.0

    Behavior on reveal {
        NumberAnimation {
            duration: root.open ? Core.Theme.durOpen : Core.Theme.durClose
            easing.type: root.open ? Easing.OutCubic : Easing.InCubic
        }
    }

    visible: root.reveal > 0.001

    // --------------------------------------------------------
    // Scrim opacity
    //
    // MUST stay below the aurora-launcher layer rule's
    // ignore_alpha (0.20).
    //
    // Hyprland only blurs pixels at or above that alpha. Keeping
    // the fullscreen scrim underneath it is what stops the blur
    // from spreading across the whole desktop, while the card
    // above (glassOpacity 0.80) still gets frosted.
    //
    // Raise this above 0.20 and fullscreen blur comes back.
    // --------------------------------------------------------

    readonly property real scrimAlpha: 0.12

    // --------------------------------------------------------
    // Scrim
    // --------------------------------------------------------

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Core.Theme.backgroundDark, root.scrimAlpha * root.reveal)

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismiss()
        }
    }

    // --------------------------------------------------------
    // Card
    // --------------------------------------------------------

    Rectangle {
        id: card

        width: root.cardWidth

        height: Math.max(root.cardMinHeight, Math.min(root.cardMaxHeight, root.targetCardHeight))

        x: Math.round((parent.width - width) / 2)

        y: Math.round((parent.height - height) / 2 + 60 + (1.0 - root.reveal) * 14)

        Behavior on height {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }
        // Omarchy-style chrome: near-square corners, a single
        // hairline border, no shadow and no bounce on open.
        //
        // Still translucent, so the layer-rule blur frosts it.
        // Because the scrim behind stays under ignore_alpha, this
        // card remains the only thing Hyprland blurs.
        radius: Core.Theme.radiusSmall

        color: Core.Theme.backgroundGlass

        border.width: 0
        border.color: Core.Theme.borderActive

        opacity: root.reveal

        // Swallow clicks so they do not reach the scrim below.
        MouseArea {
            anchors.fill: parent
        }

        // No horizontal margin and no spacing between children: the
        // separator and the row selection bars run edge to edge, the
        // way a dmenu list does. Horizontal padding moves inside each
        // row instead.
        //
        // The bottom margin matches the card radius so the last row
        // cannot square off the rounded bottom corners (a Rectangle
        // does not clip its children to its own radius).
        Column {
            anchors.fill: parent
            anchors.bottomMargin: Core.Theme.radiusSmall
            spacing: 0

            // ------------------------------------------------
            // Header: prompt, counter, input
            // ------------------------------------------------

            Item {
                id: header

                width: parent.width
                height: 46

                Text {
                    id: prompt

                    anchors.left: parent.left
                    anchors.leftMargin: Core.Theme.padding + 2
                    anchors.verticalCenter: parent.verticalCenter

                    text: root.promptIcon
                    color: Core.Theme.accent
                    font.family: Core.Theme.fontMono
                    font.pixelSize: Core.Theme.fontSizeLarge
                }

                Text {
                    id: counter

                    anchors.right: parent.right
                    anchors.rightMargin: Core.Theme.padding + 2
                    anchors.verticalCenter: parent.verticalCenter

                    text: root.counterText
                    color: Core.Theme.foregroundFaint
                    font.family: Core.Theme.fontMono
                    font.pixelSize: Core.Theme.fontSizeSmall
                }

                TextInput {
                    id: input

                    anchors.left: prompt.right
                    anchors.leftMargin: Core.Theme.padding
                    anchors.right: counter.left
                    anchors.rightMargin: Core.Theme.padding
                    anchors.verticalCenter: parent.verticalCenter

                    focus: true
                    selectByMouse: true
                    selectionColor: Core.Theme.accentMuted

                    color: Core.Theme.foreground
                    font.family: Core.Theme.fontMono
                    font.pixelSize: Core.Theme.fontSizeLarge

                    // Any edit invalidates the current selection.
                    onTextChanged: root.selectedIndex = 0

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left

                        visible: input.text.length === 0

                        text: root.placeholder
                        color: Core.Theme.foregroundFaint
                        font.family: Core.Theme.fontMono
                        font.pixelSize: Core.Theme.fontSizeLarge
                    }

                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Escape) {
                            root.dismiss();
                            event.accepted = true;
                            return;
                        }

                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.accepted();
                            event.accepted = true;
                            return;
                        }

                        const ctrl = (event.modifiers & Qt.ControlModifier) !== 0;

                        if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_N) || (ctrl && event.key === Qt.Key_J)) {
                            root.move(root.columns);
                            event.accepted = true;
                            return;
                        }

                        if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_P) || (ctrl && event.key === Qt.Key_K)) {
                            root.move(-root.columns);
                            event.accepted = true;
                            return;
                        }

                        if (event.key === Qt.Key_Tab) {
                            root.move(1);
                            event.accepted = true;
                            return;
                        }

                        if (event.key === Qt.Key_Backtab) {
                            root.move(-1);
                            event.accepted = true;
                            return;
                        }

                        // Horizontal arrows only navigate in grids, and
                        // only at the ends of the text, so editing the
                        // query still works normally.
                        if (root.columns > 1) {
                            if (event.key === Qt.Key_Right && input.cursorPosition >= input.text.length) {
                                root.move(1);
                                event.accepted = true;
                                return;
                            }

                            if (event.key === Qt.Key_Left && input.cursorPosition <= 0) {
                                root.move(-1);
                                event.accepted = true;
                                return;
                            }
                        }
                    }
                }
            }

            // ------------------------------------------------
            // Separator
            // ------------------------------------------------

            Rectangle {
                width: parent.width
                height: 1
                color: Core.Theme.separator
            }

            // ------------------------------------------------
            // Results
            // ------------------------------------------------

            Loader {
                width: parent.width
                height: parent.height - header.height - 1

                active: root.visible
                sourceComponent: root.contentComponent
            }
        }
    }
}
