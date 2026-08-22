--------------------------------------------------
-- Window Rules
-- Aurora Hyprland Desktop
--------------------------------------------------

--------------------------------------------------
-- Global Modal Dialogs
--------------------------------------------------
--
-- Modal dialogs should float above the application
-- that opened them instead of becoming tiled windows.
--------------------------------------------------

hl.window_rule({
	name = "modal-dialogs",

	match = {
		modal = true,
	},

	float = true,
	center = true,

	rounding = 10,

	dim_around = true,

	animation = "popin",
})

--------------------------------------------------
-- File Chooser Dialogs
--------------------------------------------------

hl.window_rule({
	name = "open-file-dialog",

	match = {
		title = "^(Open File)(.*)$",
	},

	float = true,
	center = true,

	size = "900 600",

	rounding = 10,

	dim_around = true,
})

hl.window_rule({
	name = "save-as-dialog",

	match = {
		title = "^(Save As)(.*)$",
	},

	float = true,
	center = true,

	size = "900 600",

	rounding = 10,

	dim_around = true,
})

hl.window_rule({
	name = "file-upload-dialog",

	match = {
		title = "^(File Upload)(.*)$",
	},

	float = true,
	center = true,

	size = "900 600",

	rounding = 10,

	dim_around = true,
})

--------------------------------------------------
-- File Operation Dialogs
--------------------------------------------------

hl.window_rule({
	name = "replace-files",

	match = {
		title = "^Confirm to replace files$",
	},

	float = true,
	center = true,

	size = "500 300",

	rounding = 10,

	dim_around = true,
})

hl.window_rule({
	name = "file-operation-progress",

	match = {
		title = "^(File Operation Progress)(.*)$",
	},

	float = true,
	center = true,

	size = "500 300",

	rounding = 10,

	dim_around = true,
})

hl.window_rule({
	name = "rename-dialog",

	match = {
		title = "^(Rename)(.*)$",
	},

	float = true,
	center = true,

	size = "450 200",

	rounding = 10,

	dim_around = true,
})

hl.window_rule({
	name = "create-folder-dialog",

	match = {
		title = "^Create New Folder$",
	},

	float = true,
	center = true,

	size = "450 200",

	rounding = 10,

	dim_around = true,
})

hl.window_rule({
	name = "properties-dialog",

	match = {
		title = "^Properties$",
	},

	float = true,
	center = true,

	size = "500 600",

	rounding = 10,

	dim_around = true,
})

--------------------------------------------------
-- Bluetooth Manager
--------------------------------------------------

hl.window_rule({
	name = "blueman-manager",

	match = {
		class = ".blueman-manager-wrapped",
	},

	float = true,
	center = true,

	size = "500 300",

	rounding = 10,

	opacity = "0.90 0.90",

	dim_around = true,

	animation = "popin",
})

--------------------------------------------------
-- NetworkManager Connection Editor
--------------------------------------------------

hl.window_rule({
	name = "network-manager",

	match = {
		class = "^nm-connection-editor$",
	},

	float = true,
	center = true,

	size = "500 600",

	rounding = 10,

	opacity = "0.95 0.95",

	dim_around = true,

	animation = "popin",
})

--------------------------------------------------
-- XDG Desktop Portal
--------------------------------------------------

hl.window_rule({
	name = "xdg-desktop-portal",

	match = {
		class = "^xdg-desktop-portal-gtk$",
	},

	float = true,
	center = true,

	size = "700 400",

	rounding = 10,

	dim_around = true,

	animation = "popin",
})

--------------------------------------------------
-- Pavucontrol
--------------------------------------------------

hl.window_rule({
	name = "pavucontrol",

	match = {
		class = "^org\\.pulseaudio\\.pavucontrol$",
	},

	float = true,
	center = true,

	size = "900 650",

	rounding = 10,

	opacity = "0.97 0.97",

	dim_around = true,

	animation = "popin",
})

--------------------------------------------------
-- OBS Studio
--------------------------------------------------
--
-- OBS remains tiled.
--------------------------------------------------

hl.window_rule({
	name = "obs-studio",

	match = {
		class = "^com\\.obsproject\\.Studio$",
	},
})

--------------------------------------------------
-- DaVinci Resolve
--------------------------------------------------
--
-- Resolve remains tiled.
--------------------------------------------------

hl.window_rule({
	name = "davinci-resolve",

	match = {
		class = "^resolve$",
	},
})

--------------------------------------------------
-- Firefox
--------------------------------------------------
--
-- Keep Firefox completely opaque.
--
-- Browser pages contain their own backgrounds,
-- images and colors, so desktop transparency
-- would make web content visually inconsistent.
--------------------------------------------------

hl.window_rule({
	name = "firefox",

	match = {
		class = "^firefox$",
	},

	opacity = "1.0 override 1.0 override 1.0 override",

	xray = true,
})

--------------------------------------------------
-- XWayland Dragging Fix
--------------------------------------------------

hl.window_rule({
	name = "fix-xwayland-drags",

	match = {
		class = "^$",
		title = "^$",

		xwayland = true,

		float = true,

		fullscreen = false,

		pin = false,
	},

	no_focus = true,
})

--------------------------------------------------
-- Hyprland Run Dialog
--------------------------------------------------

hl.window_rule({
	name = "hyprland-run",

	match = {
		class = "^hyprland-run$",
	},

	float = true,

	move = "20 monitor_h-120",

	rounding = 10,
})

--------------------------------------------------
-- Suppress Maximize Requests
--------------------------------------------------

hl.window_rule({
	name = "suppress-maximize-events",

	match = {
		class = ".*",
	},

	suppress_event = "maximize",
})
