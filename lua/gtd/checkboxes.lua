-- local random_tags = require("gtd.random_tags")
local random_tags = require("gtd.random_tags")
local helpers = require("gtd.helpers")

local M = {}
local UNCHECKED_BOX_PATTERN = "- %[ %]"
local CHECKED_BOX_PATTERN = "- %[x%]"

M.cycle_checkbox_format = function(current_checkbox_line, tagged)
    tagged = tagged or false
    local states = {
        "checked_box",
        "unchecked_box",
        "no_box",
        "no_anything",
    }
    local patterns = {
        checked_box = "- %[x%] *",
        unchecked_box = "- %[ %] *",
        no_box = "- ",
        no_anything = "[ ]*",
    }
    local replacements = {
        checked_box = "- ",
        unchecked_box = "- [x] ",
        no_box = "- [ ] ",
        no_anything = "- [ ] ",
    }

    for _, state in ipairs(states) do
        local start_ix, end_ix = current_checkbox_line:find(patterns[state])
        if start_ix ~= nil and end_ix ~= nil then
            local new_line = current_checkbox_line:sub(1, start_ix - 1)
                .. replacements[state]
                .. current_checkbox_line:sub(end_ix + 1)
            if tagged then
                new_line = random_tags.ensure_tagged(new_line)
            end
            return new_line
        end
    end
end

M.cycle_checkbox = function(tagged)
    tagged = tagged or false
    local row_ix = vim.api.nvim_win_get_cursor(0)[1]
    local new_line = M.cycle_checkbox_format(vim.api.nvim_get_current_line(), tagged)
    vim.api.nvim_buf_set_lines(0, row_ix - 1, row_ix, false, { new_line })
    vim.api.nvim_win_set_cursor(0, { row_ix, 999 })
end

M.is_action_checked = function()
    local line = vim.api.nvim_get_current_line()
    return line:match(CHECKED_BOX_PATTERN) ~= nil
end

---@param action_line string
M.check_action_line = function(action_line)
    return action_line:gsub(UNCHECKED_BOX_PATTERN, "- [x]")
end

---@param action_line string
M.uncheck_action_line = function(action_line)
    return action_line:gsub(CHECKED_BOX_PATTERN, "- [ ]")
end

M.check_action_at_location = function(tag_location)
    local bufnr = helpers.ensure_buf_loaded(tag_location.filename)
    local lines = vim.api.nvim_buf_get_lines(
        bufnr,
        tag_location.line_number - 1,
        tag_location.line_number,
        true
    )
    local checked_action_line = M.check_action_line(lines[1])
    vim.api.nvim_buf_set_lines(
        bufnr,
        tag_location.line_number - 1,
        tag_location.line_number,
        true,
        { checked_action_line }
    )
end

M.uncheck_action_at_location = function(tag_location)
    local bufnr = helpers.ensure_buf_loaded(tag_location.filename)
    local lines = vim.api.nvim_buf_get_lines(
        bufnr,
        tag_location.line_number - 1,
        tag_location.line_number,
        true
    )
    local unchecked_action_line = M.uncheck_action_line(lines[1])
    vim.api.nvim_buf_set_lines(
        bufnr,
        tag_location.line_number - 1,
        tag_location.line_number,
        true,
        { unchecked_action_line }
    )
end

M.check_action_from_tag = function(tag)
    local all_tag_locations = helpers.get_all_locations_of_tag(tag)
    for _, tag_location in ipairs(all_tag_locations) do
        M.check_action_at_location(tag_location)
    end
end

M.uncheck_action_from_tag = function(tag)
    local all_tag_locations = helpers.get_all_locations_of_tag(tag)
    for _, tag_location in ipairs(all_tag_locations) do
        M.uncheck_action_at_location(tag_location)
    end
end

M.check_action = function()
    local line = vim.api.nvim_get_current_line()
    local tag = random_tags.get_tag(line)
    M.check_action_from_tag(tag)
end

M.uncheck_action = function()
    local line = vim.api.nvim_get_current_line()
    local tag = random_tags.get_tag(line)
    M.uncheck_action_from_tag(tag)
end

M.toggle_action_check = function(tag) end

return M
