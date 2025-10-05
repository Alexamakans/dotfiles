local nl = require("null-ls")

nl.setup({
    sources = {
        nl.builtins.diagnostics.revive,
        nl.builtins.diagnostics.sqlfluff.with({
            extra_args = { "--dialect", "tsql" },
        }),
        nl.builtins.diagnostics.mypy.with({
            extra_args = function()
                local virtual = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX") or "/usr"
                return {
                    "--ignore-missing-imports",
                    "--check-untyped-defs",
                    "--install-types",
                    "--disallow-untyped-defs",
                    "--python-executable",
                    virtual .. "/bin/python3",
                }
            end,
        }),
        nl.builtins.formatting.sqlfluff.with({
            extra_args = { "--dialect", "tsql" },
        }),
        nl.builtins.formatting.black,
        nl.builtins.formatting.goimports,
        nl.builtins.formatting.prettier,
        nl.builtins.formatting.ocamlformat,
        nl.builtins.formatting.black.with({
            extra_args = function()
                return {
                    "--line-length",
                    "120",
                }
            end,
        }),
        nl.builtins.formatting.clang_format,
        nl.builtins.formatting.shfmt.with({
            args = {
                "--indent",
                "2",
                "--space-redirects",
                "--filename",
                "$FILENAME",
            },
        }),
    },
})
