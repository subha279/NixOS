pragma Singleton

import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    NotificationServer {
        id: server

        bodySupported: true
        bodyImagesSupported: true
        imageSupported: true

        persistenceSupported: true
        actionsSupported: true

        onNotification: function(notification) {
            notification.tracked = true
        }
    }

    property alias notifications: server.trackedNotifications
}
