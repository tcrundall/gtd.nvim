local M = {}

M.cycle_checkbox_format = function(current_checkbox_line)
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
            return new_line
        end
    end
end

M.cycle_checkbox = function()
    -- TODO: Add random (unique) tag at end
    local row_ix = vim.api.nvim_win_get_cursor(0)[1]
    local new_line = M.cycle_checkbox_format(vim.api.nvim_get_current_line())
    vim.api.nvim_buf_set_lines(0, row_ix - 1, row_ix, false, { new_line })
end

return M
