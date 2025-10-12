local nl = require("null-ls")

nl.setup({
  sources = {
    nl.builtins.diagnostics.revive,
    nl.builtins.formatting.goimports,
    nl.builtins.formatting.prettier,
    nl.builtins.formatting.clang_format,
    nl.builtins.formatting.mdformat,
    nl.builtins.formatting.ruff,
    nl.builtins.formatting.shfmt.with({
      args = {
        "--indent",
        "2",
        "--space-redirects",
        "--filename",
        "$FILENAME",
      },
    }),
    nl.builtins.formatting.alejandra,
  },
})
