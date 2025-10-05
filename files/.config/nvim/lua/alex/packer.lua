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
    use({ "neovim/nvim-lspconfig" })
    use({ "williamboman/mason.nvim" })
    use({ "williamboman/mason-lspconfig.nvim" })
    use({ "hrsh7th/nvim-cmp" })
    use({ "hrsh7th/cmp-nvim-lsp" })
    use({ "hrsh7th/cmp-buffer" })
    use({ "hrsh7th/cmp-path" })
    use({ "hrsh7th/cmp-cmdline" })
    use({ "L3MON4D3/LuaSnip" })
    use({ "saadparwaiz1/cmp_luasnip" })
    use({ "nvimtools/none-ls.nvim" })

    use("wbthomason/packer.nvim") -- Have packer manage itself

    use({
        "nvim-telescope/telescope.nvim",
        tag = "0.1.3",
        requires = { "nvim-lua/plenary.nvim" },
    })

    use({
        "rose-pine/neovim",
        as = "rose-pine",
        config = function()
            vim.cmd("colorscheme rose-pine")
        end,
    })

    use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
    use("nvim-treesitter/playground")

    use({
        "Vonr/align.nvim",
        branch = "v2",
    })

    use({
        "ray-x/lsp_signature.nvim",
        tag = "v0.3.1",
    })

    -- use('github/copilot.vim')

    use("APZelos/blamer.nvim")

    use({
        "hedyhli/markdown-toc.nvim",
    })

    use({
        "nvim-tree/nvim-web-devicons",
    })

    use({
        "nvim-lualine/lualine.nvim",
        requires = { "nvim-tree/nvim-web-devicons" },
    })

    use({
        "hiphish/rainbow-delimiters.nvim",
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
        "TheLeoP/powershell.nvim",
    })

    use({
        "christoomey/vim-tmux-navigator",
    })

    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
