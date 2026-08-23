pragma Singleton

import QtQuick

// PopupManager

QtObject {
    id: root

    // Currently open popup id ("" == nothing open)
    property string current: ""

    // Screen-space anchor supplied by the bar module that opened it
    property real anchorCenter: 0
    property real anchorBottom: 0

    // A nested context menu is open somewhere (used to keep the parent popup from closing on outside-click pass-through)
    property bool contextMenuOpen: false

    // Do-not-disturb.
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
