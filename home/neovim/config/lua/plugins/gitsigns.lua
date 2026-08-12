-- ============================================================================
-- Gitsigns
-- ============================================================================

require("gitsigns").setup({
  signs = {
    add = {
      text = "│",
    },

    change = {
      text = "│",
    },

    delete = {
      text = "󰍵",
    },

    topdelete = {
      text = "‾",
    },

    changedelete = {
      text = "│",
    },
  },

  current_line_blame = false,

  on_attach = function(buffer)
    local gs = package.loaded.gitsigns

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(
        mode,
        lhs,
        rhs,
        {
          buffer = buffer,
          silent = true,
          desc = desc,
        }
      )
    end

    map("n", "]g", gs.next_hunk, "Git: Next hunk")
    map("n", "[g", gs.prev_hunk, "Git: Previous hunk")

    map("n", "<leader>gh", gs.preview_hunk, "Git: Preview hunk")
    map("n", "<leader>gb", gs.blame_line, "Git: Blame line")
    map("n", "<leader>gd", gs.diffthis, "Git: Diff")
    map("n", "<leader>gr", gs.reset_hunk, "Git: Reset hunk")

    map(
      "n",
      "<leader>gS",
      gs.stage_hunk,
      "Git: Stage hunk"
    )

    map(
      "v",
      "<leader>gS",
      function()
        gs.stage_hunk({
          vim.fn.line("."),
          vim.fn.line("v"),
        })
      end,
      "Git: Stage selection"
    )
  end,
})
