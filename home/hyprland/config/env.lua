-- Environment Variables

hl.env("XCURSOR_SIZE", "30")
hl.env("HYPRCURSOR_SIZE", "30")

-- Wayland

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Qt Applications

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- GTK Applications

hl.env("GDK_BACKEND", "wayland,x11")

-- Java Applications

hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- Electron Applications

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- NVIDIA (Uncomment if using NVIDIA)

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("GBM_BACKEND", "nvidia-drm") hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")

-- Default Applications

hl.env("EDITOR", "nvim")
hl.env("BROWSER", "zen")
hl.env("TERMINAL", "kitty")
