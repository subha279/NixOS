pragma Singleton

import QtQuick
import Quickshell

// The alias is load-bearing.
import Quickshell.Services.Notifications as Notifs

import "../core" as Core

// NotificationServer

Singleton {
    id: root

    // On-screen lifetime used when an app asks for the server default (expire_timeout of -1).
    readonly property int defaultTimeout: 3500

    // Apps are allowed to request a longer life, but not forever;
    // a 5-minute toast is always a bug in the sending app.
    readonly property int maxTimeout: 10000

    // Older toasts are pushed out once this many are stacked.
    readonly property int maxVisible: 4

    property alias notifications: server.trackedNotifications

    property var toasts: []

    // Urgency 2 == Critical in the freedesktop spec. Guarded
    // because not every sender populates the hint.
    function isCritical(n) {
        try {
            if (n === null || n === undefined)
                return false;

            if (n.urgency === undefined || n.urgency === null)
                return false;

            return Number(n.urgency) === 2;
        } catch (e) {
            return false;
        }
    }

    // On-screen lifetime in ms.
    function lifetimeFor(n) {
        if (root.isCritical(n))
            return 0;

        var t = -1;

        try {
            if (n !== null && n !== undefined && n.expireTimeout !== undefined && n.expireTimeout !== null)
                t = Number(n.expireTimeout);
        } catch (e) {
            t = -1;
        }

        if (isNaN(t) || t <= 0)
            return root.defaultTimeout;

        return Math.min(t, root.maxTimeout);
    }

    function showToast(n) {
        // Do-not-disturb suppresses the overlay only.
        if (Core.PopupManager.dnd)
            return;
        const next = root.toasts.slice();
        next.push(n);

        while (next.length > root.maxVisible)
            next.shift();

        root.toasts = next;
    }

    // Removes the card from the overlay but leaves the history entry alone.
    function hideToast(n) {
        const next = [];

        for (var i = 0; i < root.toasts.length; i++) {
            if (root.toasts[i] !== n)
                next.push(root.toasts[i]);
        }

        if (next.length !== root.toasts.length)
            root.toasts = next;
    }

    function clearToasts() {
        if (root.toasts.length > 0)
            root.toasts = [];
    }

    // Removes the card AND the history entry.
    function dismiss(n) {
        root.hideToast(n);

        try {
            n.dismiss();
        } catch (e) {
            try {
                n.expire();
            } catch (e2) {
                // Nothing more we can do; the entry will go away
                // when the sender closes it.
            }
        }
    }

    Notifs.NotificationServer {
        id: server

        bodySupported: true
        bodyImagesSupported: true
        imageSupported: true

        persistenceSupported: true
        actionsSupported: true

        onNotification: function (notification) {
            notification.tracked = true;

            // If the sender or the panel closes this entry, make sure a live toast for it does not outlive it.
            try {
                notification.closed.connect(function () {
                    root.hideToast(notification);
                });
            } catch (e) {
                // Signal not available in this build; the toast
                // still expires on its own timer.
            }

            root.showToast(notification);
        }
    }

    // Turning on do-not-disturb clears whatever is already on screen, otherwise the current batch would hang around.
    Connections {
        target: Core.PopupManager

        function onDndChanged() {
            if (Core.PopupManager.dnd)
                root.clearToasts();
        }
    }
}
