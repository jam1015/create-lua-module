-- File: lua/create_lua_module/init.lua
local M = {}

-- Utility function: Get the quoted string under the cursor.
local function get_quoted_string_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
  for s, quote, content, e in line:gmatch("()([\"'])(.-)%2()") do
    if cursor_col >= s and cursor_col <= e then
      return content
    end
  end
  return nil
end

function M.create_module(cmd_arg)
  local init_mode = false
  if cmd_arg == "init" then
    init_mode = true
  end

  -- Get the module name from the quoted string under the cursor or prompt for one.
  local module_name = get_quoted_string_at_cursor()
  if not module_name or module_name == "" then
    module_name = vim.fn.input("Module name (dot-separated): ")
  end
  if module_name == "" then
    print("No module name provided.")
    return
  end

  local file_path
  if init_mode then
    -- If "init" mode, remove any trailing .lua from the module name, convert dots to slashes,
    -- and later append /init.lua.
    module_name = module_name:gsub("%.lua$", "")
    file_path = module_name:gsub("%.", "/")
  else
    file_path = module_name:gsub("%.", "/")
    if not file_path:match("%.lua$") then
      file_path = file_path .. ".lua"
    end
  end

  -- Determine the base directory.
  -- If editing a file within a project that has a 'lua' folder, use that folder.
  -- Otherwise, default to the current working directory.
  local current_file = vim.fn.expand("%:p")
  local base = nil
  local lua_dir = vim.fn.finddir("lua", vim.fn.expand("%:p:h") .. ";")
  if lua_dir and lua_dir ~= "" then
    base = vim.fn.fnamemodify(lua_dir, ":p")
  else
    base = vim.fn.getcwd()
  end

  local full_path
  if init_mode then
    full_path = base .. "/" .. file_path .. "/init.lua"
  else
    full_path = base .. "/" .. file_path
  end

  if vim.fn.filereadable(full_path) == 1 then
    print("File already exists: " .. full_path)
    return
  end

  -- Create any missing directories for the file's parent directory.
  local dir = vim.fn.fnamemodify(full_path, ":h")
  vim.fn.mkdir(dir, "p")

  -- Create a new empty buffer with the target file name.
  -- (The file won't actually be written until the user saves it.)
  vim.cmd("enew")
  vim.api.nvim_buf_set_name(0, full_path)

  -- Insert basic Lua module boilerplate into the new buffer.
  local boilerplate = {
    "-- " .. module_name,
    "",
    "local M = {}",
    "",
    "return M",
    "",
  }
  vim.api.nvim_buf_set_lines(0, 0, -1, false, boilerplate)

  print("Module buffer created: " .. full_path)
end

-- Create a Neovim command that accepts an optional argument.
vim.api.nvim_create_user_command("CreateLuaModule", function(opts)
  M.create_module(opts.args)
end, { nargs = "?" })

return M
