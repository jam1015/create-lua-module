-- File: lua/create_lua_module/init.lua
local M = {}

-- Attempt to get the module name from a require call using Treesitter.
local function get_module_from_treesitter()
  local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if not ok then
    return nil
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, "lua")
  if not parser then
    return nil
  end

  local tree = parser:parse()[1]
  if not tree then
    return nil
  end

  local root = tree:root()
  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1  -- Treesitter uses 0-indexed rows

  -- Define a Treesitter query to capture the string argument of a require call.
  local query = vim.treesitter.query.parse(
    "lua",
    [[
    (call_expression
      function: (identifier) @func (#eq? @func "require")
      arguments: (arguments (string) @module))
    ]]
  )

  for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
    local name = query.captures[id]
    if name == "module" then
      local start_row, _, end_row, _ = node:range()
      if cursor_row >= start_row and cursor_row <= end_row then
        local module_text = vim.treesitter.get_node_text(node, bufnr)
        -- Remove the surrounding quotes.
        module_text = module_text:gsub('^["\']', ""):gsub('["\']$', "")
        return module_text
      end
    end
  end

  return nil
end

function M.create_module()
  -- Try to get the module name using Treesitter first.
  local module_name = get_module_from_treesitter()
  if not module_name or module_name == "" then
    module_name = vim.fn.input("Module name (dot-separated): ")
  end
  if module_name == "" then
    print("No module name provided.")
    return
  end

  -- Convert the dot-separated module name to a file path.
  local file_path = module_name:gsub("%.", "/")
  if not file_path:match("%.lua$") then
    file_path = file_path .. ".lua"
  end

  -- Determine the base directory:
  -- If editing a file inside a project with a 'lua' folder,
  -- create the module relative to that folder. Otherwise, use the cwd.
  local current_file = vim.fn.expand("%:p")
  local base = nil
  local lua_dir = vim.fn.finddir("lua", vim.fn.expand("%:p:h") .. ";")
  if lua_dir and lua_dir ~= "" then
    base = vim.fn.fnamemodify(lua_dir, ":p")
  else
    base = vim.fn.getcwd()
  end

  local full_path = base .. "/" .. file_path

  if vim.fn.filereadable(full_path) == 1 then
    print("File already exists: " .. full_path)
    return
  end

  -- Create any missing directories.
  local dir = vim.fn.fnamemodify(full_path, ":h")
  vim.fn.mkdir(dir, "p")

  -- Create and open the new file with a basic Lua module boilerplate.
  local fd, err = io.open(full_path, "w")
  if not fd then
    print("Failed to create file: " .. err)
    return
  end

  fd:write("-- " .. module_name .. "\n\nlocal M = {}\n\n\nreturn M\n")
  fd:close()

  print("Module created: " .. full_path)
  vim.cmd("edit " .. full_path)
end

-- Create a Neovim command to invoke the module creation.
vim.api.nvim_create_user_command("CreateLuaModule", function()
  M.create_module()
end, {})

return M
