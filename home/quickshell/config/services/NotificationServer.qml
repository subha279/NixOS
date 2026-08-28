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

    // trackedNotifications has no upper bound of its own, so on a long uptime it
    // grows until the shell is restarted. The oldest entries are dropped past
    // this point.
    readonly property int maxHistory: 100

    property alias notifications: server.trackedNotifications

    property var toasts: []

    // The notification whose reply field is currently open, or null.
    //
    // Owned here rather than by either surface, because the toast overlay has to
    // switch its keyboard focus mode on it and the centre has to be able to close
    // it. Only one reply can be open at a time.
    property var replyTarget: null

    function beginReply(n) {
        if (root.hasInlineReply(n))
            root.replyTarget = n;
    }

    function cancelReply() {
        root.replyTarget = null;
    }

    function isReplying(n) {
        return n !== null && n !== undefined && root.replyTarget === n;
    }

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

    // The sender asked for this one NOT to be kept in a notification area.
    // Volume and brightness popups from other apps set it.
    function isTransient(n) {
        try {
            return n !== null && n !== undefined && n.transient === true;
        } catch (e) {
            return false;
        }
    }

    // The sender wants the entry to survive an action being invoked, so it can
    // keep updating it. Media players use it for their transport buttons.
    function isResident(n) {
        try {
            return n !== null && n !== undefined && n.resident === true;
        } catch (e) {
            return false;
        }
    }

    // Re-emitted from a previous generation after a config reload.
    function isLastGeneration(n) {
        try {
            return n !== null && n !== undefined && n.lastGeneration === true;
        } catch (e) {
            return false;
        }
    }

    // The sender attached a reply field, e.g. a chat client.
    function hasInlineReply(n) {
        try {
            return n !== null && n !== undefined && n.hasInlineReply === true;
        } catch (e) {
            return false;
        }
    }

    // Action button labels are icon NAMES rather than text when the sender set
    // the action-icons hint. See NotificationAction.identifier.
    function hasActionIcons(n) {
        try {
            return n !== null && n !== undefined && n.hasActionIcons === true;
        } catch (e) {
            return false;
        }
    }

    function replyPlaceholder(n) {
        try {
            if (n && n.inlineReplyPlaceholder && String(n.inlineReplyPlaceholder) !== "")
                return String(n.inlineReplyPlaceholder);
        } catch (e) {}

        return "Reply";
    }

    // Best label for the sending application.
    function appLabel(n) {
        if (!n)
            return "";

        try {
            if (n.appName && String(n.appName) !== "")
                return String(n.appName);
        } catch (e) {}

        try {
            if (n.desktopEntry && String(n.desktopEntry) !== "")
                return String(n.desktopEntry);
        } catch (e) {}

        return "Notification";
    }

    // Icon source for a notification, or "" when the sender gave us nothing
    // usable and the caller should fall back to a glyph.
    //
    // `image` already covers image-data, image_data, icon_data AND
    // image-path/image_path: Quickshell resolves all of them into this one
    // property, so there is no separate path to check.
    function iconFor(n) {
        if (!n)
            return "";

        try {
            if (n.image !== undefined && n.image !== null && String(n.image) !== "")
                return String(n.image);
        } catch (e) {}

        try {
            if (n.appIcon !== undefined && n.appIcon !== null && String(n.appIcon) !== "")
                return Quickshell.iconPath(String(n.appIcon), true);
        } catch (e) {}

        return "";
    }

    // Arrival timestamps
    //
    // The notification spec carries no timestamp, and Quickshell does not add
    // one, so it has to be recorded here on arrival. Keyed by notification id and
    // dropped again when the entry closes.
    property var stamps: ({})

    // Bumped on a timer so relative "5m" labels re-evaluate. Read it inside an
    // age binding to make that binding depend on it.
    property int ageTick: 0

    function ageOf(n) {
        try {
            if (!n || n.id === undefined)
                return 0;

            const t = root.stamps[n.id];

            if (t === undefined)
                return 0;

            return Date.now() - t;
        } catch (e) {
            return 0;
        }
    }

    function ageText(n) {
        const seconds = Math.floor(root.ageOf(n) / 1000);

        if (seconds < 45)
            return "now";

        const minutes = Math.floor(seconds / 60);

        if (minutes < 1)
            return "now";

        if (minutes < 60)
            return minutes + "m";

        const hours = Math.floor(minutes / 60);

        if (hours < 24)
            return hours + "h";

        return Math.floor(hours / 24) + "d";
    }

    // Only needed while the panel that shows these labels is actually up.
    Timer {
        interval: 30000

        repeat: true

        running: Core.PopupManager.isOpen("notifications")

        onTriggered: root.ageTick++
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
        // Do-not-disturb hides the overlay, but never a critical alert: those are
        // the low-battery and imminent-shutdown warnings, and they stay on screen.
        // Everything else still reaches history, so nothing is actually lost.
        if (Core.PopupManager.dnd && !root.isCritical(n))
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

        // The reply field went with the card, so the overlay must be allowed to
        // give keyboard focus back.
        if (root.replyTarget === n)
            root.replyTarget = null;
    }

    // A toast reached the end of its life.
    //
    // Transient entries are discarded rather than filed: the sender explicitly
    // asked not to have them persisted. Everything else stays for the centre.
    function expireToast(n) {
        if (root.isTransient(n)) {
            root.dismiss(n);
            return;
        }

        root.hideToast(n);
    }

    function clearToasts() {
        if (root.toasts.length > 0)
            root.toasts = [];

        root.replyTarget = null;
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

    // Invoking an action already closes the notification unless the sender marked
    // it resident, so this must NOT dismiss afterwards: that would be a second
    // close on a destroyed object, which Quickshell logs as
    // "Cannot close destroyed notification".
    //
    // A resident entry deliberately survives, so only its toast is taken down.
    function invokeAction(n, action) {
        if (!n || !action)
            return;

        try {
            action.invoke();
        } catch (e) {
            // Sender dropped off the bus before we got here.
        }

        if (root.isResident(n))
            root.hideToast(n);
    }

    // Same closing semantics as invokeAction: sendInlineReply() closes a
    // non-resident notification itself.
    function sendReply(n, text) {
        if (!n || text === undefined || text === null || String(text) === "")
            return false;

        // Quickshell logs a critical error rather than throwing if the entry has
        // no reply action, so the guard has to happen here.
        if (!root.hasInlineReply(n))
            return false;

        try {
            n.sendInlineReply(String(text));
        } catch (e) {
            return false;
        }

        if (root.replyTarget === n)
            root.replyTarget = null;

        if (root.isResident(n))
            root.hideToast(n);

        return true;
    }

    // Drop the oldest history entries once the cap is passed.
    function prune() {
        const list = server.trackedNotifications;

        if (!list || !list.values)
            return;

        // Snapshot first: dismissing mutates the model we are walking.
        const values = list.values.slice();

        const excess = values.length - root.maxHistory;

        if (excess <= 0)
            return;

        for (var i = 0; i < excess; i++)
            root.dismiss(values[i]);
    }

    Notifs.NotificationServer {
        id: server

        // Bring the unread backlog back across a config reload instead of wiping
        // it. Restored entries arrive flagged as lastGeneration, which is what
        // keeps them from re-toasting below.
        keepOnReload: true

        // Every one of these is opt-in, and an unset flag is not cosmetic: it is
        // reported through GetCapabilities, and well-behaved senders read that
        // and downgrade what they send. Leaving them off is how a desktop ends up
        // quietly receiving less than every other desktop.
        //
        // Nothing is advertised here that the UI does not actually render.
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true

        imageSupported: true

        actionsSupported: true
        actionIconsSupported: true

        // Lets chat clients attach a reply field. Both the toast and the centre
        // render one; without this flag they never offer it in the first place.
        inlineReplySupported: true

        persistenceSupported: true

        onNotification: function (notification) {
            // Required. An untracked notification is destroyed the moment this
            // handler returns, which would take the toast down with it.
            notification.tracked = true;

            // Captured now: the id is unreadable once the object is destroyed, so
            // the cleanup closure below cannot go and fetch it later.
            var id = -1;

            try {
                id = notification.id;
            } catch (e) {}

            if (id !== -1)
                root.stamps[id] = Date.now();

            // If the sender or the panel closes this entry, make sure a live toast for it does not outlive it.
            try {
                notification.closed.connect(function () {
                    root.hideToast(notification);

                    if (root.replyTarget === notification)
                        root.replyTarget = null;

                    if (id !== -1)
                        delete root.stamps[id];
                });
            } catch (e) {
                // Signal not available in this build; the toast
                // still expires on its own timer.
            }

            root.prune();

            // Restored by keepOnReload. It is already in history and was already
            // shown once, so toasting it would replay the entire backlog every
            // time the config is saved.
            if (root.isLastGeneration(notification))
                return;

            root.showToast(notification);
        }
    }

    // Turning on do-not-disturb clears whatever is already on screen, otherwise the current batch would hang around.
    Connections {
        target: Core.PopupManager

        function onDndChanged() {
            if (!Core.PopupManager.dnd)
                return;

            // Criticals stay: they are not what do-not-disturb is for.
            const kept = [];

            for (var i = 0; i < root.toasts.length; i++) {
                if (root.isCritical(root.toasts[i]))
                    kept.push(root.toasts[i]);
            }

            if (kept.length !== root.toasts.length)
                root.toasts = kept;
        }
    }
}
