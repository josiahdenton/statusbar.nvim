local M = {}

local store = require("statusbar.store")
--- we only update drift every 30 seconds
local DRIFT_CACHE_UPDATE_TIME = 30000
local cache = {
	branch = nil,
	stat = nil,
	drift = { origin = 0, head = 0 }, -- from
}
local valid = {
	branch = false,
	stat = false,
	drift = false,
}

--- fetches the drift between this branch and origin
--- @return string
local drift = function()
	if cache.branch == "(unknown)" or not cache.branch then
		return ""
	end

	if not valid.drift then
		vim.system(
			{ "git", "rev-list", "--count", string.format("HEAD..origin/%s", cache.branch) },
			{ text = true },
			function(out)
				if out.stdout and out.stdout ~= "" then
					cache.drift.origin = tonumber(vim.trim(out.stdout))
				end
				valid.drift = true
			end
		)
		vim.system(
			{ "git", "rev-list", "--count", string.format("origin/%s..HEAD", cache.branch) },
			{ text = true },
			function(out)
				if out.stdout and out.stdout ~= "" then
					cache.drift.head = tonumber(vim.trim(out.stdout))
				end
				valid.drift = true
			end
		)
	end

	return " "
		.. (cache.drift.head == 0 and "" or string.format(" [%d] ", cache.drift.head))
		.. (cache.drift.origin == 0 and "" or string.format(" [%d] ", cache.drift.origin))
end

local branch = function()
	if cache.branch and valid.branch then
		return "  " .. cache.branch
	end

	vim.system({ "git", "branch", "--show-current" }, { text = true }, function(out)
		if out.stdout and out.stdout ~= "" then
			cache.branch = string.gsub(out.stdout, "%s+", "")
		else
			cache.branch = "(unknown)"
		end
		valid.branch = true
	end)
	return cache.branch and ("  " .. cache.branch) or ""
end

--- @alias tabby.ChangeType "file"|"ins"|"del"

--- @type table<tabby.ChangeType, string>
local symbols = {
	file = "",
	ins = "",
	del = "",
}

--- @return tabby.ChangeType|nil,string|nil
local change_symbol = function(change)
	if string.find(change, "file") then
		return symbols.file, "markdownUrl"
	elseif string.find(change, "ins") then
		return symbols.ins, "DiagnosticOk"
	elseif string.find(change, "del") then
		return symbols.del, "DiagnosticError"
	end
end

--- @return table<table<string>>
local stat = function()
	if cache.stat and valid.stat then
		return cache.stat
	end

	vim.system({ "git", "diff", "--stat" }, { text = true }, function(out)
		if #out.stdout > 0 then
			local lines = vim.split(out.stdout, "\n", { trimempty = true })
			local changes = lines[#lines]
			if changes and #changes > 0 then
				local changes_by_type = vim.split(changes, ",", { trimempty = true })
				local content = {}
				local total = 0
				for _, change in ipairs(changes_by_type) do
					local amount = string.match(change, "%d+")
					total = total + tonumber(vim.trim(amount))
					local symbol, hg = change_symbol(change)
					table.insert(content, { " ", "Comment" })
					table.insert(content, { amount, "Comment" })
					table.insert(content, { " ", "Comment" })
					table.insert(content, { symbol, hg })
					table.insert(content, { " ", "Comment" })
				end
				if total > 0 then
					cache.stat = content
				else
					cache.stat = {}
				end
			end
		else
			cache.stat = {}
		end
		valid.stat = true
	end)
	return cache.stat or {}
end

-- TODO: don't show stat unless there is enough room

M.setup = function()
	store.register_segment({
		name = "git",
		split = false,
		focused = function()
			return { { branch, "MiniIconsGreen" }, { drift, "Comment" }, unpack(stat()) }
		end,
		default = function()
			return { { branch, "MiniIconsGreen" }, { drift, "Comment" }, unpack(stat()) }
		end,
	})

	local group = vim.api.nvim_create_augroup("hacked.git.refresh", { clear = true })

	vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained", "BufEnter", "BufLeave" }, {
		group = group,
		callback = vim.schedule_wrap(function()
			valid.branch = false
			valid.drift = false
		end),
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "MiniGitCommandDone",
		group = group,
		callback = vim.schedule_wrap(function()
			valid.branch = false
			valid.drift = false
			valid.stat = false
		end),
	})

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
		group = group,
		callback = vim.schedule_wrap(function()
			valid.stat = false
		end),
	})

	local timer = vim.uv.new_timer()
	timer:start(
		DRIFT_CACHE_UPDATE_TIME,
		DRIFT_CACHE_UPDATE_TIME,
		vim.schedule_wrap(function()
			valid.drift = false
		end)
	)
end

return M
