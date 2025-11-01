local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Install your plugins here
return packer.startup(function(use)
  use("wbthomason/packer.nvim") -- Have packer manage itself

  use({ "williamboman/mason.nvim" })
  use({ "WhoIsSethDaniel/mason-tool-installer.nvim" })
  use({ "mason-org/mason-lspconfig.nvim", requires = { "neovim/nvim-lspconfig" } })
  use({ "stevearc/conform.nvim" })
  use({ "mfussenegger/nvim-lint" })
  use({ "hrsh7th/nvim-cmp" })
  use({ "hrsh7th/cmp-nvim-lsp" })
  use({ "hrsh7th/cmp-buffer" })
  use({ "neovim/nvim-lspconfig" })
  use({ "hrsh7th/cmp-path" })
  use({ "hrsh7th/cmp-cmdline" })

  use({
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    requires = { "nvim-lua/plenary.nvim" },
  })

  use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
  use("nvim-treesitter/playground")

  use({
    "ray-x/lsp_signature.nvim",
    tag = "v0.3.1",
    config = function()
      require("lsp_signature").setup({
        close_timeout = 2000,
        transparency = 100, -- this is actually opacity
      })
    end,
  })

  use("APZelos/blamer.nvim")

  use({
    "nvim-lualine/lualine.nvim",
    requires = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
        },
        sections = {
          lualine_a = {},
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = {},
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  })

  use({
    "HiPhish/rainbow-delimiters.nvim",
  })

  use({
    "ThePrimeagen/refactoring.nvim",
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
    },
  })

  use({
    "mbbill/undotree",
  })

  use({
    "rose-pine/neovim",
    as = "rose-pine",
    config = function()
      vim.cmd("colorscheme rose-pine")
    end,
  })

  use({
    "ggandor/leap.nvim",
    config = function()
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
      vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
    end,
    requires = "tpope/vim-repeat",
  })

  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
