# exec-flow.nvim

在阅读一段代码时按「执行顺序」打编号锚点：纯记忆锚点 + 快速跳转，不写文件、不进会话。

```
:ExecFlowAdd      标记当前行（自动取下一个编号）
:ExecFlowList     浮窗列出全部锚点（<CR> 跳、d 删、J/K 调序、c 清空）
:ExecFlowClear    清空全部
:ExecFlowQf       导出到 quickfix
```

## 特性

- 位置用 extmark 保存，插入 / 删除行自动跟随，不存死行号
- 编号右对齐到窗口右侧，不挤占代码、不与缩进重叠
- 编号 = 插入顺序；`J/K` 调序后统一重编号
- `]x` / `[x` 式跳转由宿主绑定，**按编号顺序**而不是文件行序
- 只活在内存里，重开 Neovim 即消失；长期追踪交给 todo 类插件
- 浮窗交互内置（私有 `exec_flow.float_list`），无第三方依赖

## 安装

任意插件管理器，Lua 模块名为 `exec_flow`：

```lua
require("exec_flow").setup({
  -- 键位默认全部关闭
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

## 配置

| 选项 | 默认 | 说明 |
| --- | --- | --- |
| `keys` | `false` | 键位表；`false` 表示完全不注册 |
| `commands` | `{add="ExecFlowAdd",list="ExecFlowList",clear="ExecFlowClear",qf="ExecFlowQf"}` | 命令名，可改名或设为 `false` |
| `label` | `⟦n⟧` | `fun(seq) -> string` |
| `to_editor` | `nil` | 跳转前把焦点挪到普通编辑窗口；返回 `false` 表示未能移动 |
| `panel.title` | `" 执行流 "` | 浮窗标题 |
| `panel.max_height` | `20` | 浮窗最大高度 |

## API

`add()`、`delete()`、`delete_at(idx)`、`clear()`、`jump(dir)`、`panel()`、
`move(entry, dir)`、`move_by_idx(idx, dir)`、`qf()`、`setup(opts)`。

## 健康检查

`:checkhealth exec-flow`
