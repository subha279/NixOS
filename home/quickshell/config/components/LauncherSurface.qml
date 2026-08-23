import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core" as Core

// Launcher Surface

PanelWindow {
    id: root

    // API for subclasses

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

    // Grid launchers set this so Left/Right and Up/Down
    // move by a row rather than by one item.
    property int columns: 1

    property int selectedIndex: 0

    property Component contentComponent: null

    property alias query: input.text

    // Live selection
    //
    // Pickers that apply as you move (wallpaper, colourscheme) set this.
    // The applier is debounced rather than fired on every step: spinning
    // the wheel through forty wallpapers must not spawn forty processes,
    // it should apply the one you stop on.
    property bool liveSelect: false

    property int liveSelectDelay: 200

    // h/j/k/l navigation, live only while the query is empty so that
    // typing a search containing those letters still types.
    property bool vimNavigation: false

    signal accepted
    signal previewSelection
    signal didOpen
    signal didClose

    Timer {
        id: previewTimer

        interval: root.liveSelectDelay
        repeat: false

        // Guarded: the last step before you hit Enter or Escape
        // can land after the launcher has already closed.
        onTriggered: {
            if (root.open)
                root.previewSelection();
        }
    }

    readonly property bool open: Core.PopupManager.isOpen(root.launcherId)

    // Open / close

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

        // Deliberately here rather than in onSelectedIndexChanged:
        // hovering the grid with the mouse moves the selection, and so
        // does retyping the query, and neither of those should apply
        // anything.
        if (root.liveSelect && root.open)
            previewTimer.restart();
    }

    property real wheelTravel: 0
    readonly property bool wheelActive: wheelLock.running

    Timer {
        id: wheelLock

        interval: 60
        repeat: false
    }

    function wheelSelect(deltaY) {
        if (deltaY === 0 || root.itemCount <= 0)
            return;

        // Ignore additional wheel events until the current step is finished.
        if (wheelLock.running)
            return;
        wheelLock.restart();

        if (deltaY > 0) {
            root.move(-root.columns);
        } else {
            root.move(root.columns);
        }
    }

    onItemCountChanged: {
        if (root.selectedIndex >= root.itemCount)
            root.selectedIndex = Math.max(0, root.itemCount - 1);
    }

    onOpenChanged: {
        if (root.open) {
            input.text = "";
            root.selectedIndex = 0;
            root.wheelTravel = 0;

            // Resetting the selection must not count as a move.
            previewTimer.stop();

            input.forceActiveFocus();
            root.didOpen();
        } else {
            previewTimer.stop();
            root.didClose();
        }
    }

    // Surface

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "aurora-launcher"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    exclusionMode: ExclusionMode.Ignore

    // Driving everything from one animated value keeps the close animation
    // visible: the window stays mapped until reveal has actually reached.
    property real reveal: root.open ? 1.0 : 0.0

    Behavior on reveal {
        NumberAnimation {
            duration: root.open ? Core.Theme.durOpen : Core.Theme.durClose

            easing.type: root.open ? Easing.OutQuint : Easing.InQuint
        }
    }

    visible: root.reveal > 0.001

    // Scrim opacity

    readonly property real scrimAlpha: 0.12

    // Scrim

    Rectangle {
        anchors.fill: parent

        color: Qt.alpha(Core.Theme.backgroundDark, root.scrimAlpha * root.reveal)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: root.dismiss()
        }
    }

    // Floating shadow
    //
    // Declared after the scrim and before the card so it paints between them
    // without needing an explicit z.

    Item {
        anchors.fill: card

        opacity: card.opacity

        visible: root.reveal > 0.001

        Rectangle {
            anchors.fill: parent
            anchors.margins: -12

            radius: card.radius + 12

            color: "#000000"

            opacity: Core.Theme.shellShadowOpacity * 0.15

            antialiasing: true
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -7

            radius: card.radius + 7

            color: "#000000"

            opacity: Core.Theme.shellShadowOpacity * 0.28

            antialiasing: true
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -3

            radius: card.radius + 3

            color: "#000000"

            opacity: Core.Theme.shellShadowOpacity * 0.50

            antialiasing: true
        }
    }

    // Card

    Rectangle {
        id: card

        width: root.cardWidth

        height: Math.max(root.cardMinHeight, Math.min(root.cardMaxHeight, root.targetCardHeight))

        x: Math.round((parent.width - width) / 2)

        y: Math.round((parent.height - height) / 2 + 60 + (1.0 - root.reveal) * 14)

        Behavior on height {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutQuint
            }
        }

        radius: Core.Theme.radiusSmall

        color: Core.Theme.backgroundGlass

        border.width: 0
        border.color: Core.Theme.borderActive

        opacity: root.reveal

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onWheel: function (event) {
                root.wheelSelect(event.angleDelta.y);
                event.accepted = true;
            }
        }
        Column {
            anchors.fill: parent
            anchors.bottomMargin: Core.Theme.radiusSmall
            spacing: 0

            // Header: prompt, counter, input

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

                        // Vim navigation
                        //
                        // Only with an empty query, and only unmodified:
                        // the moment you start typing, h/j/k/l go back
                        // to being letters, so searching for "khaki"
                        // still works.
                        if (root.vimNavigation && input.text.length === 0 && event.modifiers === Qt.NoModifier) {
                            if (event.key === Qt.Key_H) {
                                root.move(-1);
                                event.accepted = true;
                                return;
                            }

                            if (event.key === Qt.Key_L) {
                                root.move(1);
                                event.accepted = true;
                                return;
                            }

                            // In a one-column list, columns is 1,
                            // so k and j are simply previous and next.
                            if (event.key === Qt.Key_K) {
                                root.move(-root.columns);
                                event.accepted = true;
                                return;
                            }

                            if (event.key === Qt.Key_J) {
                                root.move(root.columns);
                                event.accepted = true;
                                return;
                            }
                        }

                        // Horizontal arrows only navigate in grids,
                        // and only at the ends of the text, so editing
                        // the query still works normally.
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

            // Separator

            Rectangle {
                width: parent.width
                height: 1

                color: Core.Theme.separator
            }

            // Results

            Loader {
                width: parent.width

                height: parent.height - header.height - 1

                active: root.visible

                sourceComponent: root.contentComponent
            }
        }
    }
}
