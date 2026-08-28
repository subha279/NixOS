import QtQuick
import "../core" as Core

// Launcher content, WITHOUT a window.
//
// This is the old LauncherSurface with the PanelWindow, the card Rectangle, the
// Glass background and the border removed. Bar.qml owns the single PanelWindow
// and its surface, and hosts one of these per launcher inside it, so a picker no
// longer creates a second layer surface of its own.
//
// The property and signal contract is unchanged, so the pickers only had to
// change which type they inherit.

Item {
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

    // Bar reads this to size its surface.
    property int cardWidth: 620

    property int itemCount: 0

    readonly property int headerHeight: 46
    readonly property int separatorHeight: 1

    // Row height each launcher actually renders: delegate height plus the view's
    // spacing, plus any margins the content view adds. The surface is sized from
    // these, so a wrong value leaves a half row showing at the bottom.
    property int rowHeight: 40

    property int contentMargins: 0

    property int cellHeight: 0

    readonly property int rowExtent: root.columns > 1 ? (root.cellHeight > 0 ? root.cellHeight : Math.round((root.cardWidth / root.columns) * 0.70)) : root.rowHeight

    readonly property int listMaxRows: 10
    readonly property int gridMaxRows: 4

    readonly property int cardMinHeight: 110
    readonly property int cardMaxHeight: Core.Theme.launcherMaxHeight

    property int columns: 1
    property int selectedIndex: 0
    property Component contentComponent: null

    property alias query: input.text

    property bool liveSelect: false

    property int liveSelectDelay: 200
    property bool vimNavigation: false

    readonly property int fittableRows: Math.max(1, Math.floor((root.cardMaxHeight - root.headerHeight - root.separatorHeight - root.contentMargins) / root.rowExtent))

    readonly property int wantedRows: root.columns > 1 ? Math.max(1, Math.ceil(root.itemCount / root.columns)) : Math.max(1, root.itemCount)

    readonly property int visibleRows: Math.min(root.columns > 1 ? root.gridMaxRows : root.listMaxRows, root.fittableRows, root.wantedRows)

    readonly property int targetCardHeight: root.headerHeight + root.separatorHeight + root.contentMargins + root.visibleRows * root.rowExtent

    // The height Bar animates its surface to. Not animated here: a second
    // animation on the same dimension is what made the old popup look unstable.
    readonly property int viewHeight: Math.max(root.cardMinHeight, Math.min(root.cardMaxHeight, root.targetCardHeight))

    readonly property bool open: Core.PopupManager.isOpen(root.launcherId)

    property real wheelAccumulator: 0

    readonly property real wheelStep: 120

    visible: root.open

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

            // Deferred: `visible` is driven by the same `open` change, and an
            // invisible item cannot take focus, so focusing inline can lose the
            // race and leave the launcher unable to type.
            Qt.callLater(root.grabInput);

            root.didOpen();
        } else {
            root.wheelAccumulator = 0;

            previewTimer.stop();

            root.didClose();
        }
    }

    function grabInput() {
        if (root.open)
            input.forceActiveFocus();
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

                font.pixelSize: Core.Theme.iconSize
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

            height: Math.max(0, parent.height - header.height - root.separatorHeight)

            active: root.open

            sourceComponent: root.contentComponent
        }
    }
}
