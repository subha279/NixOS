pragma Singleton

import QtQuick
import Quickshell

// The alias is load-bearing.
//
// services/qmldir registers THIS file as a composite type named
// `NotificationServer`. A bare `NotificationServer { }` below therefore
// resolved back to this singleton instead of the Quickshell type, so the
// real D-Bus object was never constructed, org.freedesktop.Notifications
// was never claimed, and every notification on the system was dropped.
import Quickshell.Services.Notifications as Notifs

import "../core" as Core

// ================================================================
// NotificationServer
// ----------------------------------------------------------------
// Owns TWO separate lists, and keeping them separate is the whole
// point of this file:
//
//   notifications  persistent history, shown in the panel. Entries
//                  live until the user clears them.
//
//   toasts         the transient on-screen overlay. Entries live
//                  for a few seconds and then leave on their own.
//
// The overlay used to be bound directly to `notifications`, so a
// toast could only disappear when its history entry was destroyed
// — which is why they sat on screen until clicked.
// ================================================================

Singleton {
    id: root

    // On-screen lifetime used when an app asks for the server
    // default (expire_timeout of -1).
    readonly property int defaultTimeout: 5000

    // Apps are allowed to request a longer life, but not forever;
    // a 5-minute toast is always a bug in the sending app.
    readonly property int maxTimeout: 20000

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

    // On-screen lifetime in ms. Returns 0 to mean "never auto
    // dismiss", which is reserved for critical notifications.
    //
    // Note on expire_timeout of 0: the spec says "never expire",
    // but in practice a lot of apps send 0 when they simply do not
    // care, which turns the overlay into a wall of stuck cards.
    // Only genuine critical urgency gets to be sticky here.
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
        // Do-not-disturb suppresses the overlay only. The entry is
        // still tracked and still readable in the panel.
        if (Core.PopupManager.dnd)
            return;
        const next = root.toasts.slice();
        next.push(n);

        while (next.length > root.maxVisible)
            next.shift();

        root.toasts = next;
    }

    // Removes the card from the overlay but leaves the history
    // entry alone. This is what a timeout does.
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

            // If the sender or the panel closes this entry, make
            // sure a live toast for it does not outlive it.
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

    // Turning on do-not-disturb clears whatever is already on
    // screen, otherwise the current batch would hang around.
    Connections {
        target: Core.PopupManager

        function onDndChanged() {
            if (Core.PopupManager.dnd)
                root.clearToasts();
        }
    }
}
