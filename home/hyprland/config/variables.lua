local M = {}


M.mainMod = "SUPER"
M.altMod = "ALT"


M.terminal = "kitty"

M.browser = "zen"

M.fileManager = "thunar"

M.editor = "nvim"

M.guieditor = "zeditor"

M.note = "obsidian"

M.menu = "qs ipc call launcher toggle"

M.colorscheme = "qs ipc call theme toggle"

M.wallpaper = "qs ipc call wallpaper toggle"

M.clipboard = "qs ipc call clipboard toggle"

M.emoji = "qs ipc call emoji toggle"


M.screenshot = [[grim -g "$(slurp)" - | swappy -f -]]


M.scriptDir = os.getenv("HOME") .. "/.config/hypr/scripts"


M.wallpaperDir = os.getenv("HOME") .. "/Wallpapers"


M.volumeUp = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"

M.volumeDown = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

M.volumeMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

M.micMute = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"


M.brightnessUp = "brightnessctl -e4 -n2 set 5%+"

M.brightnessDown = "brightnessctl -e4 -n2 set 5%-"


M.mediaPlay = "playerctl play-pause"

M.mediaNext = "playerctl next"

M.mediaPrev = "playerctl previous"


return M
