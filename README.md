# referencer.nvim

`referencer.nvim` is a lightweight, asynchronous Neovim plugin written in Lua that uses the built-in LSP to show the number of references to functions, methods, types, or other symbols directly in the buffer using virtual text.

This is especially useful for quickly understanding code usage without manually invoking LSP commands.

---
## Preview

https://github.com/user-attachments/assets/1b6351c8-407b-4ed4-846e-dc6cef817219



---

## Features

- ✨ **Asynchronous**: non-blocking usage count queries using built-in LSP.
- 👁️ Displays number of references next to functions, methods, structs, etc.
- ⚖️ Fully configurable highlight groups and colors.
- 💪 Works with any LSP that supports `textDocument/references` and `textDocument/documentSymbol`.
- ⚖️ On-demand or auto-triggered via `LspAttach` event.

---

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "your-username/referencer.nvim",
    config = function()
        require("referencer").setup()
    end
}
```

With [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
    "your-username/referencer.nvim",
    config = function()
        require("referencer").setup()
    end
}
```

---

## Default configuration

```lua
require("referencer").setup({
    enable = false,                      -- enable after LSP attach
    format = "  %d reference(s)",       -- format string for reference count
    show_no_reference = true,            -- show if refs count = 0
    kinds = { 5, 6, 8, 12, 13, 14, 23, } -- LSP SymbolKinds to show references for
    hl_group = "Comment",                -- default highlight group
    color = nil,                         -- optional custom color (overrides hl_group)
    virt_text_pos = "eol",               -- virtual text position (eol | overlay | right_align)
    pattern = nil,                       -- pattern for LspAttach autocmd to auto-enable

})
```

## Configuration example

```lua
require("referencer").setup({
    enable = true, 
    format = "  %d ref", 
    show_no_reference = true, 
    kinds = { 12, 6, 5, 23, 8 }, 
    hl_group = "Comment", 
    color = "#FFA500", 
    virt_text_pos = "eol",
    pattern = "*.go", 
})
```

### `kinds`

A list of LSP `SymbolKind` numeric values. Some common kinds:

	File = 1;
	Module = 2;
	Namespace = 3;
	Package = 4;
	Class = 5;
	Method = 6;
	Property = 7;
	Field = 8;
	Constructor = 9;
	Enum = 10;
	Interface = 11;
	Function = 12;
	Variable = 13;
	Constant = 14;
	String = 15;
	Number = 16;
	Boolean = 17;
	Array = 18;
	Object = 19;
	Key = 20;
	Null = 21;
	EnumMember = 22;
	Struct = 23;
	Event = 24;
	Operator = 25;
	TypeParameter = 26;


Full list: [LSP Specification - SymbolKind](https://microsoft.github.io/language-server-protocol/specifications/specification-current/#symbolkind)

---

## Commands

| Command             | Description                         |
| ------------------- | ----------------------------------- |
| `:ReferencerToggle` | Toggle reference display on/off         |
| `:ReferencerUpdate` | Force refresh reference information in current buffer  |

---

## Notes

- ⚡ The plugin is **asynchronous**, so it won’t block your UI while fetching references.
- ✅ Compatible with most major LSPs (gopls, tsserver, etc.).
- ⚠ Only the first attached LSP client is used for requests.

