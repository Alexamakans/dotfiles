local base_dir = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "..", "nvim"))
vim.opt.runtimepath:prepend(base_dir)

local lsps = require("shared.lsps")
local treesitters = require("shared.treesitters")

vim.list_extend(treesitters, { "go" }) -- treesitter parsers to install
-- vim.list_extend(treesitters, { "python", "toml" })

vim.list_extend(lsps, {
  {
    name = "gopls",
    config = {}, -- custom config for lsp to pass to vim.lsp.config
  },
  {
    -- entry with no name and config can be used to install non-lsp tools
    -- with Mason, and configure them for conform.nvim or nvim-lint.
    tools = {
      mason = { "golangci-lint" }, -- binaries to install with Mason
      -- mason = { "ruff" },
      formatters = {
        by_ft = {
          -- conform.nvim config of formatters to use, by filetype
          -- python = { "ruff_fix", "ruff_fmt" }
        },
      },
      linters = {
        by_ft = {
          -- nvim-lint config of linters to use, by filetype
          -- python = { "ruff_lint" }
        },
      },
    },
  },
})

dofile(vim.fs.joinpath(base_dir, "init.lua"))
