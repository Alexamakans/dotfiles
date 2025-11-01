vim.opt.list = true
vim.opt.listchars:append({ trail = ".", tab = "T~" })

-- Group for our autocmds
local aug = vim.api.nvim_create_augroup("WhitespaceHL", { clear = true })

-- Re-apply highlight colors when the colorscheme changes
local function set_whitespace_hl()
  vim.api.nvim_set_hl(0, "EoLSpace", { bg = "#aaaa33" })
  vim.api.nvim_set_hl(0, "Tabs", { bg = "#ff3377" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = aug,
  callback = set_whitespace_hl,
})

set_whitespace_hl() -- set once at startup, too

-- Apply matches for each window
local function apply_matches_for_window()
  -- Avoid duplicating matches in the same window by caching ids
  if vim.w._eolspace_match == nil then
    vim.w._eolspace_match = vim.fn.matchadd("EoLSpace", [[\s\+$]])
  end
  if vim.w._tabs_match == nil then
    vim.w._tabs_match = vim.fn.matchadd("Tabs", [[\t\+]])
  end
end

vim.api.nvim_create_autocmd({ "VimEnter", "WinNew", "BufWinEnter" }, {
  group = aug,
  callback = apply_matches_for_window,
})

-- Apply immediately for the current window
apply_matches_for_window()
