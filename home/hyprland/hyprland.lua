--------------------------------------------------
-- Hyprland Lua Configuration
-- Main Entry Point
--
-- This file should ONLY load modules.
-- All configuration belongs inside /config.
--------------------------------------------------

------------------------
-- Core Configuration --
------------------------
local colors = require("stylix-colors")

require("config.variables")
require("config.env")
require("config.monitor")

-----------------------
-- Appearance ---------
-----------------------

require("config.theme")
require("config.general")
require("config.decoration")
require("config.animation")

-----------------------
-- Input & Layout -----
-----------------------

require("config.input")
require("config.layout")

-----------------------
-- Window Rules -------
-----------------------

require("config.windowrules")
require("config.layerules")

-----------------------
-- Startup ------------
-----------------------

require("config.startup")

-----------------------
-- Keybindings --------
-----------------------

require("config.keybinds")

-----------------------
-- Misc ---------------
-----------------------

require("config.misc")
