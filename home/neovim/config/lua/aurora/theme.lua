-- Aurora theme access
--
-- One loader, one watcher, one fan-out point.
--
-- Nine files used to carry their own copy of
--
--   local path = vim.fn.expand("~/.config/aurora/active-theme.lua")
--   local ok, theme = pcall(dofile, path)
--   if not ok then return nil end
--   if type(theme) ~= "table" then return nil end
--   if type(theme.colors) ~= "table" then return nil end
--
-- which meant the same generated file was read and executed nine times on every
-- theme switch, and adding a guard meant editing nine call sites. This module
-- owns that read, caches it, and invalidates the cache when the theme changes.

local M = {}

-- Paths

local AURORA_DIR = vim.fn.expand("~/.config/aurora")

-- Plain-text pointer holding the active theme id. aurora-theme writes this
-- LAST, after relinking active-theme.lua, so observing a new value here means
-- the generated Lua is already in place.
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

-- The whole theme table, or nil when Aurora has not generated one yet (a fresh
-- machine, or a Neovim started before the first home-manager activation).
function M.get()
	if not cache_valid then
		cached = load()
		cache_valid = true
	end

	return cached
end

-- Always a table, so callers can index it without guarding first. Absent keys
-- come back nil, which nvim_set_hl treats as "no colour" -- matching how the
-- per-file copies behaved.
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

-- Active theme id, read from the pointer file. Deliberately not from the
-- generated Lua: the watcher polls this every 500ms and should not execute a
-- file to do it.
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

-- Register a function to re-apply highlights after a theme switch.
--
-- Subscribers run in registration order, which follows init.lua's require
-- order, so a refresh reproduces exactly the same sequence of nvim_set_hl calls
-- as startup does. That equivalence is the point: refresh_plugins() previously
-- re-applied only a subset, so groups owned by an unrefreshed module kept the
-- old theme's colours until the next restart.
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

	-- One redraw for the whole pass. Several modules used to each schedule their
	-- own redraw!/redrawstatus! from a refresh_theme() that did nothing else.
	vim.cmd("redraw!")
	vim.cmd("redrawstatus!")
end

-- Watcher

local watching = false

-- Poll the pointer file for a change of id.
--
-- Only ever started once. ui/theme.lua and plugins/alpha.lua each used to run
-- their own 500ms uv timer against this same file, so a theme switch woke two
-- independent pollers that refreshed overlapping sets of highlights.
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

			-- First observation on a machine where the pointer appeared after
			-- startup: adopt it without refreshing, since nothing was applied
			-- from an older theme.
			if last_id == nil then
				last_id = current
				return
			end

			if current == last_id then
				return
			end

			-- Recorded before refreshing so a slow refresh cannot re-trigger.
			last_id = current

			M.refresh()
		end)
	)
end

return M
