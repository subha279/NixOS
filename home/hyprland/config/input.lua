hl.config({

	input = {


		kb_layout = "us",
        kb_options = "caps:swapescape",


		follow_mouse = 1,

		sensitivity = 0,
		accel_profile = "flat",


		touchpad = {

			natural_scroll = true,
			scroll_factor = 0.80, -- Smooth scrolling speed

			tap_to_click = true,
			tap_and_drag = true,
			drag_lock = false,

			disable_while_typing = true, -- Palm rejection
			clickfinger_behavior = true, -- 2-finger right click
			middle_button_emulation = false,

			tap_button_map = "lrm", -- Left / Right / Middle
		},
	},
})


hl.gesture({

	fingers = 3,

	direction = "horizontal",

	action = "workspace",
})


hl.device({

	name = "epic-mouse-v1",

	sensitivity = -0.5,
})
