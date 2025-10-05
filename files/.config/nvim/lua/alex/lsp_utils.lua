local LspUtils = {}

function LspUtils:highlight_hovered_if_highlight_provider(opts)
  assert(opts.buffer, "opts.buffer is required")
  assert(opts.client, "opts.client is required")
  if opts.client.server_capabilities.documentHighlightProvider then
    vim.cmd([[
          hi! link LspReferenceRead Visual
          hi! link LspReferenceText Visual
          hi! link LspReferenceWrite Visual
        ]])

    local gid = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
    vim.api.nvim_create_autocmd("CursorHold", {
      group = gid,
      buffer = opts.buffer,
      callback = function()
        vim.lsp.buf.document_highlight()
      end,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
      group = gid,
      buffer = opts.buffer,
      callback = function()
        vim.lsp.buf.clear_references()
      end,
    })
  end
end

return LspUtils
