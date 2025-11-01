local base_dir = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "..", "nvim"))
vim.opt.runtimepath:prepend(base_dir)

local lsps = require("shared.lsps")
local treesitters = require("shared.treesitters")

vim.list_extend(treesitters, { "yaml", "json", "bicep", "powershell", "bash" })

vim.list_extend(lsps, {
  {
    name = "azure_pipelines_ls",
    config = {
      cmd = { "azure-pipelines-language-server", "--stdio" },
      filetypes = { "yaml" },
      on_new_config = function(cfg, root)
        if not root or root == vim.loop.os_homedir() then
          cfg.enabled = false
        end
      end,
      root_markers = { ".git" },
      settings = {
        yaml = {
          schemas = {
            ["https://json.schemastore.org/azure-pipelines.json"] = {
              "azure-pipelines*.y?(a)ml",
              "template*.y?(a)ml",
              "pipeline*.y?(a)ml",
              ".azure-pipelines/**/*.y?(a)ml",
            },
          },
        },
      },
    },
  },
  {
    name = "bicep",
  },
  {
    name = "powershell_es",
    config = {
      bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
      settings = {
        powershell = {
          codeFormatting = {
            Preset = "OTBS",
            AutoCorrectAliases = true,
            AvoidSemiColonsAsLineTerminators = true,
            UseCorrectCasing = true,
            UseConstantStrings = false,
          },
        },
      },
    },
  },
  {
    tools = {
      mason = { "prettierd", "jsonlint", "yamllint" }, -- binaries to install with Mason
      formatters = {
        by_ft = {
          json = { "prettierd" },
          yaml = { "prettierd" },
          powershell = { "powershell_es" },
        },
      },
      linters = {
        by_ft = {
          json = { "jsonlint" },
          yaml = { "yamllint" },
          powershell = { "powershell_es" },
        },
      },
    },
  },
})

dofile(vim.fs.joinpath(base_dir, "init.lua"))
