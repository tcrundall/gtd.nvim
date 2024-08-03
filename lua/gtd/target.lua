local helpers = require("gtd.helpers")
local random_tags = require("gtd.random_tags")
local sync = require("gtd.sync")

local M = {}

local TARGET_PATTERN = "%[◎%]"
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

M.target_action = function()
    local action_line = vim.api.nvim_get_current_line()

    if not helpers.is_action(action_line) then
        return "Not an action!"
    end

    action_line = random_tags.ensure_tagged(action_line)

    local line_number = vim.fn.line(".")
    line_number = line_number - 1

    local default_context = "Miscellaneous"
    local context = helpers.get_nearest_heading(0, line_number)
    context = context or default_context

    -- TODO: use configuration for next-action file path
    local filename = "/Users/tcrundall/Coding/GtdPlugin/tests/resources/next-actions.md"
    sync.add_to_next_actions(context, helpers.strip_action(action_line), filename)

    action_line = M.tag_action_as_targeted(action_line)
    vim.api.nvim_set_current_line(action_line)
    return action_line
end

return M
