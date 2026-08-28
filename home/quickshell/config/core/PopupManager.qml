pragma Singleton

import QtQuick


QtObject {
    id: root

    property string current: ""

    property real anchorCenter: 0
    property real anchorBottom: 0

    property bool contextMenuOpen: false

    property bool dnd: false

    function isOpen(id) {
        return root.current === id;
    }

    function open(id, center, bottom) {
        root.anchorCenter = center;
        root.anchorBottom = bottom;
        root.current = id;
    }

    function toggle(id, center, bottom) {
        if (root.current === id) {
            root.close();
            return;
        }

        root.open(id, center, bottom);
    }

    function close() {
        root.contextMenuOpen = false;
        root.current = "";
    }
}
