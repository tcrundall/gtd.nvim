local M = {}

---@param line string
---@return boolean
M.is_action = function(line)
    return line:find("%s*- %[ %] ") == 1
end

---@param line string
---@return boolean
M.is_heading = function(line)
    return line:find("[#]+ ") == 1
end

---@param action_line string
---@return string
M.strip_action = function(action_line)
    local pattern = "%s*(- %[[x| ]%] .*)"
    return action_line:gmatch(pattern)()
end

---@param bufnr integer
---@param line_number integer
---@return string | nil
M.get_nearest_heading = function(bufnr, line_number)
    local res = nil
    line_number = line_number - 1
    while line_number >= 0 do
        local line = vim.api.nvim_buf_get_lines(bufnr, line_number, line_number + 1, true)[1]
        -- return line
        if M.is_heading(line) then
            -- TODO: Match for heading name
            local pattern = "[#]+ (.*)"
            res = line:gmatch(pattern)()
            break
        end
        line_number = line_number - 1
    end
    return res
end

-- in contents? in file? return position?
-- command exists already in nvim api?
-- in vim api, yes
M.is_action_in_contents = function(action_line, contents)
    return
end

M.ensure_buf_loaded = function(filename)
    vim.fn.bufadd(filename)
    vim.fn.bufload(filename)
end

M.is_action_in_file = function(action, filename)
    M.ensure_buf_loaded(filename)
    local matches = vim.fn.matchbufline(filename, action, 1, "$")
    return #matches ~= 0
end

-- local filename = "/Users/tcrundall/Coding/GtdPlugin/lua/gtd/random_tags.lua"
-- local filename = "lua/gtd/random_tags.lua"
-- local filename = "~/Coding/GtdPlugin/lua/gtd/helpers.lua"
local filename = "~/Coding/GtdPlugin/lua/gtd/random_tags.lua"
-- vim.api.nvim_buf_is_loaded
vim.fn.bufadd(filename)
vim.fn.bufload(filename)
local line = "--- Append a concealed random tag, if not already present"
-- local line = "Append.*"

M.TOC = function()
    -- local target_dir = vim.fn.fnamemodify(test_filename, ":p:h")
    local target_dir = vim.fn.expand("%:p:h")
    local filenames = vim.fn.readdir(target_dir)

    vim.api.nvim_buf_set_lines(0, 2, -1, false, {})
    local toc_start_line = 2
    local toc_entries = {}
    for _, filename in ipairs(filenames) do
        if filename ~= "_index.md" then
            local short_filename = vim.fn.fnamemodify(filename, ":r")
            local toc_entry = "- [" .. short_filename .. "](./" .. filename .. ")"
            table.insert(toc_entries, toc_entry)
        end
    end
    vim.api.nvim_buf_set_lines(0, toc_start_line, toc_start_line + #toc_entries, false, toc_entries)
end

return M
