-- ============================================================================
-- Aurora Native LSP
-- ============================================================================

local M = {}

-- ============================================================================
-- Aurora Theme
-- ============================================================================

local function get_theme()
	local path = vim.fn.expand("~/.config/aurora/active-theme.lua")

	local ok, theme = pcall(dofile, path)

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

local function colors()
	local theme = get_theme()

	if theme and theme.colors then
		return theme.colors
	end

	return {}
end

local function set_hl(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

-- ============================================================================
-- LSP Highlights
-- ============================================================================

local function apply_highlights()
	local c = colors()

	-- ========================================================================
	-- Floating UI
	-- ========================================================================

	set_hl("LspFloatNormal", {
		fg = c.text,
		bg = "NONE",
	})

	set_hl("LspFloatBorder", {
		fg = c.borderFocus or c.border,
		bg = "NONE",
	})

	set_hl("LspFloatTitle", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	-- ========================================================================
	-- Signature Help
	-- ========================================================================

	set_hl("LspSignatureActiveParameter", {
		fg = c.accent,
		bg = c.surfaceHover,
		bold = true,
	})

	-- ========================================================================
	-- Inlay Hints
	-- ========================================================================

	set_hl("LspInlayHint", {
		fg = c.textMuted,
		bg = "NONE",
		italic = true,
	})

	-- ========================================================================
	-- Code Lens
	-- ========================================================================

	set_hl("LspCodeLens", {
		fg = c.textMuted,
		bg = "NONE",
		italic = true,
	})

	set_hl("LspCodeLensSeparator", {
		fg = c.border,
		bg = "NONE",
	})

	-- ========================================================================
	-- References
	-- ========================================================================

	set_hl("LspReferenceText", {
		bg = c.surfaceHover,
	})

	set_hl("LspReferenceRead", {
		bg = c.surfaceHover,
	})

	set_hl("LspReferenceWrite", {
		bg = c.surfaceHover,
		bold = true,
	})

	set_hl("LspReferenceTarget", {
		bg = c.surfaceHover,
		underline = true,
	})

	-- ========================================================================
	-- Semantic Tokens
	-- ========================================================================

	set_hl("@lsp.type.namespace", {
		fg = c.info,
	})

	set_hl("@lsp.type.type", {
		fg = c.accent,
	})

	set_hl("@lsp.type.class", {
		fg = c.accent,
		bold = true,
	})

	set_hl("@lsp.type.interface", {
		fg = c.accent,
	})

	set_hl("@lsp.type.enum", {
		fg = c.accent,
	})

	set_hl("@lsp.type.enumMember", {
		fg = c.warning,
	})

	set_hl("@lsp.type.function", {
		fg = c.info,
		bold = true,
	})

	set_hl("@lsp.type.method", {
		fg = c.info,
	})

	set_hl("@lsp.type.variable", {
		fg = c.text,
	})

	set_hl("@lsp.type.parameter", {
		fg = c.textSecondary,
	})

	set_hl("@lsp.type.property", {
		fg = c.info,
	})

	set_hl("@lsp.type.keyword", {
		fg = c.accent,
		bold = true,
	})

	set_hl("@lsp.type.string", {
		fg = c.success,
	})

	set_hl("@lsp.type.number", {
		fg = c.warning,
	})

	set_hl("@lsp.type.comment", {
		fg = c.textMuted,
		italic = true,
	})
end

-- ============================================================================
-- LSP Hover
-- ============================================================================

local function hover()
	vim.lsp.buf.hover({
		border = "rounded",
		max_width = 90,
		max_height = 30,
		focusable = true,
		close_events = {
			"CursorMoved",
			"BufHidden",
			"InsertCharPre",
		},
	})
end

-- ============================================================================
-- LSP Signature Help
-- ============================================================================

local function signature_help()
	vim.lsp.buf.signature_help({
		border = "rounded",
		max_width = 90,
		max_height = 15,
		focusable = true,
		close_events = {
			"CursorMoved",
			"BufHidden",
			"InsertCharPre",
		},
	})
end

-- ============================================================================
-- Diagnostics
-- ============================================================================

local function configure_diagnostics()
	vim.diagnostic.config({
		virtual_text = {
			spacing = 2,
			source = "if_many",
			prefix = "●",

			format = function(diagnostic)
				return diagnostic.message
			end,
		},

		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚",
				[vim.diagnostic.severity.WARN] = "󰀪",
				[vim.diagnostic.severity.INFO] = "󰋼",
				[vim.diagnostic.severity.HINT] = "󰌵",
			},
		},

		underline = true,

		update_in_insert = false,

		severity_sort = true,

		float = {
			border = "rounded",

			source = true,

			header = {
				" Diagnostics ",
				"DiagnosticFloatTitle",
			},

			prefix = function(diagnostic)
				if diagnostic.severity == vim.diagnostic.severity.ERROR then
					return "󰅚 ", "DiagnosticError"
				end

				if diagnostic.severity == vim.diagnostic.severity.WARN then
					return "󰀪 ", "DiagnosticWarn"
				end

				if diagnostic.severity == vim.diagnostic.severity.INFO then
					return "󰋼 ", "DiagnosticInfo"
				end

				return "󰌵 ", "DiagnosticHint"
			end,

			format = function(diagnostic)
				return diagnostic.message
			end,
		},
	})
end

-- ============================================================================
-- Server Configuration
-- ============================================================================

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = {
					"vim",
				},
			},

			workspace = {
				checkThirdParty = false,
			},

			telemetry = {
				enable = false,
			},
		},
	},
})

-- ============================================================================

vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},

			cargo = {
				allFeatures = true,
			},

			procMacro = {
				enable = true,
			},

			inlayHints = {
				bindingModeHints = {
					enable = true,
				},

				chainingHints = {
					enable = true,
				},

				closingBraceHints = {
					enable = true,
				},

				closureCaptureHints = {
					enable = true,
				},

				closureReturnTypeHints = {
					enable = "always",
				},

				discriminantHints = {
					enable = "always",
				},

				expressionAdjustmentHints = {
					enable = "always",
				},

				lifetimeElisionHints = {
					enable = "skip_trivial",
				},

				parameterHints = {
					enable = true,
				},

				reborrowHints = {
					enable = "always",
				},

				renderColons = true,

				typeHints = {
					enable = true,
				},
			},
		},
	},
})

-- ============================================================================
-- Enable Servers
-- ============================================================================

vim.lsp.enable({
	"lua_ls",
	"rust_analyzer",
	"ts_ls",
	"pyright",
	"clangd",
	"nixd",
	"bashls",
	"jsonls",
	"html",
	"cssls",
	"eslint",
	"yamlls",
	"marksman",
	"tailwindcss",
	"dockerls",
	"taplo",
})

-- ============================================================================
-- LSP Attach
-- ============================================================================

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)

		if not client then
			return
		end

		local buf = event.buf

		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, {
				buffer = buf,
				silent = true,
				noremap = true,
				nowait = true,
				desc = desc,
			})
		end

		-- ======================================================================
		-- Navigation
		-- ======================================================================

		map("n", "gd", vim.lsp.buf.definition, "LSP: Definition")

		map("n", "gD", vim.lsp.buf.declaration, "LSP: Declaration")

		map("n", "gi", vim.lsp.buf.implementation, "LSP: Implementation")

		map("n", "gr", vim.lsp.buf.references, "LSP: References")

		map("n", "gt", vim.lsp.buf.type_definition, "LSP: Type definition")

		-- ======================================================================
		-- Documentation
		-- ======================================================================

		map("n", "K", hover, "LSP: Hover")

		map("n", "<C-k>", signature_help, "LSP: Signature help")

		-- ======================================================================
		-- Refactoring
		-- ======================================================================

		map("n", "<leader>lr", vim.lsp.buf.rename, "LSP: Rename")

		map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "LSP: Code action")

		-- ======================================================================
		-- Diagnostics
		-- ======================================================================

		map("n", "<leader>ld", vim.diagnostic.open_float, "LSP: Line diagnostics")

		map("n", "[d", function()
			vim.diagnostic.jump({
				count = -1,
				float = true,
			})
		end, "Diagnostics: Previous")

		map("n", "]d", function()
			vim.diagnostic.jump({
				count = 1,
				float = true,
			})
		end, "Diagnostics: Next")

		-- ======================================================================
		-- Inlay Hints
		-- ======================================================================

		if vim.lsp.inlay_hint and client:supports_method("textDocument/inlayHint") then
			map("n", "<leader>lh", function()
				local enabled = vim.lsp.inlay_hint.is_enabled({
					bufnr = buf,
				})

				vim.lsp.inlay_hint.enable(not enabled, {
					bufnr = buf,
				})
			end, "LSP: Toggle inlay hints")
		end
	end,
})

-- ============================================================================
-- Initialize
-- ============================================================================

configure_diagnostics()

apply_highlights()

-- ============================================================================
-- Live Aurora Theme Refresh
-- ============================================================================

function M.refresh_theme()
	apply_highlights()

	configure_diagnostics()

	vim.schedule(function()
		vim.cmd("redraw!")
		vim.cmd("redrawstatus!")
	end)

	return true
end

return M
