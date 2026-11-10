local M = {}

function M.check()
	local health = vim.health or require("vim.health")
	local start = health.start or health.report_start
	local ok = health.ok or health.report_ok
	local warn = health.warn or health.report_warn
	local info = health.info or health.report_info

	start("exec-flow.nvim")

	if vim.fn.has("nvim-0.10") == 1 then
		ok("Neovim >= 0.10")
	else
		warn("需要 Neovim >= 0.10（extmark virt_text / nvim_open_win）")
	end

	local loaded = package.loaded["exec_flow"]
	if loaded then
		ok("exec_flow 已加载")
		local cmds = loaded.opts and loaded.opts.commands or {}
		info(
			("命令：%s / %s / %s / %s"):format(
				cmds.add or "-",
				cmds.list or "-",
				cmds.clear or "-",
				cmds.qf or "-"
			)
		)
		local keys = loaded.opts and loaded.opts.keys
		if type(keys) == "table" then
			info("键位：由 setup({ keys = ... }) 注入")
		else
			info("键位：未注册（插件默认不抢键）")
		end
		if type(loaded.opts and loaded.opts.to_editor) == "function" then
			ok("使用宿主提供的 to_editor 回调")
		else
			info("使用内置编辑窗口落点逻辑")
		end
		local n = #loaded._anchors()
		info(("当前锚点数：%d（仅内存，退出即消失）"):format(n))
	else
		warn("exec_flow 未加载：请 require('exec_flow').setup()")
	end
end

return M
