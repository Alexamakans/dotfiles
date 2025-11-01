local aug = vim.api.nvim_create_augroup("TransparentBG", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = aug,
  callback = function()
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" }) -- main editor windows
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" }) -- floating windows (LSP hovers, popups, some plugin UIs)
  end,
})
