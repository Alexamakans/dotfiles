require("refactoring").setup()

vim.keymap.set("x", "<leader>ee", ":Refactor extract ")
vim.keymap.set("x", "<leader>eef", ":Refactor extract_to_file ")

vim.keymap.set("x", "<leader>ev", ":Refactor extract_var ")

vim.keymap.set({ "n", "x" }, "<leader>iv", ":Refactor inline_var")

vim.keymap.set("n", "<leader>if", ":Refactor inline_func")

vim.keymap.set("n", "<leader>eb", ":Refactor extract_block")
vim.keymap.set("n", "<leader>ebf", ":Refactor extract_block_to_file")

require("refactoring").setup({
	prompt_func_return_type = {
		go = true,
	},
	prompt_func_param_type = {
		go = true,
	},
})
