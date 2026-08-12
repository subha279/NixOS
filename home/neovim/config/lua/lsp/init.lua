-- ============================================================================
-- Native Neovim LSP
-- ============================================================================

vim.diagnostic.config({
	virtual_text = {
		spacing = 2,
		source = "if_many",
	},

	signs = true,

	underline = true,

	update_in_insert = false,

	severity_sort = true,

	float = {
		border = "rounded",
		source = true,
	},
})

-- ============================================================================
-- Server configuration
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
-- Enable servers
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
				desc = desc,
			})
		end

		-- Navigation
		map("n", "gd", vim.lsp.buf.definition, "LSP: Definition")

		map("n", "gD", vim.lsp.buf.declaration, "LSP: Declaration")

		map("n", "gi", vim.lsp.buf.implementation, "LSP: Implementation")

		map("n", "gr", vim.lsp.buf.references, "LSP: References")

		map("n", "gt", vim.lsp.buf.type_definition, "LSP: Type definition")

		-- Documentation
		map("n", "K", vim.lsp.buf.hover, "LSP: Hover")

		map("n", "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature help")

		-- Refactoring
		map("n", "<leader>lr", vim.lsp.buf.rename, "LSP: Rename")

		map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "LSP: Code action")

		-- Diagnostics
		map("n", "<leader>ld", vim.diagnostic.open_float, "LSP: Line diagnostics")

		map("n", "[d", vim.diagnostic.goto_prev, "Diagnostics: Previous")

		map("n", "]d", vim.diagnostic.goto_next, "Diagnostics: Next")

		-- Inlay hints
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
