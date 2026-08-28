import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import "../core" as Core
import "../modules" as Modules
import "../services" as Services


PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    margins.top: Core.Theme.barMarginTop

    implicitHeight: Core.Theme.pillHeight + 20

    color: "transparent"

    exclusiveZone: Core.Theme.pillHeight + margins.top + 4

    WlrLayershell.namespace: "aurora-bar"

    mask: Region {
        item: pill
    }


    readonly property bool launcherPopupOpen: Core.PopupManager.current === "launcher" || Core.PopupManager.current === "wallpaper" || Core.PopupManager.current === "theme" || Core.PopupManager.current === "clipboard" || Core.PopupManager.current === "emoji"

    readonly property bool wantExpanded: !root.launcherPopupOpen && (pillHover.hovered || Core.PopupManager.current !== "")

    property bool expanded: false

    onWantExpandedChanged: {
        if (root.wantExpanded) {
            collapseTimer.stop();
            root.expanded = true;
            return;
        }

        collapseTimer.restart();
    }

    Timer {
        id: collapseTimer

        interval: Core.Theme.barCollapseDelay

        onTriggered: root.expanded = root.wantExpanded
    }

    property real reveal: root.expanded ? 1.0 : 0.0

    Behavior on reveal {
        NumberAnimation {
            duration: root.expanded ? Core.Theme.barRevealDuration : Core.Theme.barHideDuration

            easing.type: Easing.BezierSpline
            easing.bezierCurve: Core.Theme.easeStandard
        }
    }

    readonly property bool modulesVisible: root.reveal > 0.012


    readonly property bool osd: Core.OsdController.active && !root.expanded


    property real osdMix: root.osd ? 1.0 : 0.0

    Behavior on osdMix {
        NumberAnimation {
            duration: Core.Theme.barRevealDuration
            easing.type: Easing.OutQuint
        }
    }

    readonly property real barContentWidth: content.implicitWidth + (osdView.implicitWidth - content.implicitWidth) * root.osdMix


    Rectangle {
        id: pillBorder

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        height: Core.Theme.pillHeight + (Core.Theme.borderWidth * 2)

        width: root.barContentWidth + 24 + (Core.Theme.borderWidth * 2)

        radius: height / 2

        antialiasing: true

        color: "transparent"

        border.width: Core.Theme.borderWidth
        border.color: Core.Theme.borderActive


        Rectangle {
            id: pill

            anchors.centerIn: parent

            height: Core.Theme.pillHeight

            width: root.barContentWidth + 24

            radius: height / 2

            color: "transparent"

            antialiasing: true

            Glass {
                anchors.fill: parent
                radius: parent.radius
            }


            HoverHandler {
                id: pillHover
            }


            BarOsd {
                id: osdView

                anchors.centerIn: parent

                opacity: root.osdMix

                visible: root.osdMix > 0.01

                transform: Translate {
                    y: (1.0 - root.osdMix) * 4
                }
            }

            RowLayout {
                id: content

                anchors.centerIn: parent

                spacing: 3

                opacity: 1.0 - root.osdMix

                visible: root.osdMix < 0.99


                Modules.NotificationCenter {
                    id: notificationCenter

                    Layout.preferredWidth: 30 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }


                Modules.Volume {
                    Layout.preferredWidth: 58 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }


                Modules.Brightness {
                    Layout.preferredWidth: 58 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }


                Modules.Clock {
                    id: clockModule

                    Layout.preferredWidth: clockModule.implicitWidth

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    reveal: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }


                Modules.Network {
                    Layout.preferredWidth: 30 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }


                Separator {
                    reveal: root.reveal
                }


                Modules.Bluetooth {
                    Layout.preferredWidth: 30 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }

                Separator {
                    reveal: root.reveal
                }


                Modules.Battery {
                    Layout.preferredWidth: 58 * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible && Services.BatteryService.available

                    opacity: root.reveal
                }


                Separator {
                    reveal: root.reveal

                    available: Services.BatteryService.available
                }


                Modules.Tray {
                    id: tray

                    barWindow: root

                    Layout.preferredWidth: tray.implicitWidth * root.reveal

                    Layout.preferredHeight: Core.Theme.moduleHeight

                    visible: root.modulesVisible

                    opacity: root.reveal
                }
            }
        }
    }

    component Separator: Item {
        id: sep

        property real reveal: 1.0

        property bool available: true

        readonly property color tint: Core.Theme.separator

        Layout.preferredWidth: 1

        Layout.preferredHeight: 18

        visible: sep.available && sep.reveal > 0.012

        opacity: sep.reveal * 0.9

        Rectangle {
            anchors.centerIn: parent

            width: 1

            height: parent.height

            antialiasing: true

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(sep.tint.r, sep.tint.g, sep.tint.b, 0.0)
                }

                GradientStop {
                    position: 0.32
                    color: sep.tint
                }

                GradientStop {
                    position: 0.68
                    color: sep.tint
                }

                GradientStop {
                    position: 1.0
                    color: Qt.rgba(sep.tint.r, sep.tint.g, sep.tint.b, 0.0)
                }
            }
        }
    }
}
