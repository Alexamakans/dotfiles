require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all" (the five listed parsers should always be installed)
	ensure_installed = { "c_sharp", "c", "lua", "vim", "vimdoc", "query", "javascript", "typescript", "rust" },
	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,

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

local tresitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
tresitter_parser_config.powershell = {
	install_info = {
		url = vim.fn.stdpath("config") .. "/tsparsers/tree-sitter-powershell",
		files = { "src/parser.c", "src/scanner.c" },
		branch = "main",
		generate_requires_npm = false,
		requires_generate_from_grammar = false,
	},
	filetype = "ps1",
}
