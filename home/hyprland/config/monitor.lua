--------------------------------------------------
-- Monitor Configuration
-- https://wiki.hypr.land/Configuring/Monitors/
--------------------------------------------------

--------------------------------------------------
-- Default Monitor
--------------------------------------------------

--hl.monitor({
--    output = "",
--    mode = "preferred",
--    position = "auto",
--    scale = "1.25",
--})

--------------------------------------------------
-- Example Laptop Display
--------------------------------------------------
-- Uncomment and modify if you want to configure
-- your laptop display manually.

-- hl.monitor({
--     output = "eDP-1",
--     mode = "1920x1080@60",
--     position = "0x0",
--     scale = 1.25,
-- })

--------------------------------------------------
-- Example External Monitor
--------------------------------------------------

hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@180",
	position = "0x0",
	scale = 1,
})

--------------------------------------------------
-- Example DisplayPort Monitor
--------------------------------------------------

-- hl.monitor({
--     output = "DP-1",
--     mode = "2560x1440@180",
--     position = "0x0",
--     scale = 1,
-- })

--------------------------------------------------
-- Example Vertical Monitor
--------------------------------------------------

-- hl.monitor({
--     output = "DP-2",
--     mode = "1080x1920@60",
--     position = "2560x0",
--     scale = 1,
--     transform = 1,
-- })

--------------------------------------------------
-- Example Disable Monitor
--------------------------------------------------

hl.monitor({
	output = "eDP-1",
	disabled = true,
})
