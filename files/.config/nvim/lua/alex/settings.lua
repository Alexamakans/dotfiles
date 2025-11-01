vim.opt.encoding = "utf-8" -- UTF-8 is the default, but it's nice to be explicit about this one IMO.

-- Line numbers
vim.opt.nu = true -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative numbers. Current line stays absolute.

-- Tabs & indentation (2 spaces “soft tabs”)
vim.opt.tabstop = 2 -- Render a <Tab> as 2 spaces (visual width)
vim.opt.softtabstop = 2 -- Editing a <Tab> feels like 2 spaces (backspace/delete count)
vim.opt.shiftwidth = 2 -- >> and << shift by 2 spaces
vim.opt.expandtab = true -- Insert spaces instead of literal <Tab> characters

-- Auto indentation
vim.opt.smartindent = true -- Basic smart indenting on new lines (language-agnostic)

-- Wrapping
vim.opt.wrap = false -- Do not soft-wrap long lines (keeps columns stable)

-- Files, backups, and undo
vim.opt.swapfile = true -- Enable swap files (a bit of clutter; safer if Vim crashes)
vim.opt.backup = false -- Do not keep backup files like file.txt~
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- Where to store persistent undo history
vim.opt.undofile = true -- Enable persistent undo across sessions
-- Make sure the undo dir exists: `mkdir -p ~/.vim/undodir`

-- Searching
vim.opt.hlsearch = true -- Highlight matches after a search.
-- <leader>h (from ./remap.lua) to unhighlight.

vim.opt.incsearch = true -- Show matches as you type your search

-- Colors
vim.opt.termguicolors = true -- 24-bit color in the terminal (required by many modern themes)

-- UI niceties
vim.opt.cursorcolumn = true -- Extend the cursor visually upwards and downards, filling the entire column.
vim.opt.scrolloff = 10 -- Keep 10 lines visible above/below the cursor (context while scrolling)
vim.opt.signcolumn = "yes" -- Always show the sign column (prevents text “jumps” when diagnostics appear)
vim.opt.isfname:append("@-@") -- Treat @ and - as filename chars (improves gf, path detection for some tools)

-- Performance / timing
vim.opt.updatetime = 30 -- Faster CursorHold/autocmds and quicker LSP diagnostics updates (default is 4000ms)
-- Very low values can increase background CPU usage in some setups; 50–200ms is common.

-- Visual guide(s) for line length
vim.opt.colorcolumn = { "100", "120" } -- Draw rulers at columns 100 and 120

-- When splitting vertically (:vsplit, <C-w><C-v>), the window on the right will get focus.
vim.opt.splitright = true

-- When splitting horizontally (:split, <C-w><C-s>), the window on the bottom will get focus.
vim.opt.splitbelow = true

-- Highlight the current line and line number in the active window.
-- Highlight cursorline only in the focused window
vim.api.nvim_create_augroup("CursorLineOnlyInActiveWindow", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = "CursorLineOnlyInActiveWindow",
  callback = function()
    vim.wo.cursorline = true
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = "CursorLineOnlyInActiveWindow",
  callback = function()
    vim.wo.cursorline = false
  end,
})
