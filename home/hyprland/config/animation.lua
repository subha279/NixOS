hl.config({
	animations = {
		enabled = true,
	},
})

hl.curve("standard", { type = "bezier", points = { { 0.20, 0 }, { 0, 1 } } })
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.30, 1 } } })
hl.curve("easeInQuint", { type = "bezier", points = { { 0.64, 0 }, { 0.78, 0 } } })
hl.curve("easeInOutQuint", { type = "bezier", points = { { 0.83, 0 }, { 0.17, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.50, 0.50 }, { 0.75, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 3.0, bezier = "easeOutQuint" })

hl.animation({ leaf = "windows", enabled = true, speed = 3.0, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.2, bezier = "standard", style = "popin 96%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.4, bezier = "easeInQuint", style = "popin 96%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.6, bezier = "easeOutExpo" })

hl.animation({ leaf = "fade", enabled = true, speed = 2.0, bezier = "almostLinear" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.0, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.3, bezier = "almostLinear" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 2.0, bezier = "almostLinear" })
hl.animation({ leaf = "fadePopups", enabled = true, speed = 1.5, bezier = "almostLinear" })

hl.animation({ leaf = "layers", enabled = true, speed = 2.0, bezier = "standard" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1.8, bezier = "standard", style = "popin 96%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.2, bezier = "easeInQuint", style = "popin 96%" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.6, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.2, bezier = "almostLinear" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 2.8, bezier = "easeOutExpo" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2.6, bezier = "easeOutExpo", style = "slidefade 15%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2.4, bezier = "easeOutExpo", style = "slidefade 15%" })

hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.4, bezier = "easeOutQuint", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 2.4, bezier = "standard", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1.6, bezier = "easeInQuint", style = "slidevert" })

hl.animation({ leaf = "border", enabled = true, speed = 2.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle", enabled = false, speed = 30, bezier = "linear" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 2.5, bezier = "easeInOutQuint" })
