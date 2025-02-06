# session-undo.nvim

> Session-aware undo protection

## Installation

```lua
{ "mvllow/session-undo.nvim" }
```

_Note that this plugin does modify your `u` key to use the safe undo. Use at your own risk 💜_

## Usage

```lua
-- Enable persistent undo
vim.o.undofile = true

require("session-undo").setup()
```
