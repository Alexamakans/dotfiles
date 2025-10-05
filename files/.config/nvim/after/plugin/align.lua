local NS = { noremap = true, silent = true }
local align = require("align")

vim.keymap.set("x", "aa", function()
  align.align_to_char({ length = 1 })
end, NS)

vim.keymap.set("x", "ad", function()
  align.align_to_char({ preview = true, length = 2 })
end, NS)

vim.keymap.set("x", "aw", function()
  align.align_to_string({ preview = true, regex = false })
end, NS)

vim.keymap.set("x", "ar", function()
  align.align_to_string({ preview = true, regex = true })
end, NS)

vim.keymap.set("n", "gaw", function()
  align.operator(align.align_to_string, {
    regex = false,
    preview = true,
  })
end, NS)

vim.keymap.set("n", "gaa", function()
  align.operator(align.align_to_char)
end, NS)

-- Align inside braces, powershell specific
vim.keymap.set("n", "<leader>a{", "vi{aa=", { remap = true })
vim.keymap.set("n", "<leader>a}", "vi}aa=", { remap = true })
-- Align inside parentheses, powershell specific
vim.keymap.set("n", "<leader>a(", "vi(ar\\]\\@<= \\[<CR><Esc>vi(aa$<Esc>vi(aa=", { remap = true })
vim.keymap.set("n", "<leader>a)", "vi(ar\\]\\@<= \\[<CR><Esc>vi)aa$<Esc>vi)aa=", { remap = true })
