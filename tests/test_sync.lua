MiniTest = require("mini.test") -- only here to supress Undefined global warnings

-- Define helper aliases
local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

-- Create (but not start) child Neovim object
local child = MiniTest.new_child_neovim()

-- Define main test set of this file
local T = new_set({
    -- Register hooks
    hooks = {
        -- This will be executed before every (even nested) case
        pre_case = function()
            -- Restart child process with custom 'init.lua' script
            child.restart({ "-u", "scripts/minimal_init.lua" })
            -- Load tested plugin
            child.lua([[M = require('gtd.sync')]])
        end,
        -- This will be executed one after all tests from this set are finished
        post_once = child.stop,
    },
})

T["identifying subheadings"] = new_set({
    parametrize = {
        { "### some heading", 1, true },
        { "### some heading", 2, true },
        { "##### some heading", 2, true },
        { "some heading", 2, false },
        { "### some heading", 4, false },
    },
})
T["identifying subheadings"]["works"] = function(heading, current_level, expected_result)
    eq(
        child.lua_get("M.is_subheading('" .. heading .. "', " .. current_level .. ")"),
        expected_result
    )
end

T["finding line"] = new_set({
    parametrize = {
        { [[{ "line 1", "line 2", "line 3" }]], "line 4", vim.NIL },
        { [[{}]], "line 1", vim.NIL },
        { [[{ "line 1", "line 2", "line 3" }]], "line 2", 2 },
        { [[{ "# line 1", "## line 2", "### line 3" }]], "[#]+ line 2", 2 },
    },
})
T["finding line"]["works"] = function(lines, target_line, expected_result)
    eq(child.lua_get("M.find_line(" .. lines .. ", '" .. target_line .. "')"), expected_result)
end

T["finding heading"] = new_set({
    parametrize = {
        { [[{"# line 1", "# line 2"}]], "line 4", vim.NIL },
        { [[{}]], "line 1", vim.NIL },
        { [[{"line 1", "### line 2", "line 3"}]], "line 2", 2 },
        { [[{"# line 1", "## line 2", "### line 3"}]], "line 2", 2 },
    },
})
T["finding heading"]["works"] = function(lines, target_heading, expected_result)
    eq(
        child.lua_get("M.find_heading(" .. lines .. ", '" .. target_heading .. "')"),
        expected_result
    )
end

T["adding to next actions"] =
    new_set({ parametrize = {
        { "Existing Context 1" },
        { "New Context 1" },
    } })

T["adding to next actions"]["works"] = function(context)
    child.o.lines, child.o.columns = 15, 50
    child.bo.readonly = false

    -- Arrange
    local action = "- [ ] New action 1"
    local filename = "./tests/resources/next-actions.md"
    local bufnr = child.lua_get("vim.fn.bufadd('" .. filename .. "')")

    -- Act
    child.lua("M.insert_action_into_next_actions(...)", { context, action, filename })

    -- Assert
    child.lua("vim.api.nvim_set_current_buf(...)", { bufnr })
    expect.reference_screenshot(child.get_screenshot())
end
T["adding to next actions"]["parent method works"] = function(context)
    child.o.lines, child.o.columns = 45, 50
    child.bo.readonly = false

    -- Arrange
    local tag = "[](syncnewt)"
    local action_line = "- [ ] New action 1" .. " " .. tag
    local lines = { "## " .. context, "", action_line }

    -- Arrange
    child.lua("vim.api.nvim_buf_set_lines(...)", { 0, 0, 1, false, lines })
    child.lua("vim.fn.cursor(3, 0)")

    -- Act
    child.lua("M.add_to_next_actions(...)", { action_line, tag })

    -- Assert
    local next_actions_file = child.lua_get("NEXT_ACTIONS_FILE")
    local bufnr = child.lua_get("vim.fn.bufadd('" .. next_actions_file .. "')")
    child.lua("vim.api.nvim_set_current_buf(...)", { bufnr })
    expect.reference_screenshot(child.get_screenshot())
end

return T
