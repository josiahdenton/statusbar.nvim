local M = {}

M.setup = function()
    require("statusbar.segments.filepath").setup()
	require("statusbar.segments.git").setup()
	require("statusbar.segments.pager").setup()
	require("statusbar.segments.system").setup()
end

return M
