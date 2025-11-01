do
  local aug = vim.api.nvim_create_augroup("MyOnLspAttach", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = aug,
    desc = "LSP actions",
    callback = function(ev)
      local buf = ev.buf
      local opts = { buffer = buf, silent = true }

      vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("keep", { desc = "Hover" }, opts))
      vim.keymap.set(
        "n",
        "gd",
        vim.lsp.buf.definition,
        vim.tbl_extend("keep", { desc = "Goto definition" }, opts)
      )
      vim.keymap.set(
        "n",
        "gD",
        vim.lsp.buf.declaration,
        vim.tbl_extend("keep", { desc = "Goto declaration" }, opts)
      )
      vim.keymap.set(
        "n",
        "gi",
        vim.lsp.buf.implementation,
        vim.tbl_extend("keep", { desc = "Goto implementation" }, opts)
      )
      vim.keymap.set(
        "n",
        "gt",
        vim.lsp.buf.type_definition,
        vim.tbl_extend("keep", { desc = "Goto type definition" }, opts)
      )
      vim.keymap.set(
        "n",
        "gr",
        vim.lsp.buf.references,
        vim.tbl_extend("keep", { desc = "List references" }, opts)
      )
      vim.keymap.set(
        "n",
        "gs",
        vim.lsp.buf.signature_help,
        vim.tbl_extend("keep", { desc = "Signature help" }, opts)
      )
      vim.keymap.set(
        "n",
        "<leader>vrn",
        vim.lsp.buf.rename,
        vim.tbl_extend("keep", { desc = "Rename symbol" }, opts)
      )
      vim.keymap.set(
        "n",
        "<leader>vca",
        vim.lsp.buf.code_action,
        vim.tbl_extend("keep", { desc = "Code action" }, opts)
      )
    end,
  })
end

local cmp = require("cmp")
cmp.setup({
  sources = {
    { name = "nvim_lsp" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }), -- sometimes C-y is nicer
    ["<C-f>"] = cmp.mapping.confirm({ select = true }), -- sometimes C-f is nicer
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
  }),
})

require("mason").setup({})

-- shared.lsps is a table populated by profiles.
local lsps = require("shared.lsps")

local ensure_servers = {}

if os.getenv("NIXOS_NVIM") ~= "1" then
  ensure_servers = vim.tbl_map(function(s)
    return s.name
  end, lsps)
end
require("mason-lspconfig").setup({
  ensure_installed = ensure_servers,
  automatic_enable = true,
})

local caps = require("cmp_nvim_lsp").default_capabilities()

for _, s in ipairs(lsps) do
  if s.name ~= nil then
    local cfg = vim.deepcopy(s.config or {})
    if s.replace_capabilities then
      cfg.capabilities = s.config and s.config.capabilities or {}
    else
      cfg.capabilities = vim.tbl_deep_extend("force", vim.deepcopy(caps), cfg.capabilities or {})
    end
    vim.lsp.config(s.name, cfg)
  elseif s.config ~= nil then
    print("error: encountered an unnamed lsp config object")
  end
end
vim.lsp.enable(ensure_servers)

local fmt_by_ft, fmt_overrides, lint_by_ft, lint_overrides = {}, {}, {}, {}
local ensure_tools = {} -- mason package names of tools (not LSPs)

for _, s in ipairs(lsps) do
  local t = s.tools or {}

  -- collect mason tool names
  if os.getenv("NIXOS_NVIM") ~= "1" then
    for _, pkg in ipairs(t.mason or {}) do
      table.insert(ensure_tools, pkg)
    end
  end

  -- merge conform formatters
  if t.formatters and t.formatters.by_ft then
    for ft, list in pairs(t.formatters.by_ft) do
      fmt_by_ft[ft] = fmt_by_ft[ft] or {}
      -- append; order matters
      vim.list_extend(fmt_by_ft[ft], list)
    end
  end
  if t.formatters and t.formatters.overrides then
    for name, conf in pairs(t.formatters.overrides) do
      fmt_overrides[name] = conf
    end
  end

  -- merge nvim-lint linters
  if t.linters and t.linters.by_ft then
    for ft, list in pairs(t.linters.by_ft) do
      lint_by_ft[ft] = lint_by_ft[ft] or {}
      vim.list_extend(lint_by_ft[ft], list)
    end
  end
  if t.linters and t.linters.overrides then
    for name, conf in pairs(t.linters.overrides) do
      lint_overrides[name] = conf
    end
  end
end

-- Install tools at startup. If you don’t want this, skip this block.
-- Requires: 'WhoIsSethDaniel/mason-tool-installer.nvim'
require("mason-tool-installer").setup({
  ensure_installed = ensure_tools,
  auto_update = false,
  run_on_start = true, -- installs missing only; no “install on file open”
})

-- Conform (formatters)
require("conform").setup({
  formatters_by_ft = fmt_by_ft,
  formatters = fmt_overrides,
  format_on_save = function()
    return { timeout_ms = 2000, lsp_fallback = true }
  end,
})

-- nvim-lint (linters)
local lint = require("lint")
-- register overrides without replacing the table
for name, conf in pairs(lint_overrides) do
  lint.linters[name] = conf
end
lint.linters_by_ft = vim.tbl_extend("force", lint.linters_by_ft or {}, lint_by_ft)
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("LintOnWrite", { clear = true }),
  callback = function()
    require("lint").try_lint(nil, { ignore_errors = true })
  end,
})
