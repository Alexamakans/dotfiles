-- List of
-- {
--   name = "name",
--   config = {},
--   tools = {
--     mason = { "black", "ruff" }, -- tell mason what binaries to install
--     formatters = {
--       by_ft = { python = { "ruff_format", "black" } }, -- passed to conform.nvim
--       overrides = {                                    -- passed to conform.nvim
--         black = { args = { ... } },
--       },
--     },
--     linters = {                                        -- passed to nvim-lint
--       by_ft = { python = { "ruff" } },
--     },
--   },
-- }
-- tables
local M = {}
return M
