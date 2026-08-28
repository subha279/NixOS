-- Aurora theme access

local M = {}

-- Paths

local AURORA_DIR = vim.fn.expand("~/.config/aurora")

M.id_path = AURORA_DIR .. "/active-theme"

-- Symlink to the generated theme for the active id.
M.theme_path = AURORA_DIR .. "/active-theme.lua"

-- Load / cache

local cached = nil
local cache_valid = false

local function load()
	local ok, theme = pcall(dofile, M.theme_path)

	if not ok then
		return nil
	end

	if type(theme) ~= "table" then
		return nil
	end

	if type(theme.colors) ~= "table" then
		return nil
	end

	return theme
end

function M.get()
	if not cache_valid then
		cached = load()
		cache_valid = true
	end

	return cached
end

function M.colors()
	local theme = M.get()

	return theme and theme.colors or {}
end

function M.ui()
	local theme = M.get()

	return theme and theme.ui or {}
end

function M.invalidate()
	cache_valid = false
	cached = nil
end

function M.id()
	local file = io.open(M.id_path, "r")

	if not file then
		return nil
	end

	local value = file:read("*l")

	file:close()

	if value == nil or value == "" then
		return nil
	end

	return value
end

-- Subscribers

local subscribers = {}

function M.on_change(fn)
	if type(fn) ~= "function" then
		return
	end

	subscribers[#subscribers + 1] = fn
end

-- Drop the cache, then let every subscriber recolour against the new palette.
function M.refresh()
	M.invalidate()

	for _, fn in ipairs(subscribers) do
		-- One broken subscriber must not stop the others recolouring.
		local ok, err = pcall(fn)

		if not ok then
			vim.schedule(function()
				vim.notify("Aurora: theme refresh failed\n" .. tostring(err), vim.log.levels.WARN)
			end)
		end
	end

	-- A visible NvimTree caches its own rendered highlights.
	pcall(function()
		local api = require("nvim-tree.api")

		if api.tree.is_visible() then
			api.tree.reload()
		end
	end)

	vim.cmd("redraw!")
	vim.cmd("redrawstatus!")
end

-- Watcher

local watching = false

function M.watch()
	if watching then
		return
	end

	watching = true

	local last_id = M.id()

	local timer = vim.uv.new_timer()

	if not timer then
		return
	end

	timer:start(
		500,
		500,
		vim.schedule_wrap(function()
			local current = M.id()

			if current == nil then
				return
			end

			if last_id == nil then
				last_id = current
				return
			end

			if current == last_id then
				return
			end

			last_id = current

			M.refresh()
		end)
	)
end

return M
