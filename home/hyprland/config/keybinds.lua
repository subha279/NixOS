local vars = require("config.variables")
local mainMod = vars.mainMod
local altMod = vars.altMod


hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(vars.terminal))
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(vars.fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(vars.browser))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(vars.menu))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(vars.guieditor))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(vars.note))

hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(vars.colorscheme))


hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))


hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(vars.screenshot))


hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(vars.wallpaper))


hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(vars.clipboard))

hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(vars.emoji))

hl.bind(altMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(altMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(altMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(altMod .. " + L", hl.dsp.focus({ direction = "right" }))


for i = 1, 10 do
	local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end


hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(vars.volumeUp), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(vars.volumeDown), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(vars.volumeMute), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(vars.micMute), { locked = true, repeating = true })


hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(vars.brightnessUp), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(vars.brightnessDown), { locked = true, repeating = true })


hl.bind("XF86AudioNext", hl.dsp.exec_cmd(vars.mediaNext), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(vars.mediaPrev), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(vars.mediaPlay), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(vars.mediaPlay), { locked = true })
