# Create Lua Module

Create Lua Module is a simple Neovim plugin written in Lua. It lets you
quickly generate a Lua module file based on a dot-separated module name.

## Features

- Converts dot-separated module names (e.g., `foo.bar.baz`) into a file path (e.g., `foo/bar/baz.lua`).
- Supports an optional argument `init`: running `:CreateLuaModule init` creates the module as a directory with an `init.lua` file (e.g., `foo/bar/init.lua`).
- Automatically creates any missing directories.
- Adds a basic Lua module boilerplate to the new file.
- Opens the new file in Neovim after creation.
- If the opened file has a `.lua` extension, the plugin explicitly sets the filetype to `lua` as a redundancy.

## Installation

You can install this plugin via your favorite Neovim plugin manager. For
example, using [lazy.nvim](https://github.com/folke/lazy.nvim):

``` lua
use {
  'yourusername/create_lua_module',
  config = function()
    require("create_lua_module")
  end
}
  
```

## Usage

1.  Open a Lua file in Neovim.
2.  Type a dot-separated module name (for example, `foo.bar.baz`).
3.  Place your cursor on the module name.
4.  Execute the command:
    - `:CreateLuaModule` -- Creates the file `foo/bar/baz.lua`
    - `:CreateLuaModule init` -- Creates the module as a directory with an `init.lua` file (`foo/bar/init.lua`)
5.  The plugin creates the file, adds a basic module template, opens it
    for editing, and if it's a Lua file, it ensures the filetype is set
    to `lua`.

