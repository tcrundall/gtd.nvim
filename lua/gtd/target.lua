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

return M
