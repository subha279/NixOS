pragma Singleton

import QtQuick
import Quickshell

import Quickshell.Services.Notifications as Notifs

import "../core" as Core


Singleton {
    id: root

    readonly property int defaultTimeout: 3500

    readonly property int maxTimeout: 10000

    readonly property int maxVisible: 4

    property alias notifications: server.trackedNotifications

    property var toasts: []

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
        if (Core.PopupManager.dnd)
            return;
        const next = root.toasts.slice();
        next.push(n);

        while (next.length > root.maxVisible)
            next.shift();

        root.toasts = next;
    }

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

    function dismiss(n) {
        root.hideToast(n);

        try {
            n.dismiss();
        } catch (e) {
            try {
                n.expire();
            } catch (e2) {
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

            try {
                notification.closed.connect(function () {
                    root.hideToast(notification);
                });
            } catch (e) {
            }

            root.showToast(notification);
        }
    }

    Connections {
        target: Core.PopupManager

        function onDndChanged() {
            if (Core.PopupManager.dnd)
                root.clearToasts();
        }
    }
}
