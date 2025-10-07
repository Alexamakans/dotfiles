-- Neovim-friendly defaults
std = "lua54"
codes = true                 -- show warning codes (e.g. W111)
max_line_length = 120
ignore = {
  "631",                     -- allow line length in long strings/comments
}

-- Treat the Neovim API table as a known global
globals = {
  "vim",
}

-- Common patterns to skip (generated/vendor files)
exclude_files = {
  "plugin/packer_compiled.lua",
  "**/node_modules/**",
  "**/vendor/**",
  "**/.git/**",
  ".direnv/**",
}

-- Per-path tweaks (examples)
files = {
  ["test/"] = {
    globals = { "describe", "it", "before_each", "after_each", "pending", "assert", "stub", "spy" },
  },
  ["lua/"] = {
    -- Allow unused self for methods
    allow_defined = true,
  },
}

-- Be stricter about unused vars, but allow intentionally prefixed ones
unused_args = false          -- flag unused function args…
allow_defined = true
allow_global = false
allow_unused_globals = false
ignore = { "231" }           -- …except allow `_`-prefixed locals/args (Luacheck’s rule 231 handles this)
