local M = {}

function M.create_module(opts)
  -- Determine if the optional argument was provided.
  local as_init = false
  if opts and opts.args and opts.args == "init" then
    as_init = true
  end

  -- Get the current line and the cursor column.
  local line = vim.fn.getline(".")
  local col = vim.fn.col(".")

  -- Look for a quoted string that contains the cursor position.
  local module_name = nil
  local pos = 1
  while true do
    local start_pos, end_pos, quote, content = line:find('(["\'])(.-)%1', pos)
    if not start_pos then break end
    if col >= start_pos and col <= end_pos then
      module_name = content
      break
    end
    pos = end_pos + 1
  end

  if not module_name or module_name == "" then
    print("Cursor is not inside a quoted string. Aborting module creation.")
    return
  end

  -- Convert the dot-separated module name to a file path.
  local file_path = module_name:gsub("%.", "/")

  if as_init then
    file_path = file_path .. "/init.lua"
  else
    if not file_path:match("%.lua$") then
      file_path = file_path .. ".lua"
    end
  end

  -- Determine the base directory.
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

  -- Set filetype to lua if applicable.
  if vim.fn.expand("%:e") == "lua" then
    vim.cmd("set filetype=lua")
  end
end

-- Create a Neovim command to invoke the module creation.
vim.api.nvim_create_user_command("CreateLuaModule", function(opts)
  M.create_module(opts)
end, { nargs = "?" })

return M
