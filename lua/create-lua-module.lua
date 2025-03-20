local M = {}

function M.create_module(opts)
  -- Determine if the optional argument was provided.
  local as_init = false
  if opts and opts.args and opts.args == "init" then
    as_init = true
  end

  -- Get the module name under the cursor.
  local module_name = vim.fn.expand("<cWORD>")
  if module_name == nil or module_name == "" then
    module_name = vim.fn.input("Module name (dot-separated): ")
  end
  if module_name == "" then
    print("No module name provided.")
    return
  end

  -- Convert the dot-separated module name to a file path.
  local file_path = module_name:gsub("%.", "/")

  if as_init then
    -- If 'init' option is used, create the module as a directory with an init.lua file.
    file_path = file_path .. "/init.lua"
  else
    -- Append .lua extension if not already present.
    if not file_path:match("%.lua$") then
      file_path = file_path .. ".lua"
    end
  end

  -- Determine the base directory.
  -- Try to locate a 'lua' directory relative to the file being edited.
  local base = nil
  local lua_dir = vim.fn.finddir("lua", vim.fn.expand("%:p:h") .. ";")
  if lua_dir and lua_dir ~= "" then
    base = vim.fn.fnamemodify(lua_dir, ":p")
  else
    base = vim.fn.getcwd()
  end

  local full_path = base .. "/" .. file_path

  -- Check if the file already exists.
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

  -- After editing, if the current file has a .lua extension, set the filetype to lua.
  if vim.fn.expand("%:e") == "lua" then
    vim.cmd("set filetype=lua")
  end
end

-- Create a Neovim command to invoke the module creation.
vim.api.nvim_create_user_command("CreateLuaModule", function(opts)
  M.create_module(opts)
end, { nargs = "?" })

return M
