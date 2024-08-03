local M = {}

---@param line string
---@return boolean
M.is_action_tagged_as_targeted = function(line)
    local target_pattern = "%[◎%]"
    local start_ix = line:find(target_pattern)
    return start_ix ~= nil
end

---@param line string
---@return string
M.tag_action_as_targeted = function(line)
    if M.is_action_tagged_as_targeted(line) then
        return line
    end
    local target_str = "[◎]"
    return table.concat({ line, target_str }, " ")
end

return M
