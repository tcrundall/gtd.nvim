local helpers = require("gtd.helpers")
local random_tags = require("gtd.random_tags")
local sync = require("gtd.sync")

local M = {}

local TARGET_PATTERN = "%s*%[◎%]"
local TARGET_STR = "[◎]"

---@param line string
---@return boolean
M.is_action_tagged_as_targeted = function(line)
    local start_ix = line:find(TARGET_PATTERN)
    return start_ix ~= nil
end

---@param line string
---@return string
M.tag_action_as_targeted = function(line)
    if M.is_action_tagged_as_targeted(line) then
        return line
    end
    return table.concat({ line, TARGET_STR }, " ")
end

---@param line string
---@return string
M.untag_action_as_targeted = function(line)
    local start_ix, end_ix = line:find(TARGET_PATTERN)
    if start_ix == nil then
        return line
    end
    return line:sub(1, start_ix - 1) .. line:sub(end_ix + 1)
end

--- Tag an action as targeted and add to next-actions
M.target_action = function()
    local action_line = vim.api.nvim_get_current_line()

    if not helpers.is_action(action_line) then
        return "Not an action!"
    end

    local tag
    action_line, tag = random_tags.ensure_tagged(action_line)
    sync.add_to_next_actions(action_line, tag)
    action_line = M.tag_action_as_targeted(action_line)
    vim.api.nvim_set_current_line(action_line)
    return action_line
end

--- toggle an action as targeted or not (adding tag if missing)
M.toggle_target = function()
    local action_line = vim.api.nvim_get_current_line()

    if not helpers.is_action(action_line) then
        return "Not an action!"
    end

    local tag
    action_line, tag = random_tags.ensure_tagged(action_line)

    if M.is_action_tagged_as_targeted(action_line) then
        -- TODO: Remove from next actions
        -- sync.remove_from_next_actions(tag)
        action_line = M.untag_action_as_targeted(action_line)
    else
        sync.add_to_next_actions(action_line, tag)
        action_line = M.tag_action_as_targeted(action_line)
    end
    vim.api.nvim_set_current_line(action_line)
    return action_line
end

return M
