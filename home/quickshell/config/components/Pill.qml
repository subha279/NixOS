import QtQuick

import "../core" as Core

Rectangle {
    id: root

    implicitHeight: 36

    radius: height / 2

    color: Core.Theme.background

    border.width: 1
    border.color: Core.Theme.border

    antialiasing: true
}
