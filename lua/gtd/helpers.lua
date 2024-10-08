local M = {}

---@param line string
---@return boolean
M.is_action = function(line)
    return line:find("%s*- %[[ |x]%] ") == 1
end

---@param line string
---@return boolean
M.is_heading = function(line)
    return line:find("[#]+ ") == 1
end

---@param action_line string
---@return string
M.trim_action = function(action_line)
    local pattern = "%s*(- %[[x| ]%] .*)"
    local action_line_without_leading_whitespace = action_line:gmatch(pattern)()
    return M.remove_target(action_line_without_leading_whitespace)
end

---@param action_line string
---@return string
M.remove_target = function(action_line)
    local pattern = "[ ]?%[◎%]"
    local result = action_line:gsub(pattern, "")
    return result
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

-- -- in contents? in file? return position?
-- -- command exists already in nvim api?
-- -- in vim api, yes
-- M.is_action_in_contents = function(action_line, contents)
--     return
-- end

---@param filename string
---@return integer
M.ensure_buf_loaded = function(filename)
    local bufnr = vim.fn.bufadd(filename)
    vim.fn.bufload(filename)
    return bufnr
end

M.is_action_in_file = function(action, filename)
    local bufnr = M.ensure_buf_loaded(filename)
    local matches = vim.fn.matchbufline(bufnr, action, 1, "$")
    return #matches ~= 0
end

---@param filename string
---@param tag string
---@return boolean
M.is_tag_in_file = function(filename, tag)
    local bufnr = M.ensure_buf_loaded(filename)
    local matches = vim.fn.matchbufline(bufnr, ".*" .. tag .. ".*", 1, "$")
    return #matches ~= 0
end

---Get line number of first match. -1 indicates no match
---@param filename string
---@param tag string
---@return integer
M.get_first_location_of_tag_in_file = function(filename, tag)
    local bufnr = M.ensure_buf_loaded(filename)
    local matches = vim.fn.matchbufline(bufnr, ".*" .. tag .. ".*", 1, "$")
    if #matches == 0 then
        return -1
    end
    return matches[1].lnum
end

M.get_file_contents = function(filename)
    local bufnr = M.ensure_buf_loaded(filename)
    return vim.api.nvim_buf_get_lines(bufnr, 0, 10000, false)
end

-- -- local filename = "/Users/tcrundall/Coding/GtdPlugin/lua/gtd/random_tags.lua"
-- -- local filename = "lua/gtd/random_tags.lua"
-- -- local filename = "~/Coding/GtdPlugin/lua/gtd/helpers.lua"
-- local filename = "~/Coding/GtdPlugin/lua/gtd/random_tags.lua"
-- -- vim.api.nvim_buf_is_loaded
-- vim.fn.bufadd(filename)
-- vim.fn.bufload(filename)
-- local line = "--- Append a concealed random tag, if not already present"
-- -- local line = "Append.*"

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

M.write_all_files = function()
    local enter = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    vim.api.nvim_feedkeys(":wa" .. enter, "n", false)
end

---Get all locations of a tag. Requires ripgrep to be installed
---@param tag string
---@return table
M.get_all_locations_of_tag = function(tag)
    local notes_dir = "tests/resources/"
    local escaped_tag = tag
    escaped_tag = escaped_tag:gsub("%[", "\\[")
    escaped_tag = escaped_tag:gsub("%]", "\\]")
    escaped_tag = escaped_tag:gsub("%(", "\\(")
    escaped_tag = escaped_tag:gsub("%)", "\\)")
    local command = "!rg '" .. escaped_tag .. "' " .. notes_dir .. " -n"

    local rg_res = vim.fn.execute(command)
    local results_without_command = vim.fn.split(rg_res, "\r\n\n")[2]

    local tag_locations = {}
    for _, result in ipairs(vim.fn.split(results_without_command, "\n")) do
        result = vim.fn.split(result, ":")
        local location = {
            filename = result[1],
            line_number = tonumber(result[2]),
        }
        table.insert(tag_locations, location)
    end
    return tag_locations
end

return M
