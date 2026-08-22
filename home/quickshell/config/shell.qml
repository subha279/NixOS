//@ pragma UseQApplication

import Quickshell
import Quickshell.Wayland

import "components"
import "modules"

Scope {
    id: root
    Bar {}
    NetworkPopup {}
    BluetoothPopup {}
    BatteryPopup {}
    AudioPopup {}
    CalendarPopup {}
    NotificationPopup {}
    Notifications {}

    // dmenu-style surfaces, replacing Fuzzel. Each registers its own
    // IPC target, so Hyprland opens them with:
    //
    //     qs ipc call launcher  toggle
    //     qs ipc call wallpaper toggle
    //     qs ipc call theme     toggle
    AppLauncher {}
    WallpaperPicker {}
    ThemePicker {}
}
