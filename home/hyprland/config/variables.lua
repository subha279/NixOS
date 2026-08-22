--------------------------------------------------
-- Variables
-- Shared variables used throughout the config.
--------------------------------------------------

local M = {}

--------------------------------------------------
-- Modifier Key
--------------------------------------------------

M.mainMod = "SUPER"
M.altMod = "ALT"

--------------------------------------------------
-- Applications
--------------------------------------------------

M.terminal = "kitty"

M.browser = "firefox"

M.fileManager = "thunar"

M.editor = "nvim"

M.guieditor = "zeditor"

M.note = "obsidian"

-- Quickshell owns the launcher, the wallpaper picker and the
-- colorscheme picker. These are IPC calls into the already-running
-- shell rather than new processes, so there is no spawn cost and no
-- second theming path to keep in sync.
M.menu = "qs ipc call launcher toggle"

M.colorscheme = "qs ipc call theme toggle"

--------------------------------------------------
-- Screenshot
--------------------------------------------------

M.screenshot = [[grim -g "$(slurp)" - | swappy -f -]]

--------------------------------------------------
-- Scripts Directory
--------------------------------------------------

M.scriptDir = os.getenv("HOME") .. "/.config/hypr/scripts"

--------------------------------------------------
-- Wallpapers
--------------------------------------------------

M.wallpaperDir = os.getenv("HOME") .. "/Wallpapers"

--------------------------------------------------
-- Scripts
--------------------------------------------------

M.wallpaperScript = "qs ipc call wallpaper toggle"

--------------------------------------------------
-- Audio
--------------------------------------------------

M.volumeUp = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"

M.volumeDown = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

M.volumeMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

M.micMute = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

--------------------------------------------------
-- Brightness
--------------------------------------------------

M.brightnessUp = "brightnessctl -e4 -n2 set 5%+"

M.brightnessDown = "brightnessctl -e4 -n2 set 5%-"

--------------------------------------------------
-- Media
--------------------------------------------------

M.mediaPlay = "playerctl play-pause"

M.mediaNext = "playerctl next"

M.mediaPrev = "playerctl previous"

--------------------------------------------------
-- Return Module
--------------------------------------------------

return M
