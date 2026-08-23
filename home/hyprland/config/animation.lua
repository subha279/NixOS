-- -----------------------------------------------------
-- Animations — name "Fluid"
-- speed = duration in ds (1ds = 100ms) — higher is SLOWER
-- -----------------------------------------------------

hl.config({
	animations = {
		enabled = true,
	},
})

-- Curves — real easing values, one job each
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeOutExpo",  { type = "bezier", points = { { 0.16, 1 }, { 0.30, 1 } } })

-- Accelerate (exits) — clean, no bounce on the way out
hl.curve("easeInQuint",  { type = "bezier", points = { { 0.64, 0 }, { 0.78, 0 } } })

-- Symmetric (resize, zoom)
hl.curve("easeInOutQuint", { type = "bezier", points = { { 0.83, 0 }, { 0.17, 1 } } })

-- Overshoot — ONLY for windowsIn / workspaces / scratchpad. Never fades.
hl.curve("softBack", { type = "bezier", points = { { 0.34, 1.30 }, { 0.64, 1 } } })
hl.curve("hardBack", { type = "bezier", points = { { 0.20, 1.45 }, { 0.55, 1 } } })

-- Utility
hl.curve("almostLinear", { type = "bezier", points = { { 0.50, 0.50 }, { 0.75, 1 } } })
hl.curve("linear",       { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("snappy",       { type = "bezier", points = { { 0.15, 0 }, { 0.10, 1 } } })

-- Windows
hl.animation({ leaf = "global",     enabled = true, speed = 3.0, bezier = "easeOutQuint" })

hl.animation({ leaf = "windows",     enabled = true, speed = 3.0, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3.2, bezier = "softBack",   style = "popin 88%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 1.8, bezier = "easeInQuint", style = "popin 94%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.6, bezier = "easeOutExpo" })

-- Fades — strictly monotonic curves, exits faster than entrances
hl.animation({ leaf = "fade",       enabled = true, speed = 2.0, bezier = "almostLinear" })
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 2.0, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 1.3, bezier = "almostLinear" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeDim",    enabled = true, speed = 2.0, bezier = "almostLinear" })
hl.animation({ leaf = "fadePopups", enabled = true, speed = 1.5, bezier = "almostLinear" })

-- Layers (waybar, rofi/launcher, notifications)
hl.animation({ leaf = "layers",         enabled = true, speed = 2.4, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",       enabled = true, speed = 2.4, bezier = "softBack",    style = "popin 90%" })
hl.animation({ leaf = "layersOut",      enabled = true, speed = 1.6, bezier = "easeInQuint", style = "popin 94%" })
hl.animation({ leaf = "fadeLayersIn",   enabled = true, speed = 1.8, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut",  enabled = true, speed = 1.3, bezier = "almostLinear" })

-- Workspaces — the one place a rubber-band actually looks expensive
hl.animation({ leaf = "workspaces",    enabled = true, speed = 2.8, bezier = "easeOutExpo" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 2.8, bezier = "softBack", style = "slidefade 15%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2.6, bezier = "softBack", style = "slidefade 15%" })

hl.animation({ leaf = "specialWorkspace",    enabled = true, speed = 2.6, bezier = "softBack",    style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 2.8, bezier = "hardBack",    style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1.8, bezier = "easeInQuint", style = "slidevert" })

-- Border & zoom
hl.animation({ leaf = "border",      enabled = true, speed = 2.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle", enabled = false, speed = 30, bezier = "linear" }) -- set true + "loop" for a rotating gradient (costs GPU)
hl.animation({ leaf = "zoomFactor",  enabled = true, speed = 2.5, bezier = "easeInOutQuint" })
