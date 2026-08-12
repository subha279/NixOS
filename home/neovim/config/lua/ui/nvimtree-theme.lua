-- ============================================================================
-- Aurora NvimTree Highlights
-- ============================================================================

local function setup()
  local groups = {
    -- Background
    NvimTreeNormal = {
      link = "Normal",
    },

    NvimTreeNormalNC = {
      link = "Normal",
    },

    NvimTreeEndOfBuffer = {
      link = "EndOfBuffer",
    },

    -- Directory
    NvimTreeFolderName = {
      link = "Directory",
    },

    NvimTreeOpenedFolderName = {
      link = "Directory",
      bold = true,
    },

    NvimTreeFolderIcon = {
      link = "Directory",
    },

    -- Files
    NvimTreeFileName = {
      link = "Normal",
    },

    NvimTreeOpenedFile = {
      link = "CursorLine",
      bold = true,
    },

    NvimTreeModifiedFile = {
      link = "DiagnosticWarn",
    },

    -- Root
    NvimTreeRootFolder = {
      link = "Title",
      bold = true,
    },

    -- Git
    NvimTreeGitNew = {
      link = "DiagnosticOk",
    },

    NvimTreeGitDirty = {
      link = "DiagnosticWarn",
    },

    NvimTreeGitDeleted = {
      link = "DiagnosticError",
    },

    NvimTreeGitStaged = {
      link = "DiagnosticOk",
    },

    NvimTreeGitMerge = {
      link = "DiagnosticError",
    },

    NvimTreeGitRenamed = {
      link = "Special",
    },

    NvimTreeGitIgnored = {
      link = "Comment",
    },

    -- Diagnostics
    NvimTreeLspDiagnosticsError = {
      link = "DiagnosticError",
    },

    NvimTreeLspDiagnosticsWarning = {
      link = "DiagnosticWarn",
    },

    NvimTreeLspDiagnosticsInformation = {
      link = "DiagnosticInfo",
    },

    NvimTreeLspDiagnosticsHint = {
      link = "DiagnosticHint",
    },

    -- Window separator
    NvimTreeWinSeparator = {
      link = "WinSeparator",
    },
  }

  for name, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, name, opts)
  end
end

return {
  setup = setup,
}
