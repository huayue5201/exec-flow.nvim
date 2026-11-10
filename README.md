# exec-flow.nvim

Anchor line numbers in execution order while reading code: pure in-memory anchors plus fast jumps. No files written, no session involved.

```
:ExecFlowAdd      mark the current line (takes the next number automatically)
:ExecFlowList     list all anchors in a float (<CR> jump, d delete, J/K reorder, c clear)
:ExecFlowClear    clear all anchors
:ExecFlowQf       export to the quickfix list
```

## Features

- Positions are stored as extmarks, so they follow inserted / deleted lines instead of storing fixed line numbers
- Numbers are right-aligned to the window edge, so they do not crowd the code or overlap indentation
- Numbers reflect insertion order; after `J/K` reordering everything is renumbered
- `]x` / `[x` style jumps are bound by the host and go in **sequence order**, not file line order
- Memory only: anchors disappear when Neovim exits; long-term tracking belongs to TODO-style plugins
- The float UI is built in (private `exec_flow.float_list`), no third-party dependencies

## Installation

Any plugin manager; the Lua module name is `exec_flow`:

```lua
require("exec_flow").setup({
  -- all keys are disabled by default
  keys = {
    add = "<leader>xa",
    list = "<leader>xl",
    delete = "<leader>xd",
    clear = "<leader>xc",
    qf = "<leader>xq",
    next = "]x",
    prev = "[x",
  },
})
```

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `keys` | `false` | Keymap table; `false` registers nothing |
| `commands` | `{add="ExecFlowAdd",list="ExecFlowList",clear="ExecFlowClear",qf="ExecFlowQf"}` | Command names; rename them or set to `false` |
| `label` | `⟦n⟧` | `fun(seq) -> string` |
| `to_editor` | `nil` | Move focus to a normal editing window before jumping; return `false` if it could not move |
| `panel.title` | `" 执行流 "` | Float title (built-in default) |
| `panel.max_height` | `20` | Maximum float height |

## API

`add()`, `delete()`, `delete_at(idx)`, `clear()`, `jump(dir)`, `panel()`,
`move(entry, dir)`, `move_by_idx(idx, dir)`, `qf()`, `setup(opts)`.

## Health check

`:checkhealth exec-flow`
