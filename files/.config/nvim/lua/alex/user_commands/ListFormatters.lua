vim.api.nvim_create_user_command("ListFormatters", function()
  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })

  local formatters = vim.tbl_filter(function(c)
    return c.supports_method("textDocument/formatting")
  end, clients)

  formatters = vim.tbl_map(function(c)
    return c.name
  end, formatters)

  if #formatters > 0 then
    print(vim.inspect(formatters))
  else
    print("No formatters active in current buffer")
  end
end, {})
