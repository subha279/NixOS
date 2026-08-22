--------------------------------------------------
-- Window Rules
-- Aurora Hyprland Desktop
--------------------------------------------------
--
-- Hyprland applies rules in file order and, for any
-- given property, the last matching rule wins. So
-- this file is ordered from general to specific:
--
--   1. global behaviour
--   2. generic dialogs      matched on title
--   3. system and shell UI  matched on class
--   4. applications         matched on class
--   5. media, creation, GPU
--   6. gaming
--   7. compositor helpers
--
-- Every class here corresponds to something actually
-- installed by modules/desktop, modules/creator,
-- modules/gaming, modules/development or
-- modules/virtualisation.
--------------------------------------------------


--------------------------------------------------
-- 1. Global
--------------------------------------------------

--------------------------------------------------
-- Suppress Maximize Requests
--------------------------------------------------
--
-- Declared first so a later, more specific rule can
-- still override anything else it sets.
--------------------------------------------------

hl.window_rule({
	name = "suppress-maximize-events",

	match = {
		class = ".*",
	},

	suppress_event = "maximize",
})

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
-- 2. Generic Dialogs
--------------------------------------------------
--
-- This section used to be nine rules that differed
-- only in the title they matched. Three sizes were
-- repeated verbatim:
--
--   900 600   open-file / save-as / file-upload
--   500 300   replace-files / file-operation-progress
--   450 200   rename-dialog / create-folder-dialog
--
-- Collapsed into one rule per size using alternation.
-- Same behaviour, and adding a new dialog is now a
-- word rather than a block.
--------------------------------------------------

--------------------------------------------------
-- File Choosers
--------------------------------------------------

hl.window_rule({
	name = "file-chooser-dialogs",

	match = {
		title = "^(Open File|Open Files|Open Folder|Open Document|Open Image|Save|Save As|Save File|Save Image|Save Video|Save Document|Save Project|Select File|Select Files|Select Folder|Select Directory|Select a File|Choose File|Choose Files|Choose a file|File Upload|Add Files|Add Folder|Import File|Export Image|Export As)( .*)?$",
	},

	float = true,
	center = true,

	size = "900 600",

	rounding = 10,

	dim_around = true,
})

--------------------------------------------------
-- File Operations
--------------------------------------------------

--------------------------------------------------
-- File Conflicts
--------------------------------------------------
--
-- Deliberately NO size. These dialogs grow with
-- the filename and the number of buttons, so a
-- forced 500x300 clipped Replace / Rename / Skip
-- straight off the bottom edge.
--------------------------------------------------

hl.window_rule({
	name = "file-conflict-dialogs",

	match = {
		title = "^(Confirm to replace files|Confirm to replace|Replace file|Replace files|File Exists|Merge Folders?)( .*)?$",
	},

	float = true,
	center = true,

	rounding = 10,

	dim_around = true,
})

--------------------------------------------------
-- File Operation Progress
--------------------------------------------------
--
-- A progress window is not modal. Centring it put
-- it directly on top of the conflict dialog that
-- the same operation had just raised, which made
-- the buttons unreachable.
--
-- Parked bottom-right, never focused, never dims.
--------------------------------------------------

hl.window_rule({
	name = "file-progress-dialogs",

	match = {
		title = "^(File Operation Progress|Copying files|Moving files|Deleting files|Transferring files|Extracting files|Compressing files|Emptying Trash)( .*)?$",
	},

	float = true,

	move = "monitor_w-520 80",

	rounding = 10,

	no_focus = true,
})

--------------------------------------------------
-- Short Confirmations
--------------------------------------------------

hl.window_rule({
	name = "confirmation-dialogs",

	match = {
		title = "^(Rename|Rename File|Rename Folder|Create New Folder|Create Folder|New Folder|Confirm|Confirmation|Question|Warning|Error|Delete|Permanently Delete)( .*)?$",
	},

	float = true,
	center = true,

	rounding = 10,

	dim_around = true,
})

--------------------------------------------------
-- Properties
--------------------------------------------------

hl.window_rule({
	name = "properties-dialog",

	match = {
		title = "^(Properties|.* Properties)$",
	},

	float = true,
	center = true,

	size = "500 600",

	rounding = 10,

	dim_around = true,
})

--------------------------------------------------
-- Preferences and About
--------------------------------------------------

hl.window_rule({
	name = "preferences-dialogs",

	match = {
		title = "^(Preferences|Settings|Options|Configuration|Keyboard Shortcuts|About)( .*)?$",
	},

	float = true,
	center = true,

	size = "800 600",

	rounding = 10,

	dim_around = true,

	animation = "popin",
})


--------------------------------------------------
-- 3. System and Shell UI
--------------------------------------------------

--------------------------------------------------
-- Polkit Authentication Agent
--------------------------------------------------
--
-- plasma-polkit-agent is started by
-- desktop-services.target. Its prompt appears for
-- every privileged action, so it should be centred,
-- dimmed and unmissable.
--------------------------------------------------

hl.window_rule({
	name = "polkit-agent",

	match = {
		class = "^(polkit-kde-authentication-agent-1|org\\.kde\\.polkit-kde-authentication-agent-1|polkit-gnome-authentication-agent-1)$",
	},

	float = true,
	center = true,

	size = "480 260",

	rounding = 10,

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
-- Bluetooth Manager
--------------------------------------------------
--
-- Was 500x300, which is too small for the device
-- list; the pairing UI needed scrolling to use.
--------------------------------------------------

hl.window_rule({
	name = "blueman-manager",

	match = {
		class = "^\\.blueman-manager-wrapped$",
	},

	float = true,
	center = true,

	size = "760 560",

	rounding = 10,

	opacity = "0.90 0.90",

	dim_around = true,

	animation = "popin",
})

hl.window_rule({
	name = "blueman-dialogs",

	match = {
		class = "^(blueman-adapters|blueman-services|blueman-sendto|\\.blueman-adapters-wrapped|\\.blueman-services-wrapped)$",
	},

	float = true,
	center = true,

	size = "600 460",

	rounding = 10,

	opacity = "0.95 0.95",

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
-- Appearance Tools
--------------------------------------------------
--
-- nwg-look, qt6ct and Kvantum are all installed by
-- modules/desktop/applications.nix and had no rules,
-- so they opened tiled into the middle of a workspace.
--------------------------------------------------

hl.window_rule({
	name = "appearance-tools",

	match = {
		class = "^(nwg-look|qt6ct|kvantummanager|org\\.kde\\.kvantummanager)$",
	},

	float = true,
	center = true,

	size = "900 650",

	rounding = 10,

	dim_around = true,

	animation = "popin",
})


--------------------------------------------------
-- 4. Applications
--------------------------------------------------

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
		class = "^(firefox|firefox-esr|Navigator)$",
	},

	opacity = "1.0 override 1.0 override 1.0 override",

	xray = true,
})

--------------------------------------------------
-- Firefox Picture-in-Picture
--------------------------------------------------

hl.window_rule({
	name = "firefox-picture-in-picture",

	match = {
		title = "^Picture-in-Picture$",
	},

	float = true,

	size = "640 360",

	move = "monitor_w-664 monitor_h-408",

	rounding = 10,

	opacity = "1.0 override 1.0 override",
})

--------------------------------------------------
-- Firefox Screen Sharing Indicator
--------------------------------------------------
--
-- Small always-present strip. It must never take
-- focus away from the window being shared.
--------------------------------------------------

hl.window_rule({
	name = "firefox-sharing-indicator",

	match = {
		title = "(Firefox|Nightly) . Sharing Indicator$",
	},

	float = true,

	move = "50% 0",

	no_focus = true,
})

--------------------------------------------------
-- Thunar
--------------------------------------------------

hl.window_rule({
	name = "thunar-bulk-rename",

	match = {
		class = "^(thunar|Thunar)$",
		title = "^Bulk Rename( .*)?$",
	},

	float = true,
	center = true,

	size = "800 500",

	rounding = 10,

	dim_around = true,
})

--------------------------------------------------
-- Archive Manager
--------------------------------------------------

hl.window_rule({
	name = "file-roller",

	match = {
		class = "^(file-roller|org\\.gnome\\.FileRoller)$",
	},

	float = true,
	center = true,

	size = "800 550",

	rounding = 10,

	dim_around = true,

	animation = "popin",
})

--------------------------------------------------
-- Image Viewer
--------------------------------------------------
--
-- Gwenview is the default handler for png, jpeg,
-- webp, gif, tiff, bmp and avif in modules/xdg, so
-- it opens constantly. Forced opaque for the same
-- reason as Firefox: it renders other people's
-- images and transparency corrupts them.
--------------------------------------------------

hl.window_rule({
	name = "gwenview",

	match = {
		class = "^org\\.kde\\.gwenview$",
	},

	float = true,
	center = true,

	size = "1280 800",

	rounding = 10,

	opacity = "1.0 override 1.0 override",
})

hl.window_rule({
	name = "imagemagick-display",

	match = {
		class = "^display-im6\\.q16$",
	},

	float = true,
	center = true,

	opacity = "1.0 override 1.0 override",
})

--------------------------------------------------
-- Screenshot Annotation
--------------------------------------------------

hl.window_rule({
	name = "swappy",

	match = {
		class = "^swappy$",
	},

	float = true,
	center = true,

	size = "1200 800",

	rounding = 10,

	opacity = "1.0 override 1.0 override",

	animation = "popin",
})

--------------------------------------------------
-- Editors and Notes
--------------------------------------------------
--
-- Electron and GPU-composited editors blend badly
-- with compositor transparency, so both are pinned
-- fully opaque.
--------------------------------------------------

hl.window_rule({
	name = "code-editors",

	match = {
		class = "^(dev\\.zed\\.Zed|obsidian)$",
	},

	opacity = "1.0 override 1.0 override",
})

--------------------------------------------------
-- Office
--------------------------------------------------

hl.window_rule({
	name = "libreoffice",

	match = {
		class = "^(libreoffice.*|soffice.*)$",
	},

	opacity = "1.0 override 1.0 override",
})

--------------------------------------------------
-- Virtualisation
--------------------------------------------------

hl.window_rule({
	name = "virt-manager",

	match = {
		class = "^(virt-manager|\\.virt-manager-wrapped)$",
	},

	float = true,
	center = true,

	size = "1100 700",

	rounding = 10,
})

hl.window_rule({
	name = "virt-viewer",

	match = {
		class = "^(virt-viewer|\\.virt-viewer-wrapped|\\.remote-viewer-wrapped)$",
	},

	float = true,
	center = true,

	size = "1280 800",

	opacity = "1.0 override 1.0 override",
})


--------------------------------------------------
-- 5. Media and Content Creation
--------------------------------------------------
--
-- Everything in this section renders colour-critical
-- output. Transparency and blur are wrong here, not
-- just distracting, so opacity is forced to 1.0.
--------------------------------------------------

--------------------------------------------------
-- OBS Studio
--------------------------------------------------
--
-- OBS remains tiled.
--
-- The previous rule had an empty body and did
-- nothing at all.
--------------------------------------------------

hl.window_rule({
	name = "obs-studio",

	match = {
		class = "^com\\.obsproject\\.Studio$",
	},

	opacity = "1.0 override 1.0 override",

	xray = true,
})

hl.window_rule({
	name = "obs-studio-dialogs",

	match = {
		class = "^com\\.obsproject\\.Studio$",
		title = "^(Settings|Filters|Properties for .*|Auto-Configuration Wizard|Output Timer|Stats|Docks)( .*)?$",
	},

	float = true,
	center = true,

	size = "960 680",

	rounding = 10,

	dim_around = true,
})

--------------------------------------------------
-- DaVinci Resolve
--------------------------------------------------
--
-- Resolve remains tiled.
--
-- The previous rule had an empty body. Resolve is
-- also an Xwayland client that draws its own splash
-- and tool windows with no class, so it needs the
-- opacity override to stay colour accurate.
--------------------------------------------------

hl.window_rule({
	name = "davinci-resolve",

	match = {
		class = "^resolve$",
	},

	opacity = "1.0 override 1.0 override",

	xray = true,
})

--------------------------------------------------
-- VLC
--------------------------------------------------

hl.window_rule({
	name = "vlc",

	match = {
		class = "^vlc$",
	},

	opacity = "1.0 override 1.0 override",
})

--------------------------------------------------
-- GIMP
--------------------------------------------------

hl.window_rule({
	name = "gimp",

	match = {
		class = "^(gimp.*|GNU Image Manipulation Program)$",
	},

	opacity = "1.0 override 1.0 override",
})

--------------------------------------------------
-- Blender
--------------------------------------------------

hl.window_rule({
	name = "blender",

	match = {
		class = "^([Bb]lender)$",
	},

	opacity = "1.0 override 1.0 override",
})


--------------------------------------------------
-- 6. Gaming
--------------------------------------------------

--------------------------------------------------
-- Steam
--------------------------------------------------

hl.window_rule({
	name = "steam",

	match = {
		class = "^steam$",
	},

	opacity = "1.0 override 1.0 override",
})

--------------------------------------------------
-- Steam Secondary Windows
--------------------------------------------------
--
-- Friends list, settings and the news popup all
-- arrive as separate top-level windows and tile
-- themselves into the layout if left alone.
--------------------------------------------------

hl.window_rule({
	name = "steam-dialogs",

	match = {
		class = "^steam$",
		title = "^(Friends List|Steam Settings|Steam - News.*|Screenshot Uploader|Special Offers|Sign in to Steam)( .*)?$",
	},

	float = true,
	center = true,

	size = "700 800",

	rounding = 10,
})

--------------------------------------------------
-- Games
--------------------------------------------------
--
-- Anything launched through Steam or gamescope.
-- No transparency, no dimming from a dialog that
-- happens to open behind them.
--------------------------------------------------

hl.window_rule({
	name = "games",

	match = {
		class = "^(steam_app_\\d+|steam_proton|gamescope|\\.gamescope-wrapped)$",
	},

	opacity = "1.0 override 1.0 override",

	xray = true,
})


--------------------------------------------------
-- 7. Compositor Helpers
--------------------------------------------------

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
