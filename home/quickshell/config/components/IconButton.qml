import QtQuick

import "../core" as Core

Rectangle {
    id: root

    property string icon: ""
    property string tooltip: ""

    signal clicked()

    implicitWidth: 32
    implicitHeight: 32

    radius: height / 2

    color: mouse.containsMouse
        ? Core.Theme.hover
        : "transparent"

    Text {
        anchors.centerIn: parent

        text: root.icon

        color: Core.Theme.foreground

        font.family: Core.Theme.fontFamily
        font.pixelSize: 16

        renderType: Text.NativeRendering
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
