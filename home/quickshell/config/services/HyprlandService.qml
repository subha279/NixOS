pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Hyprland

// HyprlandService
//
// The only file that imports Quickshell.Hyprland, so the compositor coupling
// stays in one place and the bar module remains a pure view.

Singleton {
    id: root

    // Null until the IPC connection is up, so everything below is guarded
    // rather than assuming a workspace exists.
    readonly property var focused: Hyprland.focusedWorkspace

    readonly property bool available: root.focused !== null

    readonly property int current: root.available ? root.focused.id : 0

    readonly property string name: root.available ? root.focused.name : ""

    readonly property bool urgent: root.available && root.focused.urgent

    // Hyprland names a numbered workspace after its own id, so the name is
    // only worth showing when one has actually been labelled.
    readonly property string label: {
        if (!root.available)
            return "-";

        if (root.name.length > 0 && root.name !== String(root.current))
            return root.name;

        return String(root.current);
    }

    function focus(n) {
        Hyprland.dispatch("workspace " + n);
    }

    // e+1 / e-1 skip empty workspaces, which is what makes a scroll over the
    // indicator land somewhere with windows in it.
    function step(direction) {
        Hyprland.dispatch(direction > 0 ? "workspace e+1" : "workspace e-1");
    }
}
