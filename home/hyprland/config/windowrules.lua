-- ==========================================
-- Window Rules
-- ==========================================

hl.window_rule({ match = { title = "^(Open File)(.*)$" }, size = "900 600" })
hl.window_rule({ match = { title = "^(Save As)(.*)$" }, size = "900 600" })
hl.window_rule({ match = { title = "^(File Upload)(.*)$" }, size = "900 600" })
hl.window_rule({ match = { title = "^(Confirm to replace files)$" }, size = "500 300" })
hl.window_rule({ match = { title = "^(File Operation Progress)(.*)$" }, size = "500 300" })
hl.window_rule({ match = { title = "^(Rename)(.*)$" }, size = "450 200" })
hl.window_rule({ match = { title = "^(Create New Folder)$" }, size = "450 200" })
hl.window_rule({ match = { title = "^(Properties)$" }, size = "500 600" })
hl.window_rule({ match = { modal = true }, float = true, center = true, rounding = 10 })

-- =========================================================================
-- Window Rules
-- =========================================================================
--hl.window_rule({ match = { class = "^kitty$" }, float = true, size = "950 550", center = true, rounding = 8, opacity = "0.9 0.9" })
hl.window_rule({
	match = {
		initial_class = "^%.blueman%-manager%-wrapped$",
	},
	float = true,
	size = "500 300",
	rounding = 10,
	opacity = "0.90 0.90",
	border_size = 1,
	border_color = "rgb(87b158) rgb(2D353B)",
	animation = "popin",
	dim_around = true,
})

hl.window_rule({
	match = { class = "^nm-connection-editor$" },
	float = true,
	size = "500 600",
	center = true,
	rounding = 10,
	opacity = "0.95 0.95",
	border_color = "rgb(87b158)",
})
hl.window_rule({ match = { class = "^xdg-desktop-portal-gtk$" }, float = true, center = true, size = "700 400" })

-- ==========================================
-- Creator Applications
-- ==========================================

-- OBS Studio
hl.window_rule({
	match = { class = "^com\\.obsproject\\.Studio$" },
})

-- DaVinci Resolve
hl.window_rule({
	match = { class = "^resolve$" },
})

-- Pavucontrol
hl.window_rule({
	match = { class = "^org\\.pulseaudio\\.pavucontrol$" },
	float = true,
	center = true,
	size = "900 650",
	rounding = 10,
	opacity = "0.97 0.97",
	dim_around = true,
})

--------------------------------------------------
-- Firefox Glass
--------------------------------------------------

hl.window_rule({
	name = "firefox-glass",

	match = {
		class = "^firefox$",
	},

	opacity = "0.90 override 0.90 override 1.0 override",

	xray = true,
})
