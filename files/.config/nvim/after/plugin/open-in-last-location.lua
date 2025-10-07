-- Open last position
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    if vim.fn.line("'\"'") > 1 and vim.fn.line("'\"'") <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
})
