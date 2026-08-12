local M = {}

local api = vim.api

-- ============================================================================
-- Configuration
-- ============================================================================

local width = 70

local function center(text)
	local padding = math.max(0, math.floor((vim.o.columns - vim.fn.strdisplaywidth(text)) / 2))

	return string.rep(" ", padding) .. text
end

local function dashboard_lines()
	local lines = {}

	local logo = {
		"╭────────────────────────────────────────────────────────────╮",
		"│                                                            │",
		"│                         N E O V I M                        │",
		"│                                                            │",
		"│                    Native • Minimal • Fast                 │",
		"│                                                            │",
		"╰────────────────────────────────────────────────────────────╯",
	}

	for _, line in ipairs(logo) do
		table.insert(lines, center(line))
	end

	table.insert(lines, "")
	table.insert(lines, "")
	table.insert(lines, center("───  Quick Actions  ───"))
	table.insert(lines, "")

	local actions = {
		{ key = "f", text = "Find File" },
		{ key = "r", text = "Recent Files" },
		{ key = "g", text = "Live Grep" },
		{ key = "n", text = "New File" },
		{ key = "c", text = "Neovim Config" },
		{ key = "q", text = "Quit" },
	}

	for _, item in ipairs(actions) do
		local text = string.format("  [%s]  %s", item.key, item.text)

		table.insert(lines, center(text))
	end

	table.insert(lines, "")
	table.insert(lines, "")
	table.insert(lines, center("󰒲  Ready"))

	return lines
end

-- ============================================================================
-- Dashboard buffer
-- ============================================================================

local function create_buffer()
	local buf = api.nvim_create_buf(false, true)

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = true

	return buf
end

-- ============================================================================
-- Render
-- ============================================================================

local function render(buf)
	local lines = dashboard_lines()

	vim.bo[buf].modifiable = true

	api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	vim.bo[buf].modifiable = false

	vim.bo[buf].filetype = "dashboard"
end

-- ============================================================================
-- Keybinds
-- ============================================================================

local function setup_keymaps(buf)
	local opts = {
		buffer = buf,
		silent = true,
		noremap = true,
	}

	vim.keymap.set("n", "f", function()
		vim.cmd("Explore")
	end, opts)

	vim.keymap.set("n", "r", function()
		vim.cmd("browse oldfiles")
	end, opts)

	vim.keymap.set("n", "g", function()
		vim.cmd("vimgrep /")
	end, opts)

	vim.keymap.set("n", "n", function()
		vim.cmd("enew")
	end, opts)

	vim.keymap.set("n", "c", function()
		vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
	end, opts)

	vim.keymap.set("n", "q", function()
		vim.cmd("quit")
	end, opts)

	vim.keymap.set("n", "<Esc>", function()
		vim.cmd("quit")
	end, opts)
end

-- ============================================================================
-- Highlighting
-- ============================================================================

local function setup_highlights()
	vim.api.nvim_set_hl(0, "DashboardLogo", {
		fg = "#CBA6F7",
		bg = "NONE",
		bold = true,
	})

	vim.api.nvim_set_hl(0, "DashboardTitle", {
		fg = "#89B4FA",
		bg = "NONE",
		bold = true,
	})

	vim.api.nvim_set_hl(0, "DashboardKey", {
		fg = "#CBA6F7",
		bg = "NONE",
		bold = true,
	})

	vim.api.nvim_set_hl(0, "DashboardText", {
		fg = "#7F8FA6",
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "DashboardStatus", {
		fg = "#A6E3A1",
		bg = "NONE",
	})
end

-- ============================================================================
-- Apply highlights to dashboard
-- ============================================================================

local function apply_highlights(buf)
	local lines = api.nvim_buf_get_lines(buf, 0, -1, false)

	for i, line in ipairs(lines) do
		local line_number = i - 1

		if line:match("N E O V I M") then
			api.nvim_buf_add_highlight(buf, -1, "DashboardLogo", line_number, 0, -1)
		elseif line:match("Quick Actions") then
			api.nvim_buf_add_highlight(buf, -1, "DashboardTitle", line_number, 0, -1)
		elseif line:match("%[.%]") then
			local start = line:find("%[")

			if start then
				api.nvim_buf_add_highlight(buf, -1, "DashboardKey", line_number, start - 1, start + 2)

				api.nvim_buf_add_highlight(buf, -1, "DashboardText", line_number, start + 2, -1)
			end
		elseif line:match("Ready") then
			api.nvim_buf_add_highlight(buf, -1, "DashboardStatus", line_number, 0, -1)
		end
	end
end

-- ============================================================================
-- Detect empty startup
-- ============================================================================

local function should_open()
	if vim.fn.argc() ~= 0 then
		return false
	end

	if vim.fn.line2byte("$") ~= -1 then
		return false
	end

	return true
end

-- ============================================================================
-- Setup
-- ============================================================================

function M.setup()
	setup_highlights()

	if not should_open() then
		return
	end

	vim.schedule(function()
		local buf = create_buffer()

		render(buf)
		apply_highlights(buf)
		setup_keymaps(buf)

		api.nvim_set_current_buf(buf)

		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.wo.cursorline = false
		vim.wo.signcolumn = "no"
		vim.wo.statusline = ""
		vim.wo.winbar = ""
		vim.wo.list = false

		vim.bo[buf].modifiable = false

		vim.cmd("redraw")
	end)
end

return M
