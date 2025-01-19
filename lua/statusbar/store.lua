local M = {}

--- @class statusbar.State
--- @field content table<statusbar.Content>
--- @field focused string printer currently in focus
--- @field segments table<statusbar.FieldName, statusbar.Segment> table of available printers

--- @alias statusbar.FieldName "default"|"player"|"git"|"filepath"|"stats"|"pager"|"system"

--- @class statusbar.Content
--- @field display table<table<string>>
--- @field split_next boolean

--- @class statusbar.Segment
--- @field name statusbar.FieldName
--- @field split boolean
--- @field focused fun(): table<table<string>>
--- @field default fun(): table<table<string>>

--- @return statusbar.State
local default_state = function()
    return {
        content = {},
        focused = "default",
        segments = {},
    }
end

--- @type statusbar.State
local state = default_state()

--- @return statusbar.State
M.state = function()
    return state
end

--- adds a new statusbar segment
--- @param segment statusbar.Segment
M.register_segment = function(segment)
    table.insert(state.segments, segment)
end

--- @param name statusbar.FieldName
M.focus_on = function(name)
    state.focused = name
end

--- update state, will run before ui.render
M.tick = function()
    if state.focused == "default" then
        local content = {}
        for _, segment in ipairs(state.segments) do
            table.insert(content, { display = segment.default(), split_next = segment.split })
        end
        state.content = content
    else
        local segment = state.segments[state.focused]
        state.content = { { display = segment.focused(), split_next = segment.split } }
    end
end

return M
