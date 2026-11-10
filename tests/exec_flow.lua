vim.opt.rtp:prepend(vim.fn.getcwd())

local function check(cond, msg)
	if not cond then
		error("FAIL: " .. msg, 0)
	end
end

local flow = require("exec_flow")

-- 默认 setup：命令可用，键位默认不抢
flow.setup()
for _, name in ipairs({ "ExecFlowAdd", "ExecFlowList", "ExecFlowClear", "ExecFlowQf" }) do
	check(vim.fn.exists(":" .. name) == 2, "缺少命令 :" .. name)
end
check(vim.fn.maparg("<leader>xa", "n") == "", "默认不应映射任何键位")

local buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "alpha", "beta", "gamma" })
vim.api.nvim_set_current_buf(buf)
vim.api.nvim_win_set_cursor(0, { 1, 0 })
flow.add()
vim.api.nvim_win_set_cursor(0, { 3, 0 })
flow.add()
check(#flow._anchors() == 2, "应有两个锚点")

local a1 = flow._anchors()[1]
local mark = vim.api.nvim_buf_get_extmark_by_id(buf, vim.api.nvim_create_namespace("exec_flow"), a1.mark, { details = true })
check(mark[1] == 0, "第一个锚点应在第 1 行")
local details = mark[3] or {}
check(details.virt_text and details.virt_text[1][1] == "⟦1⟧", "默认标签应为 ⟦1⟧")

-- 同位置重复 add 不重复添加
vim.api.nvim_win_set_cursor(0, { 1, 0 })
flow.add()
check(#flow._anchors() == 2, "同一行不应重复添加")

-- 顺序跳转 + 环绕
vim.api.nvim_win_set_cursor(0, { 3, 0 })
flow.jump(1)
check(vim.api.nvim_win_get_cursor(0)[1] == 1, "jump(1) 应环绕到第 1 个锚点")
flow.jump(1)
check(vim.api.nvim_win_get_cursor(0)[1] == 3, "再次 jump(1) 应到第 2 个锚点")
flow.jump(-1)
check(vim.api.nvim_win_get_cursor(0)[1] == 1, "jump(-1) 应回到第 1 个锚点")

-- 调序后重编号
local second = flow._anchors()[2]
flow.move_by_idx(2, -1)
check(flow._anchors()[1].mark == second.mark, "move 应交换顺序")
local ns = vim.api.nvim_create_namespace("exec_flow")
local m1 = vim.api.nvim_buf_get_extmark_by_id(buf, ns, flow._anchors()[1].mark, { details = true })
check(m1[3].virt_text[1][1] == "⟦1⟧", "调序后应重编号")

-- 删除当前行 / 清空
vim.api.nvim_win_set_cursor(0, { 3, 0 })
flow.delete()
check(#flow._anchors() == 1, "delete 应删掉当前行锚点")
flow.clear()
check(#flow._anchors() == 0, "clear 应清空")

-- quickfix 导出（需要有文件名，否则 quickfix 条目会被丢弃）
vim.api.nvim_buf_set_name(buf, vim.fn.tempname() .. ".txt")
vim.api.nvim_win_set_cursor(0, { 1, 0 })
flow.add()
flow.qf()
local qf = vim.fn.getqflist()
check(#qf == 1 and qf[1].lnum == 1, "quickfix 应包含锚点")
check(qf[1].text:find("[1]", 1, true) == 1, "quickfix 文本应带序号")
vim.cmd("cclose")
flow.clear()

-- 浮窗列表
flow.add()
flow.panel()
check(flow._list and flow._list:is_open(), "panel 应打开浮窗")
check(#flow._list.items == 1, "浮窗应列出一个锚点")
flow._list:close("test")
flow.clear()

-- BufWipeout 清理
local tmp = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_lines(tmp, 0, -1, false, { "tmp" })
vim.api.nvim_set_current_buf(tmp)
flow.add()
check(#flow._anchors() == 1, "临时 buffer 应有锚点")
vim.cmd("bwipeout! " .. tmp)
check(#flow._anchors() == 0, "wipeout 后应自动清理锚点")

-- 自定义配置：标签、命令名、键位、to_editor
local editor_called = false
flow.setup({
	label = function(seq)
		return "<" .. seq .. ">"
	end,
	commands = { add = "MyFlowAdd", list = "MyFlowList", clear = "MyFlowClear", qf = "MyFlowQf" },
	keys = { add = "<leader>fa", list = "<leader>fl", next = "]f", prev = "[f" },
	to_editor = function()
		editor_called = true
		return true
	end,
})
check(vim.fn.exists(":MyFlowAdd") == 2, "应注册自定义命令")
check(vim.fn.maparg("<leader>fa", "n") ~= "", "应注册自定义键位")

vim.api.nvim_set_current_buf(buf)
vim.api.nvim_win_set_cursor(0, { 2, 0 })
flow.add()
local m = vim.api.nvim_buf_get_extmark_by_id(buf, ns, flow._anchors()[1].mark, { details = true })
check(m[3].virt_text[1][1] == "<1>", "自定义 label 应生效")

-- 从浮窗里跳转：应调用宿主的 to_editor
local float_buf = vim.api.nvim_create_buf(false, true)
local float_win = vim.api.nvim_open_win(float_buf, true, {
	relative = "editor",
	row = 2,
	col = 2,
	width = 10,
	height = 2,
	style = "minimal",
})
flow.jump(1)
check(editor_called, "从非编辑窗口跳转应调用 to_editor")
vim.api.nvim_win_close(float_win, true)
flow.clear()

print("ok: exec-flow 锚点/编号/跳转/面板/quickfix/配置符合预期")
