-- File: lua/create_lua_module/init.lua
local M = {}

-- Utility function: Get the quoted string under the cursor.
local function get_quoted_string_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
  -- Look for quoted strings in the line using a simple regex.
  for s, quote, content, e in line:gmatch("()([\"'])(.-)%2()") do
    if cursor_col >= s and cursor_col <= e then
      return content
    end
  end
  return nil
end

function M.create_module()
  -- Try to get the module name from a quoted string under the cursor.
  local module_name = get_quoted_string_at_cursor()
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
