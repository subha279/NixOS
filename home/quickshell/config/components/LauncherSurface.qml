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
    property int cardHeight: 460
    property int preferredCardHeight: 0
    property int itemCount: 0

    readonly property int headerHeight: 46
    readonly property int separatorHeight: 1
    readonly property int rowHeight: 40

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

    readonly property int visibleRows: root.columns > 1 ? Math.min(root.gridMaxRows, Math.max(1, Math.ceil(root.itemCount / root.columns))) : Math.min(root.listMaxRows, Math.max(1, root.itemCount))

    readonly property int targetCardHeight: root.preferredCardHeight > 0 ? root.preferredCardHeight : (root.columns > 1 ? root.headerHeight + root.separatorHeight + root.visibleRows * Math.round((root.cardWidth / root.columns) * 0.70) : root.headerHeight + root.separatorHeight + root.visibleRows * root.rowHeight)

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
            duration: root.open ? Core.Theme.durOpen : Core.Theme.durClose

            easing.type: root.open ? Easing.OutQuint : Easing.InQuint
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

            scale: root.reveal > 0.001 ? 1.0 : 0.97

            y: root.reveal > 0.001 ? 0 : 10

            opacity: root.reveal

            Behavior on scale {
                NumberAnimation {
                    duration: root.open ? 260 : 180

                    easing.type: Easing.OutCubic
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: root.open ? 260 : 180

                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: root.open ? 190 : 130

                    easing.type: Easing.OutCubic
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

                                font.pixelSize: 14
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
