local M = {}

local segments = require("statusbar.segments")
local store = require("statusbar.store")
local ui = require("statusbar.ui")

M.draw = function()
	store.tick()
	return ui.winbar(store.state())
end

local draw_loop = function()
	local timer = vim.uv.new_timer()
	timer:start(
		0,
		30000,
		vim.schedule_wrap(function()
			vim.cmd("redrawstatus")
		end)
	)
end

M.setup = function()
	segments.setup()
	vim.api.nvim_create_autocmd({ "VimEnter", "BufWinEnter" }, {
		group = vim.api.nvim_create_augroup("statusbar/winbar", { clear = true }),
		desc = "Attach winbar",
		callback = function(args)
			if
				not vim.api.nvim_win_get_config(0).zindex -- Not a floating window
				and vim.bo[args.buf].buftype == "" -- Normal buffer
				and not vim.wo[0].diff -- Not in diff mode
			then
				vim.o.showtabline = 0
				vim.wo.winbar = "%{%v:lua.require'statusbar.bar'.draw()%}"
			end
		end,
	})
	draw_loop()
end

return M
