local M = {}

local line = require("statusbar.line")
local bar = require("statusbar.bar")

--- @class statusbar.Config
--- @field use_winbar boolean
--- @field use_statusline boolean

--- @type statusbar.Config
local default_config = {
	use_winbar = true,
	use_statusline = true,
}

--- @param opts ?statusbar.Config
M.setup = function(opts)
	opts = opts or default_config

	if opts.use_winbar ~= nil and opts.use_winbar then
		bar.setup()
	end

	if opts.use_statusline ~= nil and opts.use_statusline then
		line.setup()
	end
end

return M
