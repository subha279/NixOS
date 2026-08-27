import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core" as Core

PanelWindow {
    id: root

    property string launcherId: ""
    property string promptIcon: Core.Icons.search
    property string placeholder: "Search"
    property string counterText: ""

    property string headerActionIcon: ""
    property bool headerActionVisible: false

    signal headerActionTriggered
    signal accepted
    signal previewSelection
    signal didOpen
    signal didClose
    signal deleteRequested
    signal clearAllRequested

    property int cardWidth: 620
    property int itemCount: 0

    readonly property int headerHeight: 46
    readonly property int separatorHeight: 1

    // Geometry the card sizes itself from.
    //
    // Each launcher has to declare what its delegates actually measure, because
    // the card height is computed from these and nothing reconciles them against
    // the real content afterwards. A single rowHeight = 40 used to be assumed for
    // every list, which was wrong for three of the five launchers: ThemePicker's
    // rows are 56px, Clipboard's are 48px, and EmojiPicker's grid cells are 70px
    // against a 65px derivation. At ten results ThemePicker's card came out 200px
    // short, so a third of the list was only reachable by scrolling.
    //
    // rowHeight is delegate height PLUS the view's spacing. contentMargins is any
    // padding the content view adds on top.
    property int rowHeight: 40

    property int contentMargins: 0

    // Grid launchers: set cellHeight to pin it, or leave 0 to derive from the
    // column width via cellAspect.
    property int cellHeight: 0

    property real cellAspect: 0.70

    readonly property int gridCellHeight: root.cellHeight > 0 ? root.cellHeight : Math.round((root.cardWidth / root.columns) * root.cellAspect)

    readonly property int listMaxRows: 10
    readonly property int gridMaxRows: 4

    readonly property int cardMinHeight: 110
    readonly property int cardMaxHeight: 620

    property int columns: 1
    property int selectedIndex: 0
    property Component contentComponent: null

    property alias query: input.text

    property bool liveSelect: false
    property int liveSelectDelay: 200
    property bool vimNavigation: false

    // Height of one row, whichever mode we are in.
    readonly property int rowExtent: root.columns > 1 ? root.gridCellHeight : root.rowHeight

    // How many rows fit inside cardMaxHeight.
    //
    // Clamping the finished height against cardMaxHeight, as this used to, stops
    // the card growing but leaves it ending mid-row: the wallpaper grid showed 3.2
    // of 4 rows and the theme list 9.5 of 10, with the remainder sliced off
    // horizontally. Clamping the row COUNT instead means the card always ends on a
    // row boundary and the rest is reached by scrolling, which is what it looks
    // like it is doing anyway.
    readonly property int fittableRows: Math.max(1, Math.floor((root.cardMaxHeight - root.headerHeight - root.separatorHeight - root.contentMargins) / root.rowExtent))

    readonly property int wantedRows: root.columns > 1 ? Math.max(1, Math.ceil(root.itemCount / root.columns)) : Math.max(1, root.itemCount)

    readonly property int visibleRows: Math.min(root.columns > 1 ? root.gridMaxRows : root.listMaxRows, root.fittableRows, root.wantedRows)

    readonly property int targetCardHeight: root.headerHeight + root.separatorHeight + root.contentMargins + root.visibleRows * root.rowExtent

    readonly property bool open: Core.PopupManager.isOpen(root.launcherId)

    property real wheelAccumulator: 0

    readonly property real wheelStep: 120

    Timer {
        id: previewTimer

        interval: root.liveSelectDelay
        repeat: false

        onTriggered: {
            if (root.open)
                root.previewSelection();
        }
    }

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
        const next = root.selectedIndex + delta;

        root.selectedIndex = Math.max(0, Math.min(root.itemCount - 1, next));

        if (root.liveSelect && root.open)
            previewTimer.restart();
    }

    function wheelSelect(deltaY) {
        if (!root.open || deltaY === 0 || root.itemCount <= 0)
            return;
        root.wheelAccumulator += deltaY;

        while (Math.abs(root.wheelAccumulator) >= root.wheelStep) {
            if (root.wheelAccumulator > 0) {
                root.move(-root.columns);
                root.wheelAccumulator -= root.wheelStep;
            } else {
                root.move(root.columns);
                root.wheelAccumulator += root.wheelStep;
            }
        }

        if (root.selectedIndex === 0 || root.selectedIndex === root.itemCount - 1) {
            root.wheelAccumulator = 0;
        }
    }

    onItemCountChanged: {
        if (root.itemCount <= 0) {
            root.selectedIndex = 0;
            root.wheelAccumulator = 0;
            return;
        }

        if (root.selectedIndex >= root.itemCount)
            root.selectedIndex = root.itemCount - 1;
    }

    onOpenChanged: {
        if (root.open) {
            input.text = "";
            root.selectedIndex = 0;
            root.wheelAccumulator = 0;

            previewTimer.stop();

            input.forceActiveFocus();
            root.didOpen();
        } else {
            root.wheelAccumulator = 0;

            previewTimer.stop();

            root.didClose();
        }
    }

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "aurora-launcher"

    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    exclusionMode: ExclusionMode.Ignore

    property real reveal: root.open ? 1.0 : 0.0

    Behavior on reveal {
        NumberAnimation {
            duration: root.open ? Core.Theme.durMedium : Core.Theme.durExitMedium

            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.open ? Core.Theme.easeDecelerate : Core.Theme.easeAccelerate
        }
    }

    visible: root.reveal > 0.001

    Rectangle {
        anchors.fill: parent

        color: "transparent"

        MouseArea {
            anchors.fill: parent

            acceptedButtons: Qt.LeftButton

            onClicked: {
                root.dismiss();
            }
        }
    }

    Rectangle {
        id: card

        width: root.cardWidth

        height: Math.max(root.cardMinHeight, Math.min(root.cardMaxHeight, root.targetCardHeight))

        x: Math.round((parent.width - width) / 2)

        y: Math.round((parent.height - height) / 2 + 60)

        color: "transparent"

        antialiasing: true

        Item {
            id: visual

            anchors.fill: parent

            transformOrigin: Item.Center

            scale: root.reveal > 0.001 ? 1.0 : 0.96

            y: root.reveal > 0.001 ? 0 : 12

            opacity: root.reveal

            // Decelerate in, accelerate out. Was OutCubic both ways.
            Behavior on scale {
                NumberAnimation {
                    duration: root.open ? Core.Theme.durMedium : Core.Theme.durExitMedium

                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.open ? Core.Theme.easeDecelerate : Core.Theme.easeAccelerate
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: root.open ? Core.Theme.durMedium : Core.Theme.durExitMedium

                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.open ? Core.Theme.easeDecelerate : Core.Theme.easeAccelerate
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: root.open ? Core.Theme.durShort : Core.Theme.durExitShort

                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.open ? Core.Theme.easeDecelerate : Core.Theme.easeAccelerate
                }
            }

            Rectangle {
                anchors.fill: parent

                radius: Core.Theme.radiusSmall

                color: "transparent"

                border.width: Core.Theme.borderWidth
                border.color: Core.Theme.borderActive

                antialiasing: true

                Glass {
                    anchors.fill: parent
                    radius: parent.radius
                }
            }

            MouseArea {
                anchors.fill: parent

                acceptedButtons: Qt.NoButton

                onWheel: function (event) {
                    root.wheelSelect(event.angleDelta.y);
                    event.accepted = true;
                }
            }

            Column {
                anchors.fill: parent

                anchors.bottomMargin: Core.Theme.radiusSmall

                spacing: 0

                Item {
                    id: header

                    width: parent.width
                    height: root.headerHeight

                    Text {
                        id: prompt

                        anchors.left: parent.left

                        anchors.leftMargin: Core.Theme.padding + 2

                        anchors.verticalCenter: parent.verticalCenter

                        text: root.promptIcon

                        color: Core.Theme.accent

                        font.family: Core.Theme.iconFont

                        font.pixelSize: Core.Theme.fontSizeLarge
                    }

                    Row {
                        id: counter

                        anchors.right: parent.right

                        anchors.rightMargin: Core.Theme.padding + 2

                        anchors.verticalCenter: parent.verticalCenter

                        spacing: 8

                        Text {
                            text: root.counterText

                            color: Core.Theme.foregroundFaint

                            font.family: Core.Theme.fontMono

                            font.pixelSize: Core.Theme.fontSizeSmall
                        }

                        Rectangle {
                            id: headerAction

                            width: 28
                            height: 28

                            radius: width / 2

                            visible: root.headerActionVisible && root.headerActionIcon !== ""

                            color: headerActionMouse.containsMouse ? Core.Theme.surfaceGlassHover : "transparent"

                            border.width: headerActionMouse.containsMouse ? Core.Theme.borderWidth : 0

                            border.color: Core.Theme.borderActive

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                    easing.type: Easing.OutQuint
                                }
                            }

                            Text {
                                anchors.centerIn: parent

                                text: root.headerActionIcon

                                color: headerActionMouse.containsMouse ? Core.Theme.danger : Core.Theme.foregroundMuted

                                font.family: Core.Theme.iconFont

                                font.pixelSize: Core.Theme.iconSizeSmall
                            }

                            MouseArea {
                                id: headerActionMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    root.headerActionTriggered();
                                }
                            }
                        }
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

                        onTextChanged: {
                            root.selectedIndex = 0;
                            root.wheelAccumulator = 0;
                        }

                        Text {
                            anchors.left: parent.left

                            anchors.verticalCenter: parent.verticalCenter

                            visible: input.text.length === 0

                            text: root.placeholder

                            color: Core.Theme.foregroundFaint

                            font.family: Core.Theme.fontMono

                            font.pixelSize: Core.Theme.fontSizeLarge
                        }

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Delete && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier)) {
                                root.clearAllRequested();
                                event.accepted = true;
                                return;
                            }

                            if (event.key === Qt.Key_Delete && event.modifiers === Qt.NoModifier) {
                                root.deleteRequested();
                                event.accepted = true;
                                return;
                            }

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

                Rectangle {
                    width: parent.width
                    height: root.separatorHeight

                    color: Core.Theme.separator
                }

                Loader {
                    width: parent.width

                    height: parent.height - header.height - root.separatorHeight

                    active: true

                    sourceComponent: root.contentComponent
                }
            }
        }
    }
}
