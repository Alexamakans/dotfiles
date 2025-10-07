vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", '"_dP')

vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format({ timeout_ms = 5000 })
end)

vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
vim.keymap.set("n", "<leader>S", ":'<,'>s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Copy relative path of current buffer to clipboard
vim.keymap.set("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.fn.setreg("", vim.fn.expand("%:p"))
end)

vim.keymap.set("n", "<leader>h", "<cmd>noh<CR>")

-- nvim-treesitter-context
-- vim.keymap.set("n", "[c", function()
-- 	require("treesitter-context").go_to_context(vim.v.count1)
-- end)

-- mbbill/undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

vim.keymap.set("n", "<C-S-j>", "<cmd>cn<CR>")
vim.keymap.set("n", "<C-S-k>", "<cmd>cp<CR>")

vim.keymap.set("n", "<leader>tj", "<cmd>GolangJsonTagStruct<CR>")
vim.keymap.set("n", "<leader>tx", "<cmd>GolangXmlTagStruct<CR>")
vim.keymap.set("n", "<leader>ty", "<cmd>GolangYamlTagStruct<CR>")
