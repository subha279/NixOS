import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services
import "../components" as Components

// AudioPopup

Components.PopupSurface {
    id: popup

    popupId: "audio"

    cardWidth: 350
    maxCardHeight: 520

    readonly property var svc: Services.AudioService

    // Collapsible sections, so the card stays short by default and springs open when you actually want to switch devices.
    property bool showOutputs: false
    property bool showInputs: false

    onDidClose: {
        popup.showOutputs = false;
        popup.showInputs = false;
    }

    // Right-click menu shared by every device row.
    function deviceMenu(node, mx, my) {
        const target = node;
        const svc = popup.svc;

        popup.openMenu(mx, my, [
            {
                label: "Set as default",
                icon: "\udb80\udc93",
                action: function () {
                    svc.setDefault(target);
                }
            },
            {
                label: svc.mutedOf(target) ? "Unmute" : "Mute",
                icon: svc.mutedOf(target) ? svc.iconHigh : svc.iconOff,
                action: function () {
                    svc.toggleMute(target);
                }
            },
            {
                label: "Set to 100%",
                icon: svc.iconHigh,
                action: function () {
                    svc.setVolume(target, 1.0);
                }
            },
            {
                separator: true
            },
            {
                label: "Open pavucontrol",
                icon: Core.Icons.gear,
                action: function () {
                    svc.openMixer();
                }
            }
        ]);
    }

    contentComponent: Component {

        Column {
            id: body

            spacing: Core.Theme.spacing

            // Header

            Components.PopupHeader {
                width: parent.width

                title: "Audio"

                subtitle: popup.svc.sink ? popup.svc.label(popup.svc.sink) : "No output device"

                actions: [
                    {
                        icon: Core.Icons.gear,
                        tooltip: "Open pavucontrol",
                        action: function () {
                            popup.svc.openMixer();
                        }
                    }
                ]
            }

            Rectangle {
                width: parent.width
                height: 1

                color: Core.Theme.separator
            }

            // Output level

            Rectangle {
                id: outputCard

                width: parent.width

                height: 76

                radius: Core.Theme.radiusRow

                color: Core.Theme.surface

                Column {
                    anchors.fill: parent
                    anchors.margins: 12

                    spacing: 8

                    Item {
                        width: parent.width
                        height: 20

                        Text {
                            id: outIcon

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: popup.svc.icon

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: 17

                            color: popup.svc.muted ? Core.Theme.foregroundFaint : Core.Theme.accent

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6

                                hoverEnabled: true

                                cursorShape: Qt.PointingHandCursor

                                onClicked: popup.svc.toggleOutputMute()
                            }
                        }

                        Text {
                            anchors.left: outIcon.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            text: popup.svc.muted ? "Muted" : "Output"

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: Core.Theme.fontSizeSmall

                            color: Core.Theme.foregroundMuted
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            text: popup.svc.volumePercent + "%"

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: Core.Theme.fontSizeLarge
                            font.weight: Font.DemiBold

                            color: popup.svc.muted ? Core.Theme.foregroundFaint : Core.Theme.foreground
                        }
                    }

                    Components.VolumeSlider {
                        width: parent.width

                        value: popup.svc.volume
                        muted: popup.svc.muted

                        enabled: popup.svc.sink !== null

                        fillColor: Core.Theme.accent

                        onMoved: function (v) {
                            popup.svc.setVolume(popup.svc.sink, v);
                        }
                    }
                }
            }

            // Output device picker

            Item {
                width: parent.width
                height: 22

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter

                    text: "OUTPUT DEVICES"

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall
                    font.letterSpacing: 1.0

                    color: Core.Theme.foregroundFaint
                }

                Text {
                    id: outChevron

                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter

                    text: popup.svc.sinks.length + (popup.showOutputs ? "  \udb80\udd43" : "  \udb80\udd40")

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.foregroundFaint
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        popup.showOutputs = !popup.showOutputs;
                    }
                }
            }

            Item {
                id: outputBox

                width: parent.width

                clip: true

                height: popup.showOutputs ? Math.min(outputList.implicitHeight, 190) : 0

                Behavior on height {
                    NumberAnimation {
                        duration: Core.Theme.durBase
                        easing.type: Easing.OutQuint
                    }
                }

                Column {
                    id: outputList

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    spacing: 2

                    add: Transition {
                        NumberAnimation {
                            properties: "opacity"
                            from: 0
                            to: 1
                            duration: 160
                            easing.type: Easing.OutQuint
                        }
                    }

                    move: Transition {
                        NumberAnimation {
                            properties: "y"
                            duration: 170
                            easing.type: Easing.OutQuint
                        }
                    }

                    Repeater {
                        model: popup.svc.sinks

                        delegate: Components.ListRow {
                            id: sinkRow

                            required property var modelData

                            width: outputList.width

                            icon: popup.svc.iconFor(sinkRow.modelData)

                            title: popup.svc.label(sinkRow.modelData)

                            subtitle: popup.svc.percentOf(sinkRow.modelData) + "%" + (popup.svc.mutedOf(sinkRow.modelData) ? "  \u00b7  muted" : "")

                            active: popup.svc.isDefault(sinkRow.modelData)

                            trailing: sinkRow.active ? "\udb80\udd34" : ""

                            trailingColor: Core.Theme.success

                            onActivated: {
                                popup.svc.setDefaultSink(sinkRow.modelData);
                            }

                            onContextRequested: function (mx, my) {
                                popup.deviceMenu(sinkRow.modelData, mx, my);
                            }
                        }
                    }
                }
            }

            // Microphone level

            Rectangle {
                width: parent.width
                height: 1

                color: Core.Theme.separator
            }

            Rectangle {
                id: inputCard

                width: parent.width

                height: 76

                radius: Core.Theme.radiusRow

                color: Core.Theme.surface

                Column {
                    anchors.fill: parent
                    anchors.margins: 12

                    spacing: 8

                    Item {
                        width: parent.width
                        height: 20

                        Text {
                            id: micIcon

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: popup.svc.micIcon

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: 17

                            color: popup.svc.micMuted ? Core.Theme.danger : Core.Theme.success

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6

                                hoverEnabled: true

                                cursorShape: Qt.PointingHandCursor

                                onClicked: popup.svc.toggleMicMute()
                            }
                        }

                        Text {
                            anchors.left: micIcon.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            text: popup.svc.micMuted ? "Microphone muted" : "Microphone"

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: Core.Theme.fontSizeSmall

                            color: popup.svc.micMuted ? Core.Theme.danger : Core.Theme.foregroundMuted
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            text: popup.svc.micPercent + "%"

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: Core.Theme.fontSizeLarge
                            font.weight: Font.DemiBold

                            color: popup.svc.micMuted ? Core.Theme.foregroundFaint : Core.Theme.foreground
                        }
                    }

                    Components.VolumeSlider {
                        width: parent.width

                        value: popup.svc.micVolume
                        muted: popup.svc.micMuted

                        enabled: popup.svc.source !== null

                        fillColor: Core.Theme.success

                        onMoved: function (v) {
                            popup.svc.setVolume(popup.svc.source, v);
                        }
                    }
                }
            }

            // Input device picker

            Item {
                width: parent.width
                height: 22

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter

                    text: "INPUT DEVICES"

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall
                    font.letterSpacing: 1.0

                    color: Core.Theme.foregroundFaint
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter

                    text: popup.svc.sources.length + (popup.showInputs ? "  \udb80\udd43" : "  \udb80\udd40")

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.foregroundFaint
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor

                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: function (event) {
                        if (event.button === Qt.RightButton) {

                            // Monitor sources are hidden by default.
                            popup.svc.showMonitors = !popup.svc.showMonitors;

                            popup.showInputs = true;

                            return;
                        }

                        popup.showInputs = !popup.showInputs;
                    }
                }
            }

            Item {
                id: inputBox

                width: parent.width

                clip: true

                height: popup.showInputs ? Math.min(inputList.implicitHeight, 190) : 0

                Behavior on height {
                    NumberAnimation {
                        duration: Core.Theme.durBase
                        easing.type: Easing.OutQuint
                    }
                }

                Column {
                    id: inputList

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    spacing: 2

                    add: Transition {
                        NumberAnimation {
                            properties: "opacity"
                            from: 0
                            to: 1
                            duration: 160
                            easing.type: Easing.OutQuint
                        }
                    }

                    move: Transition {
                        NumberAnimation {
                            properties: "y"
                            duration: 170
                            easing.type: Easing.OutQuint
                        }
                    }

                    Repeater {
                        model: popup.svc.sources

                        delegate: Components.ListRow {
                            id: sourceRow

                            required property var modelData

                            width: inputList.width

                            icon: popup.svc.iconFor(sourceRow.modelData)

                            title: popup.svc.label(sourceRow.modelData)

                            subtitle: popup.svc.percentOf(sourceRow.modelData) + "%" + (popup.svc.mutedOf(sourceRow.modelData) ? "  \u00b7  muted" : "")

                            active: popup.svc.isDefault(sourceRow.modelData)

                            trailing: sourceRow.active ? "\udb80\udd34" : ""

                            trailingColor: Core.Theme.success

                            onActivated: {
                                popup.svc.setDefaultSource(sourceRow.modelData);
                            }

                            onContextRequested: function (mx, my) {
                                popup.deviceMenu(sourceRow.modelData, mx, my);
                            }
                        }
                    }
                }
            }

            // Per-application mixer

            Item {
                width: parent.width
                height: popup.svc.streams.length > 0 ? 22 : 0

                visible: height > 0

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter

                    text: "PLAYING"

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall
                    font.letterSpacing: 1.0

                    color: Core.Theme.foregroundFaint
                }
            }

            Column {
                id: streamList

                width: parent.width

                spacing: 4

                add: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        from: 0
                        to: 1
                        duration: 160
                        easing.type: Easing.OutQuint
                    }
                }

                move: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: 170
                        easing.type: Easing.OutQuint
                    }
                }

                Repeater {
                    model: popup.svc.streams

                    delegate: Item {
                        id: streamRow

                        required property var modelData

                        width: streamList.width
                        height: 44

                        Text {
                            id: streamName

                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            anchors.top: parent.top

                            width: parent.width - 60

                            elide: Text.ElideRight

                            text: popup.svc.streamLabel(streamRow.modelData)

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: Core.Theme.fontSize

                            color: Core.Theme.foreground
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            anchors.top: parent.top

                            text: popup.svc.percentOf(streamRow.modelData) + "%"

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: Core.Theme.fontSizeSmall

                            color: Core.Theme.foregroundMuted
                        }

                        Components.VolumeSlider {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            anchors.bottom: parent.bottom

                            value: popup.svc.volumeOf(streamRow.modelData)

                            muted: popup.svc.mutedOf(streamRow.modelData)

                            fillColor: Core.Theme.accentSoft

                            onMoved: function (v) {
                                popup.svc.setVolume(streamRow.modelData, v);
                            }
                        }
                    }
                }
            }

            // Empty state

            Item {
                width: parent.width

                height: popup.svc.sink ? 0 : 70

                visible: height > 0

                Column {
                    anchors.centerIn: parent

                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: popup.svc.iconOff

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: 22

                        color: Core.Theme.foregroundFaint
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: "No audio device found"

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: Core.Theme.fontSizeSmall

                        color: Core.Theme.foregroundMuted
                    }
                }
            }
        }
    }
}
