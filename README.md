# Create Lua Module

Create Lua Module is a simple Neovim plugin written in Lua. It lets you
quickly generate a Lua module file based on a dot-separated module name.

## Features

-   Converts dot-separated module names (e.g., `foo.bar.baz`) into a
    file path (`foo/bar/baz.lua`).
-   Automatically creates any missing directories.
-   Adds a basic Lua module boilerplate to the new file.
-   Opens the new file in Neovim after creation.

## Installation

You can install this plugin via your favorite Neovim plugin manager. For
example, using `packer.nvim`:

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
4.  Execute the command: `:CreateLuaModule`.
5.  The plugin creates the file `foo/bar/baz.lua` (relative to your
    current working directory), adds a basic module template, and opens
    it for editing.

## Repository Structure

The repository is organized as follows:

``` text
create_lua_module/
├── lua/
│   └── create_lua_module/
│       └── init.lua
├── README.html
└── LICENSE
```
