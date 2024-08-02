local M = {}

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

M.is_action = function(line)
    return line:find("%s*- %[ %] ") == 1
end

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
    return M.find_line(contents, "[#]+ " .. heading)
end

M.get_file_contents = function(filename)
    local bufnr = vim.fn.bufadd(filename)
    vim.fn.bufload(filename)
    local contents = vim.fn.getbufline(filename, 1, 100000)
    return contents, bufnr
end

M.add_to_next_actions = function(context, action, filename)
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
    -- P(table.unpack(contents, 1, 3))
    -- P(contents)
    -- local contents_after_organize = { unpack(contents, organize_row_ix + 1, #contents) }
    local contents_after_organize = vim.list_slice(contents, organize_row_ix + 1)
    local next_heading_row_ix = #contents
    for row_offset, row in ipairs(contents_after_organize) do
        if vim.startswith(row, ("#"):rep(heading_level) .. " ") then
            next_heading_row_ix = organize_row_ix + row_offset
        end
    end

    local tasks_block = vim.fn.getbufline(filename, organize_row_ix, next_heading_row_ix - 1)
    P(tasks_block)

    local contexts = {}
    -- vim.list_extend(contexts, { 1 })
    P(contexts)

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
    P(contexts)
    print(contexts["Another context"])
    print(contexts["Packing list"])

    for context, row_ix in pairs(contexts) do
        print("In context ", context)
        local target_row_ix = row_ix + 1
        -- print("Looking at ", contents[target_row_ix])
        while
            contents[target_row_ix] ~= nil
            and not M.is_action(contents[target_row_ix])
            and not M.is_subheading(contents[target_row_ix], heading_level)
        do
            target_row_ix = target_row_ix + 1
            -- print("Looking at ", contents[target_row_ix])
        end
        local row = contents[target_row_ix]
        if row ~= nil and M.is_action(row) then
            print("Found next action:", row)
            M.add_to_next_actions(context, row)
        end
    end
end

return M
