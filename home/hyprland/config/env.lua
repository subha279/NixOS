--------------------------------------------------
-- Environment Variables
-- https://wiki.hypr.land/Configuring/Environment-variables/
--------------------------------------------------
--
-- Only compositor-specific variables live here.
--
-- Anything the whole session needs is exported once,
-- from Nix, and is NOT repeated here:
--
--   modules/session/environment.nix   session-wide
--   home/zsh/environment.nix          shell / user
--
-- Removed as duplicates of environment.sessionVariables.
-- Those are NixOS level, so PAM exports them into every
-- session before Hyprland even starts:
--
--   XDG_SESSION_TYPE
--   MOZ_ENABLE_WAYLAND
--   SDL_VIDEODRIVER
--   CLUTTER_BACKEND
--
-- EDITOR / BROWSER / TERMINAL are deliberately kept below
-- even though home/zsh/environment.nix also sets them.
-- home.sessionVariables is written to hm-session-vars.sh and
-- is only sourced by login shells, so an app launched from a
-- Hyprland keybind would never see it.
--------------------------------------------------

--------------------------------------------------
-- Cursor
--------------------------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

--------------------------------------------------
-- Wayland
--------------------------------------------------

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

--------------------------------------------------
-- Qt Applications
--------------------------------------------------

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

--------------------------------------------------
-- GTK Applications
--------------------------------------------------

hl.env("GDK_BACKEND", "wayland,x11")


--------------------------------------------------
-- Java Applications
--------------------------------------------------

hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

--------------------------------------------------
-- Electron Applications
--------------------------------------------------

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

--------------------------------------------------
-- NVIDIA (Uncomment if using NVIDIA)
--------------------------------------------------

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("GBM_BACKEND", "nvidia-drm")
-- hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")

--------------------------------------------------
-- Misc
--------------------------------------------------


--------------------------------------------------
-- Default Applications
--------------------------------------------------
--
-- Also set in home/zsh/environment.nix for shells.
-- Repeated here so graphical children of Hyprland
-- inherit them regardless of how the session began.
--
--------------------------------------------------

hl.env("EDITOR", "nvim")
hl.env("BROWSER", "firefox")
hl.env("TERMINAL", "kitty")
