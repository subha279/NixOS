//@ pragma UseQApplication

import Quickshell
import Quickshell.Wayland

import "components"
import "modules"

Scope {
    id: root

    // The bar itself
    Bar {}

    // Dropdowns live at the root so they render above everything
    // and are never clipped by the bar window.
    //
    // PopupManager guarantees only one can be open at a time, so
    // opening Wi-Fi automatically animates Bluetooth closed.
    NetworkPopup {}
    BluetoothPopup {}
    BatteryPopup {}
    AudioPopup {}
    CalendarPopup {}
    NotificationPopup {}

    // Transient notification toasts (top right)
    Notifications {}
}
