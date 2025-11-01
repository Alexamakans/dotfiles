vim.g.mapleader = " "

-- Use Ctrl + C to exit Insert mode
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Open directory/explorer view
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move selection down/up
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv'")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv'")

-- Stay at same char when doing J
vim.keymap.set("n", "J", "mzJ`z")

-- Center view after C-d/u
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Center view after next/prev occurrence
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste after deleting into void register (default yank register remains intact)
vim.keymap.set("x", "<leader>p", '"_dP')

-- Yank with system clipboard as target
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')

-- Delete into void register
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d')

-- Unbind Q
vim.keymap.set("n", "Q", "<nop>")

-- Find & Replace on current word in entire file.
vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
-- Find & Replace on current word on current line.
vim.keymap.set("n", "<leader>S", ":'<,'>s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- Resets search highlight
vim.keymap.set("n", "<leader>h", "<cmd>noh<CR>")

-- Move through quickfix list (:cnext, :cprev)
vim.keymap.set("n", "<C-j>", "<cmd>cn<CR>")
vim.keymap.set("n", "<C-k>", "<cmd>cp<CR>")

-- Asterisk doesn't traverse the find list.
-- I want it to function solely as a highlight keybind.
vim.keymap.set("n", "*", "*N")

-- Telescope
local telescope_builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>pf", telescope_builtin.find_files, {})
vim.keymap.set("n", "<C-p>", telescope_builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", telescope_builtin.live_grep, {})
vim.keymap.set("n", "<leader>vrd", telescope_builtin.diagnostics, {})

-- Diagnostics
vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Prev diagnostic" })

-- Formatting
vim.keymap.set({ "n", "x" }, "<leader>f", function()
  require("conform").format({ async = true, lsp_fallback = true })
end)

-- Make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Copy relative path of current buffer to clipboard
vim.keymap.set("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.fn.setreg("", vim.fn.expand("%:p"))
end)
