import QtQuick

import Quickshell

import "../core" as Core
import "../services" as Services
import "../components" as Components

// NetworkPopup

Components.PopupSurface {
    id: popup

    popupId: "network"

    cardWidth: 340
    maxCardHeight: 470

    readonly property var svc: Services.NetworkService

    // SSID awaiting a password, "" when the field is hidden
    property string passwordFor: ""
    property string passwordError: ""

    // The password field now lives inside contentComponent, so its id is out of scope here.
    property string passwordText: ""
    property int focusPulse: 0

    onDidClose: {
        popup.passwordFor = "";
        popup.passwordError = "";
        popup.passwordText = "";
    }

    Connections {
        target: popup.svc

        function onConnectFailed(ssid, message) {
            if (popup.passwordFor === ssid || popup.passwordFor === "") {
                popup.passwordFor = ssid;
                popup.passwordError = "Could not connect — check the password";
            }
        }

        function onConnectSucceeded(ssid) {
            if (popup.passwordFor === ssid) {
                popup.passwordFor = "";
                popup.passwordError = "";
                popup.passwordText = "";
            }
        }
    }

    function requestConnect(ssid, secured, saved) {
        if (secured && !saved) {
            popup.passwordError = "";
            popup.passwordFor = ssid;
            popup.passwordText = "";
            popup.focusPulse = popup.focusPulse + 1;
            return;
        }

        popup.passwordFor = "";
        popup.svc.connectWifi(ssid, "");
    }

    // Content

    // Content

    contentComponent: Component {

        Column {
            id: body

            spacing: Core.Theme.spacing

            // Header

            Components.PopupHeader {
                width: parent.width

                title: "Network"

                subtitle: popup.svc.linkLabel

                showToggle: true
                toggled: popup.svc.wifiEnabled

                onToggleRequested: popup.svc.toggleWifi()

                actions: [
                    {
                        icon: Core.Icons.refresh,
                        spinning: popup.svc.scanning,
                        action: function () {
                            popup.svc.rescan();
                        }
                    },
                    {
                        icon: Core.Icons.gear,
                        action: function () {
                            popup.svc.openEditor();
                            Core.PopupManager.close();
                        }
                    }
                ]
            }

            Rectangle {
                width: parent.width
                height: 1

                color: Core.Theme.separator
            }

            // Ethernet

            Item {
                width: parent.width

                clip: true

                height: popup.svc.ethAvailable ? ethColumn.implicitHeight : 0

                opacity: popup.svc.ethAvailable ? 1.0 : 0.0

                Behavior on height {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutQuint
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuint
                    }
                }

                Column {
                    id: ethColumn

                    width: parent.width

                    spacing: 2

                    Text {
                        text: "WIRED"

                        leftPadding: 8

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: Core.Theme.fontSizeSmall
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1

                        color: Core.Theme.foregroundFaint
                    }

                    Components.ListRow {
                        width: parent.width

                        icon: "\udb80\ude00"

                        title: popup.svc.ethConnection !== "" ? popup.svc.ethConnection : "Ethernet"

                        subtitle: popup.svc.ethConnected ? "Connected · " + popup.svc.ethDevice : popup.svc.ethState === "unavailable" ? "Cable unplugged" : "Disconnected · " + popup.svc.ethDevice

                        trailing: popup.svc.ethConnected ? "\udb80\udd34" : ""

                        trailingColor: Core.Theme.success

                        active: popup.svc.ethConnected

                        dimmed: popup.svc.ethState === "unavailable"

                        onActivated: {
                            // Clicking one link drops the other
                            popup.svc.toggleEthernet();
                        }

                        onContextRequested: function (mx, my) {
                            popup.openMenu(mx, my, [
                                {
                                    icon: popup.svc.ethConnected ? "\udb80\udd75" : "\udb80\udd74",
                                    label: popup.svc.ethConnected ? "Disconnect" : "Connect",
                                    action: function () {
                                        popup.svc.toggleEthernet();
                                    }
                                },
                                {
                                    icon: Core.Icons.refresh,
                                    label: "Reconnect",
                                    action: function () {
                                        popup.svc.disconnectEthernet();
                                        popup.svc.connectEthernet(true);
                                    }
                                },
                                {
                                    separator: true
                                },
                                {
                                    icon: Core.Icons.gear,
                                    label: "Wired settings",
                                    action: function () {
                                        popup.svc.openEditor();
                                        Core.PopupManager.close();
                                    }
                                }
                            ]);
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1

                        color: Core.Theme.separator
                    }
                }
            }

            // Wi-Fi section label

            Item {
                width: parent.width
                height: 16

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    text: "WI-FI"

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1

                    color: Core.Theme.foregroundFaint
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    text: popup.svc.scanning ? "scanning…" : popup.svc.networkModel.count + " found"

                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeSmall

                    color: Core.Theme.foregroundFaint

                    opacity: popup.svc.wifiEnabled ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutQuint
                        }
                    }
                }
            }

            // Inline password field

            Item {
                width: parent.width

                clip: true

                height: popup.passwordFor !== "" ? pwColumn.implicitHeight + 6 : 0

                opacity: popup.passwordFor !== "" ? 1.0 : 0.0

                Behavior on height {
                    NumberAnimation {
                        duration: Core.Theme.durBase
                        easing.type: Easing.OutQuint
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutQuint
                    }
                }

                Column {
                    id: pwColumn

                    width: parent.width

                    spacing: 4

                    Rectangle {
                        width: parent.width
                        height: 34

                        radius: Core.Theme.radiusRow

                        color: Core.Theme.surface

                        border.width: Core.Theme.borderWidth

                        border.color: passwordInput.activeFocus ? Core.Theme.accent : Core.Theme.border

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                                easing.type: Easing.OutQuint
                            }
                        }

                        Text {
                            id: lockIcon

                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter

                            text: "\udb80\udfba"

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: 13

                            color: Core.Theme.foregroundMuted
                        }

                        TextInput {
                            id: passwordInput

                            anchors.left: lockIcon.right
                            anchors.leftMargin: 9
                            anchors.right: pwGo.left
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter

                            clip: true

                            echoMode: TextInput.Password

                            passwordCharacter: "\u2022"

                            font.family: Core.Theme.fontFamily
                            font.pixelSize: Core.Theme.fontSize

                            color: Core.Theme.foreground

                            selectByMouse: true

                            selectionColor: Core.Theme.accentSoft

                            // Two-way bridge to popup.passwordText
                            onTextChanged: popup.passwordText = passwordInput.text

                            Component.onCompleted: passwordInput.text = popup.passwordText

                            Connections {
                                target: popup

                                function onPasswordTextChanged() {
                                    if (passwordInput.text !== popup.passwordText)
                                        passwordInput.text = popup.passwordText;
                                }

                                function onFocusPulseChanged() {
                                    passwordInput.forceActiveFocus();
                                }
                            }

                            onAccepted: {
                                if (text === "")
                                    return;
                                popup.svc.connectWifi(popup.passwordFor, text);
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter

                                visible: passwordInput.text === ""

                                text: "Password for " + popup.passwordFor

                                elide: Text.ElideRight

                                width: parent.width

                                font.family: Core.Theme.fontFamily
                                font.pixelSize: Core.Theme.fontSize

                                color: Core.Theme.foregroundFaint
                            }
                        }

                        Rectangle {
                            id: pwGo

                            anchors.right: parent.right
                            anchors.rightMargin: 4
                            anchors.verticalCenter: parent.verticalCenter

                            width: 26
                            height: 26

                            radius: 13

                            color: pwGoMouse.containsMouse ? Core.Theme.surfaceHover : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: "\udb81\udc0c"

                                font.family: Core.Theme.fontFamily
                                font.pixelSize: 13

                                color: passwordInput.text !== "" ? Core.Theme.accent : Core.Theme.foregroundFaint
                            }

                            MouseArea {
                                id: pwGoMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (passwordInput.text === "")
                                        return;
                                    popup.svc.connectWifi(popup.passwordFor, passwordInput.text);
                                }
                            }
                        }
                    }

                    Text {
                        width: parent.width

                        visible: popup.passwordError !== ""

                        text: popup.passwordError

                        leftPadding: 10

                        wrapMode: Text.WordWrap

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: Core.Theme.fontSizeSmall

                        color: Core.Theme.danger
                    }
                }
            }

            // Network list

            Item {
                width: parent.width

                readonly property int maxListHeight: 250

                height: popup.svc.wifiEnabled ? Math.min(list.contentHeight, maxListHeight) : 0

                clip: true

                // Deliberately NO Behavior on height here. The card

                ListView {
                    id: list

                    anchors.fill: parent

                    clip: true

                    spacing: 1

                    boundsBehavior: Flickable.StopAtBounds

                    model: popup.svc.networkModel

                    // Per-row motion

                    add: Transition {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 160
                            easing.type: Easing.OutQuint
                        }

                        NumberAnimation {
                            property: "scale"
                            from: 0.86
                            to: 1
                            duration: 180
                            easing.type: Easing.OutQuint
                        }
                    }

                    remove: Transition {
                        NumberAnimation {
                            property: "opacity"
                            to: 0
                            duration: 160
                            easing.type: Easing.InQuint
                        }

                        NumberAnimation {
                            property: "scale"
                            to: 0.8
                            duration: 160
                            easing.type: Easing.InQuint
                        }
                    }

                    displaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 170
                            easing.type: Easing.OutQuint
                        }
                    }

                    addDisplaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 170
                            easing.type: Easing.OutQuint
                        }
                    }

                    removeDisplaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 160
                            easing.type: Easing.OutQuint
                        }
                    }

                    delegate: Components.ListRow {
                        id: netRow

                        // `signal` is a reserved QML keyword, so the model role is called `strength`.
                        required property string ssid
                        required property int strength
                        required property string security
                        required property bool secured
                        required property bool inUse
                        required property bool saved

                        width: list.width

                        icon: popup.svc.signalIcon(netRow.strength, netRow.secured)

                        title: netRow.ssid

                        subtitle: netRow.inUse ? "Connected" : (netRow.saved ? "Saved · " : "") + (netRow.secured ? netRow.security : "Open")

                        trailing: netRow.secured ? "\udb80\udfba " + netRow.strength + "%" : netRow.strength + "%"

                        active: netRow.inUse

                        busy: popup.svc.pendingSsid === netRow.ssid && popup.svc.busy

                        // Left click

                        onActivated: {
                            if (netRow.inUse) {
                                popup.svc.disconnectWifi();
                                return;
                            }

                            popup.requestConnect(netRow.ssid, netRow.secured, netRow.saved);
                        }

                        // Right click

                        onContextRequested: function (mx, my) {
                            const items = [];

                            if (netRow.inUse) {
                                items.push({
                                    icon: "\udb80\udd75",
                                    label: "Disconnect",
                                    action: function () {
                                        popup.svc.disconnectWifi();
                                    }
                                });
                            } else {
                                items.push({
                                    icon: "\udb80\udd74",
                                    label: netRow.saved ? "Connect" : "Connect…",
                                    action: function () {
                                        popup.requestConnect(netRow.ssid, netRow.secured, netRow.saved);
                                    }
                                });
                            }

                            if (netRow.saved) {
                                items.push({
                                    icon: Core.Icons.refresh,
                                    label: "Reconnect",
                                    action: function () {
                                        popup.svc.disconnectWifi();
                                        popup.svc.connectWifi(netRow.ssid, "");
                                    }
                                });

                                items.push({
                                    icon: "\udb80\udc93",
                                    label: "Enable autoconnect",
                                    action: function () {
                                        popup.svc.setAutoconnect(netRow.ssid, true);
                                    }
                                });

                                items.push({
                                    icon: Core.Icons.close,
                                    label: "Disable autoconnect",
                                    action: function () {
                                        popup.svc.setAutoconnect(netRow.ssid, false);
                                    }
                                });
                            }

                            items.push({
                                separator: true
                            });

                            items.push({
                                icon: "\udb81\udcd6",
                                label: "Copy SSID",
                                action: function () {
                                    Quickshell.clipboardText = netRow.ssid;
                                }
                            });

                            items.push({
                                icon: "\udb80\udd7c",
                                label: "Network details",
                                action: function () {
                                    popup.svc.openEditor();
                                    Core.PopupManager.close();
                                }
                            });

                            if (netRow.saved) {
                                items.push({
                                    separator: true
                                });

                                items.push({
                                    icon: "\udb80\uddb4",
                                    label: "Forget network",
                                    danger: true,
                                    action: function () {
                                        popup.svc.forgetNetwork(netRow.ssid);
                                    }
                                });
                            }

                            popup.openMenu(mx, my, items);
                        }
                    }
                }
            }

            // Empty / disabled states

            Item {
                width: parent.width

                clip: true

                readonly property bool showEmpty: !popup.svc.wifiEnabled || popup.svc.networkModel.count === 0

                height: showEmpty ? 56 : 0

                opacity: showEmpty ? 1.0 : 0.0

                Behavior on height {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutQuint
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuint
                    }
                }

                Column {
                    anchors.centerIn: parent

                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: popup.svc.wifiEnabled ? "\udb82\udd2f" : "\udb82\udd2d"

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: 20

                        color: Core.Theme.foregroundFaint
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: popup.svc.wifiEnabled ? "No networks in range" : "Wi-Fi is turned off"

                        font.family: Core.Theme.fontFamily
                        font.pixelSize: Core.Theme.fontSizeSmall

                        color: Core.Theme.foregroundMuted
                    }
                }
            }
        }
    }
}
