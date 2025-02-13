local M = {}

local store = require("statusbar.store")

--- @return string
local file_path = function()
	local path = vim.fn.expand("%:.")
	local file = vim.fn.fnamemodify(path, ":t")
	if #file == 0 then
		return "󰏫 "
	end
	return file .. (vim.bo.modified and "  " or "")
end

M.setup = function()
	store.register_segment({
		name = "filepath",
		split = false,
		focused = function()
			return { { "", "StatusbarEdge" }, { file_path, "Statusbar" }, { "", "StatusbarEdge" } }
		end,
		default = function()
			return { { "", "StatusbarEdge" }, { file_path, "Statusbar" }, { "", "StatusbarEdge" } }
		end,
	})
end

return M
