local lsp_utils = require("alex.lsp_utils")

vim.keymap.set("n", "<leader>vd", function()
    vim.diagnostic.open_float()
end)
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1 })
end)
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1 })
end)

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(event)
        local opts = {
            buffer = event.buf,
        }

        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover()
        end, opts)
        vim.keymap.set("n", "gd", function()
            vim.lsp.buf.definition()
        end, opts)
        vim.keymap.set("n", "gD", function()
            vim.lsp.buf.declaration()
        end, opts)
        vim.keymap.set("n", "gi", function()
            vim.lsp.buf.implementation()
        end, opts)
        vim.keymap.set("n", "gt", function()
            vim.lsp.buf.type_definition()
        end, opts)
        vim.keymap.set("n", "gr", function()
            vim.lsp.buf.references()
        end, opts)
        vim.keymap.set("n", "gs", function()
            vim.lsp.buf.signature_help()
        end, opts)
        vim.keymap.set("n", "<leader>vrn", function()
            vim.lsp.buf.rename()
        end, opts)
        vim.keymap.set({ "n", "x" }, "<leader>f", function()
            vim.lsp.buf.format({ async = true })
        end, opts)
        vim.keymap.set("n", "<leader>vca", function()
            vim.lsp.buf.code_action()
        end, opts)

        opts = {
            client = assert(vim.lsp.get_client_by_id(event.data.client_id)),
            buffer = opts.buffer,
        }
        lsp_utils:highlight_hovered_if_highlight_provider(opts)
    end,
})

require("mason").setup({})
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

--local vue_ls_path = vim.fn.expand(
--    '$MASON/packages/vue-language-server/node_modules/@vue/language-server')
--local vue_plugin = {
--    name = '@vue/typescript-plugin',
--    location = vue_ls_path,
--    languages = { 'vue' },
--    configNamespace = 'typescript',
--}
--local tsserver_filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' }

--local vtsls_config = {
--    settings = {
--        vtsls = {
--            tsserver = {
--                globalPlugins = {
--                    vue_plugin,
--                },
--            },
--        },
--    },
--    filetypes = tsserver_filetypes,
--}
--local vue_ls_config = {}
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls" },
    handlers = {
        -- default for any server you didn't special-case
        function(server_name)
            vim.lsp.config(server_name, { capabilities = lsp_capabilities })
        end,
    },
})

--vim.lsp.config('vtsls', vtsls_config)
--vim.lsp.config('vue_ls', vue_ls_config)
--vim.lsp.enable({ 'vtsls', 'vue_ls' })



require("lsp_signature").setup({
    close_timeout = 2000,
    transparency = 100, -- opacity, not transparency
})

local cmp = require("cmp")

cmp.setup({
    sources = {
        { name = "nvim_lsp" },
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-f>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
    }),
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
})
