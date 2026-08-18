-- ============================================================================
-- Aurora Color Preview
-- ============================================================================
--
-- Highlights color literals with their actual color without changing Aurora's
-- theme. Hex values work in every normal file; CSS functions and named colors
-- are enabled where they are useful. QML receives its alpha-first hex format.
--
-- Examples:
--
--   #7aa2f7  #0f8  #112233aa  rgb(122 162 247)  hsl(220 86% 72%)
--   QML: #aa7aa2f7  0xaa7aa2f7
--
-- ============================================================================

local M = {}

function M.setup()
	local ok, colorizer = pcall(require, "colorizer")

	if not ok then
		vim.notify("Aurora: Colorizer could not be loaded\n" .. tostring(colorizer), vim.log.levels.WARN)
		return false
	end

	colorizer.setup({
		filetypes = {
			"*",

			-- Named colors are useful in web styles, but keeping them disabled for
			-- unrelated filetypes avoids highlighting ordinary words like "red".
			css = {
				parsers = { names = { enable = true } },
			},
			scss = {
				parsers = { names = { enable = true } },
			},
			sass = {
				parsers = { names = { enable = true } },
			},
			less = {
				parsers = { names = { enable = true } },
			},
			html = {
				parsers = { names = { enable = true } },
			},

			-- QML's eight-digit #AARRGGBB form puts alpha first, unlike CSS.
			qml = {
				parsers = {
					names = { enable = true },
					hex = {
						default = true,
						rrggbbaa = false,
						hash_aarrggbb = true,
						aarrggbb = true,
					},
				},
			},
		},

		buftypes = {},
		user_commands = true,
		lazy_load = true,

		options = {
			parsers = {
				names = {
					enable = false,
				},

				hex = {
					default = true,
					rrggbbaa = true,
					hash_aarrggbb = false,
					aarrggbb = false,
					no_hash = false,
				},

				rgb = { enable = true },
				hsl = { enable = true },
				hwb = { enable = true },
				lab = { enable = true },
				lch = { enable = true },
				oklch = { enable = true },
				css_color = { enable = true },
			},

			display = {
				mode = "background",
				disable_document_color = true,
			},
		},
	})

	return true
end

M.setup()

return M
