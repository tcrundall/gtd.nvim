local helpers = require("gtd.helpers")

local M = {}

local NEXT_ACTIONS_FILE = "/Users/tcrundall/Coding/GtdPlugin/tests/resources/next-actions.md"

M.is_subheading = function(line, level)
    local heading_prefix = ("#"):rep(level + 1)
    return vim.startswith(line, heading_prefix)
end

M.find_line = function(contents, pattern)
    for row_ix, row in ipairs(contents) do
        local match = string.match(row, pattern)
        if match ~= nil then
            return row_ix
        end
    end
    return nil
end

M.find_heading = function(contents, heading)
    -- TODO: Make resilient to special characters
    -- e.g. "-"
    return M.find_line(contents, "[#]+ " .. heading)
end

M.get_file_contents = function(filename)
    local bufnr = vim.fn.bufadd(filename)
    vim.fn.bufload(filename)
    local contents = vim.fn.getbufline(filename, 1, 100000)
    return contents, bufnr
end

---Remove action corresponding to tag from next action file (if present)
---@param tag string
M.remove_from_next_actions = function(tag)
    if not helpers.is_tag_in_file(NEXT_ACTIONS_FILE, tag) then
        print("Action was not in ", NEXT_ACTIONS_FILE, ". Out of sync?")
    else
        local line_number = helpers.get_first_location_of_tag_in_file(NEXT_ACTIONS_FILE, tag)
        if line_number < 0 then
            print("Could not locate action in next actions file")
        end
        M.remove_line_from_next_actions(line_number, NEXT_ACTIONS_FILE)
    end
end

---Add current action line to next action file (if not present)
---TODO: Remove targets before adding to next-actions
---@param action_line string
---@param tag string
M.add_to_next_actions = function(action_line, tag)
    if helpers.is_tag_in_file(NEXT_ACTIONS_FILE, tag) then
        print("Action is already in ", NEXT_ACTIONS_FILE, ". Out of sync?")
    else
        local line_number = vim.fn.line(".")
        line_number = line_number - 1

        local default_context = "Miscellaneous"
        local context = helpers.get_nearest_heading(0, line_number)
        context = context or default_context

        M.insert_action_into_next_actions(
            context,
            helpers.trim_action(action_line),
            NEXT_ACTIONS_FILE
        )
    end
end

---Insert a given action into next action file, under the subheading
---corresponding to the provided context.
---@param context string
---@param action string
---@param filename string
M.insert_action_into_next_actions = function(context, action, filename)
    -- TODO: Improve by making case insensitive
    filename = filename or "./next-actions.md"
    local contents, bufnr = M.get_file_contents(filename)

    local context_row_ix = M.find_heading(contents, context)
    if context_row_ix == nil then
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "", "## " .. context, "" })
        context_row_ix = 1000000000
    end
    vim.api.nvim_buf_set_lines(bufnr, context_row_ix + 1, context_row_ix + 1, false, { action })
end

---Remove a given line from next actions file
---@param line_number integer
---@param filename string
M.remove_line_from_next_actions = function(line_number, filename)
    -- TODO: Improve by making case insensitive
    filename = filename or "./next-actions.md"
    local bufnr = vim.fn.bufadd(filename)
    vim.fn.bufload(filename)

    vim.api.nvim_buf_set_lines(bufnr, line_number - 1, line_number, false, {})
end

M.scrape_actions = function()
    -- TODO: Cycle through each file under projects
    -- TODO: Find subheading "Organize"
    -- TODO: Extract all text between it and next heading of same level
    -- Assuming single level lists?
    -- TODO: For each subheading, duplicate first checkbox into NextActions file
    -- under same subheading (creating if needed)

    -- Later improvements:
    -- - [ ] handle nested lists

    local filename = "projects/archive/amsterdam-trip.md"
    local contents = M.get_file_contents(filename)

    local heading_text_pattern = "[#]+ Organi[s|z]e"
    local organize_row_ix, heading_level
    for row_ix, row in ipairs(contents) do
        if row:match(heading_text_pattern) then
            organize_row_ix = row_ix
            heading_level = #row:match("[#]+")
        end
    end
    -- local contents_after_organize = { unpack(contents, organize_row_ix + 1, #contents) }
    local contents_after_organize = vim.list_slice(contents, organize_row_ix + 1)
    local next_heading_row_ix = #contents
    for row_offset, row in ipairs(contents_after_organize) do
        if vim.startswith(row, ("#"):rep(heading_level) .. " ") then
            next_heading_row_ix = organize_row_ix + row_offset
        end
    end

    local tasks_block = vim.fn.getbufline(filename, organize_row_ix, next_heading_row_ix - 1)

    local contexts = {}
    -- vim.list_extend(contexts, { 1 })

    local heading_prefix = ("#"):rep(heading_level + 1) .. " "
    for row_offset, row in ipairs(tasks_block) do
        if vim.startswith(row, heading_prefix) then
            print("Found a context: ", row)
            local context = row:sub(heading_level + 3)
            print(context)

            contexts =
                vim.tbl_extend("error", contexts, { [context] = row_offset + organize_row_ix - 1 })
        end
    end
    print(contexts["Another context"])
    print(contexts["Packing list"])

    for context, row_ix in pairs(contexts) do
        print("In context ", context)
        local target_row_ix = row_ix + 1
        -- print("Looking at ", contents[target_row_ix])
        while
            contents[target_row_ix] ~= nil
            and not helpers.is_action(contents[target_row_ix])
            and not M.is_subheading(contents[target_row_ix], heading_level)
        do
            target_row_ix = target_row_ix + 1
            -- print("Looking at ", contents[target_row_ix])
        end
        local row = contents[target_row_ix]
        if row ~= nil and helpers.is_action(row) then
            print("Found next action:", row)
            M.insert_action_into_next_actions(context, row, NEXT_ACTIONS_FILE)
        end
    end
end

return M
