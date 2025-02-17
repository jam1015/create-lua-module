# Create Lua Module

Create Lua Module is a simple Neovim plugin written in Lua. It lets you
quickly generate a Lua module file based on a dot-separated module name.

## Features

-   Converts dot-separated module names (e.g., `foo.bar.baz`) into a
    file path (`foo/bar/baz.lua`).
-   Adds a basic Lua module boilerplate to the new file.
-   Opens the new file in Neovim after creation as a buffer; doesn't
    write the buffer to disk.

## Installation

With [`lazy.nvim`](https://github.com/folke/lazy.nvim)

``` lua
 {
  'jam1015/create_lua_module',
   dependencies = {'jghauser/mkdir.nvim'},
}
```
The dependency lets you save files to paths that don't yet exist.

## Usage

1.  Open a Lua file in Neovim.
2.  Type a dot-separated module name (for example, `foo.bar.baz`).
3.  Place your cursor on the module name.
4.  Execute the command: `:CreateLuaModule`.
5.  The plugin creates the file `foo/bar/baz.lua` (relative to your
    current working directory), adds a basic module template, and opens
    it for editing.
6.  Optionally takes the literal argument `init` to create the module as `foo/bar/bas/init.lua`.

