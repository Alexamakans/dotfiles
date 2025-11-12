local base_dir = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "..", "nvim"))
vim.opt.runtimepath:prepend(base_dir)

local lsps = require("shared.lsps")
local treesitters = require("shared.treesitters")

vim.list_extend(treesitters, { "python", "toml", "yaml", "json", "markdown", "bash" })

vim.list_extend(lsps, {
  {
    name = "basedpyright",
    config = {},
  },
  {
    name = "tombi", -- toml lsp/linter/formatter
    config = {},
  },
  {
    tools = {
      mason = { "ruff", "markdownlint", "prettierd" },
      formatters = {
        by_ft = {
          python = { "ruff_fix", "ruff_format" },
          markdown = { "markdownlint" },
          yaml = { "prettierd" },
          json = { "prettierd" },
        },
      },
      linters = {
        by_ft = {
          python = { "ruff" },
          markdown = { "markdownlint" },
        },
      },
    },
  },
})

dofile(vim.fs.joinpath(base_dir, "init.lua"))
