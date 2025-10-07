---@param s string
local function echo(s)
  local debug = false
  if not debug then
    return
  end
  vim.api.nvim_echo({ { s } }, false, {})
end

---@param tag string
---@param camel_case boolean
---@param field_declaration_list_node TSNode
local function add_tags(tag, camel_case, field_declaration_list_node)
  local node = field_declaration_list_node
  -- local child_count = node:child_count()
  for field_declaration, _ in node:iter_children() do
    if field_declaration:named_child_count() == 2 then
      local name_node = field_declaration:named_child(0)
      assert(name_node ~= nil, "named_child(1) of 'field_declarataion' node is nil")
      assert(
        name_node:type() == "field_identifier",
        "named_child(1) of 'field_declaration' node should be 'field_identifier', is '"
          .. name_node:type()
          .. "'"
      )
      local _, _, end_row, end_col = vim.treesitter.get_node_range(field_declaration)
      local name = vim.treesitter.get_node_text(name_node, 0, nil)
      if camel_case then
        local nameFirstLetterLowercase = name:sub(1, 1):lower() .. name:sub(2)
        name = nameFirstLetterLowercase
      end
      local tagString = "`" .. tag .. ':"' .. name .. '"`'
      vim.api.nvim_buf_set_text(0, end_row, end_col, end_row, end_col, { tagString })
    end
  end
end

---@return TSNode|nil
local function get_field_declaration_list_node(args)
  local node = vim.treesitter.get_node()
  if node == nil then
    return
  end

  if node:type() == "field_identifier" or node:type() == "type_identifier" then
    local parent = node:parent()
    if parent == nil then
      echo(
        "failed because parent() of '"
          .. node:type()
          .. "' wasn't of type 'field_declaration', is nil"
      )
      return
    elseif parent:type() == "field_declaration" or parent:type() == "type_spec" then
      node = parent
    else
      echo(
        "failed because parent() of '"
          .. node:type()
          .. "' wasn't of type 'field_declaration' or 'type_spec', is '"
          .. parent:type()
          .. "'"
      )
      return
    end
  end

  if node:type() == "field_declaration" then
    echo("field_declaration found")
    node = node:parent()
    if node == nil or node:type() ~= "field_declaration_list" then
      local err =
        "failed because parent() of 'field_declaration' wasn't of type 'field_declaration_list'"
      if node == nil then
        err = err .. ", is nil"
      else
        err = err .. ", is '" .. node:type() .. "'"
      end
      echo(err)
      return
    end
    echo("field_declaration_list found")
  end

  if node:type() == "type_declaration" then
    echo("type_declaration found")
    node = node:child(1)
    if node == nil then
      return
    end
    echo("type_declaration's child is '" .. node:type() .. "'")
  end

  if node:type() == "type_spec" then
    echo("type_spec found")
    local type_node = node:named_child(1)
    if type_node == nil or type_node:type() ~= "struct_type" then
      local err = "failed because named_child(1) of 'type_spec' wasn't of type 'struct_type'"
      if type_node == nil then
        err = err .. ", is nil"
      else
        err = err .. ", is '" .. type_node:type() .. "'"
      end
      echo(err)
      return
    end
    node = type_node
  end

  if node:type() == "struct_type" then
    echo("struct_type found")
    local field_declaration_list_node = node:child(1)
    node = field_declaration_list_node
  end

  assert(node ~= nil, "couldn't find 'field_declaration_list' node, is nil")
  assert(
    node:type() == "field_declaration_list",
    "couldn't find 'field_declaration_list' node, is '" .. node:type() .. "'"
  )

  return node
end

vim.api.nvim_create_user_command("GolangJsonTagStruct", function(args)
  local node = get_field_declaration_list_node(args)
  if node == nil then
    return
  end

  add_tags("json", true, node)
  vim.lsp.buf.format()
end, {})

vim.api.nvim_create_user_command("GolangXmlTagStruct", function(args)
  local node = get_field_declaration_list_node(args)
  if node == nil then
    return
  end

  add_tags("xml", false, node)
  vim.lsp.buf.format()
end, {})

vim.api.nvim_create_user_command("GolangYamlTagStruct", function(args)
  local node = get_field_declaration_list_node(args)
  if node == nil then
    return
  end

  add_tags("yaml", true, node)
  vim.lsp.buf.format()
end, {})
