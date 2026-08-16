import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import "../core" as Core
import "../services" as Services

PanelWindow {
    id: root

    anchors.top: true
    anchors.right: true

    margins.top: 48
    margins.right: 14

    implicitWidth: 340
    implicitHeight: Math.min(
        notificationColumn.implicitHeight,
        600
    )

    color: "transparent"

    WlrLayershell.namespace:
        "aurora-notifications"

    exclusionMode:
        ExclusionMode.Ignore

    property var notifications:
        Services.NotificationServer.notifications

    // Do-not-disturb silences the toasts. They are still collected
    // and remain readable in the notification panel.
    visible: !Core.PopupManager.dnd
            && !Core.PopupManager.isOpen("notifications")

    ColumnLayout {
        id: notificationColumn

        anchors.right: parent.right

        spacing: 8

        Repeater {
            model: root.notifications

            delegate: Rectangle {
                id: notification

                required property var modelData

                Layout.preferredWidth: 340
                Layout.preferredHeight: 86

                radius: 14

                color: Core.Theme.background

                border.width: 1
                border.color: Core.Theme.border

                opacity: 0.98

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12

                    spacing: 10

                    Text {
                        Layout.preferredWidth: 28

                        text: "󰂚"

                        font.family:
                            "JetBrains Mono Nerd Font"

                        font.pixelSize: 20

                        color:
                            Core.Theme.accent

                        horizontalAlignment:
                            Text.AlignHCenter
                    }

                    ColumnLayout {
                        Layout.fillWidth: true

                        spacing: 3

                        Text {
                            Layout.fillWidth: true

                            text:
                                notification.modelData.summary

                            font.family:
                                "JetBrains Mono Nerd Font"

                            font.pixelSize: 13

                            font.bold: true

                            color:
                                Core.Theme.foreground

                            elide:
                                Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                notification.modelData.body

                            font.family:
                                "JetBrains Mono Nerd Font"

                            font.pixelSize: 11

                            color:
                                Core.Theme.foregroundMuted

                            maximumLineCount: 2

                            wrapMode:
                                Text.Wrap

                            elide:
                                Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        notification.modelData.expire()
                    }
                }
            }
        }
    }
}
