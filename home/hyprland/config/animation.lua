-- -----------------------------------------------------
-- Animations
-- name "Smooth"
-- -----------------------------------------------------

--------------------------------------------------------------------------------
-- Animation Master Switch
--------------------------------------------------------------------------------
hl.config({
	animations = {
		enabled = true,
	},
})

--------------------------------------------------------------------------------
-- Animation Curves (Bezier)
--------------------------------------------------------------------------------
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.15, 1 }, { 0.29, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.25, 0.05 }, { 0.31, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0.24, 0.10 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.18, 0.10 }, { 0.80, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.22, 0 }, { 0.2, 1 } } })
hl.curve("wave", { type = "bezier", points = { { 0.05, 0.35 }, { 0.05, 1.05 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.04, 0.8 }, { 0.3, 1.08 } } })
hl.curve("bounce", { type = "bezier", points = { { 0.05, 0.5 }, { 0.1, 1.1 } } })

-- Animations
hl.animation({ leaf = "global", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.35, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.8, bezier = "easeOutQuint", style = "popin 85%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.5, bezier = "bounce", style = "popin 70%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.2, bezier = "bounce", style = "popin 60%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.70, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.60, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.45, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.75, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.35, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "overshot" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2.8, bezier = "overshot", style = "slidefade 10%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2.8, bezier = "overshot", style = "slidefade 10%" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 6, bezier = "quick" })
