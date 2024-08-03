local M = {}

---@param line string
---@return boolean
M.is_action_tagged_as_targeted = function(line)
    local target_pattern = "%[◎%]"
    local start_ix = line:find(target_pattern)
    return start_ix ~= nil
end

return M
