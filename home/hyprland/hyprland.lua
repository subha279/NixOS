--------------------------------------------------
-- Aurora Hyprland
--
-- Main configuration entry point.
--
-- Theme source:
--
--   ~/.config/aurora/active-theme.lua
--
-- The visual theme is handled by:
--
--   config/theme.lua
--
-- Stylix provides system-wide desktop integration.
--
-- Wallust is not used for colors.
--------------------------------------------------

--------------------------------------------------
-- Core Configuration
--------------------------------------------------

require("config.variables")
require("config.env")
require("config.monitor")
require("config.general")
require("config.decoration")
require("config.animation")
require("config.input")
require("config.layout")
require("config.windowrules")
require("config.layerules")
require("config.startup")
require("config.keybinds")
require("config.misc")

--------------------------------------------------
-- Aurora Theme
--------------------------------------------------

require("config.theme")
