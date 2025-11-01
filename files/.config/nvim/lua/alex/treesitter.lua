local treesitters = require("shared.treesitters")

require("nvim-treesitter.configs").setup({
  ensure_installed = treesitters,
  sync_install = false,
  auto_install = false,

  indent = {
    enable = true,
  },

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<leader>j",
      node_incremental = "<S-l>",
      scope_incremental = "<leader>j",
      node_decremental = "<S-h>",
    },
  },
})
