MiniTest = require("mini.test") -- only here to supress Undefined global warnings

local new_set = MiniTest.new_set
local expect, eq, neq = MiniTest.expect, MiniTest.expect.equality, MiniTest.expect.no_equality
local not_implemented = function()
    eq("NOT IMPLEMENTED", nil)
end

local child = MiniTest.new_child_neovim()

local T = new_set({
    hooks = {
        pre_case = function()
            child.restart({ "-u", "scripts/minimal_init.lua" })
            child.lua([[M = require('gtd.target')]])
        end,
        post_once = child.stop,
    },
})

T["if action is tagged as targeted"] = new_set({
    parametrize = {
        { "action [◎]" },
        { "- [ ] action [◎]" },
        { "- [x] action ()[asdfasdf] [◎]" },
        { "[◎]" },
        { "[◎] action " },
    },
})
T["if action is tagged as targeted"]["it is correctly identified"] = function(action_line)
    eq(child.lua_get("M.is_action_tagged_as_targeted(...)", { action_line }), true)
end
T["if action is tagged as targeted"]["does not gain tag when tagged"] = function(action_line)
    local result_line = child.lua_get("M.tag_action_as_targeted(...)", { action_line })
    eq(result_line, action_line)
end
T["if action is tagged as targeted"]["it loses tag when untagged"] = function(action_line)
    local target_pattern = "%[◎%]"
    local result_line = child.lua_get("M.untag_action_as_targeted(...)", { action_line })
    local start_ix, _ = result_line:find(target_pattern)
    eq(start_ix, nil)
end

T["if action is not tagged as targeted"] = new_set({
    parametrize = {
        { "action " },
        { "- [ ] action " },
        { "- [x] action " },
        { "" },
    },
})
T["if action is not tagged as targeted"]["it is correctly identified"] = function(action_line)
    eq(child.lua_get("M.is_action_tagged_as_targeted(...)", { action_line }), false)
end
T["if action is not tagged as targeted"]["gains tag when tagged"] = function(action_line)
    local target_pattern = "%[◎%]"
    local result_line = child.lua_get("M.tag_action_as_targeted(...)", { action_line })
    local start_ix, end_ix = result_line:find(target_pattern)
    neq(start_ix, nil)
    eq(end_ix, #result_line)
end
T["if action is not tagged as targeted"]["it is unchanged when untagged"] = function(action_line)
    local result_line = child.lua_get("M.untag_action_as_targeted(...)", { action_line })
    eq(result_line, action_line)
end

T["targeting valid action"] = new_set({
    parametrize = {
        { "- [ ] targeted action [](targetd1)" },
        { "    - [ ] targeted action [](targetd2)" },
        { "- [ ] targeted action [](targetd3)" },
    },
})
T["targeting valid action"]["adds action to Next Actions"] = function(action_line)
    child.o.lines, child.o.columns = 25, 80
    child.bo.readonly = false

    local context = "## Existing Context 1"

    local lines = { context, "", action_line }

    -- Arrange
    child.lua("vim.api.nvim_buf_set_lines(...)", { 0, 0, 1, false, lines })
    child.lua("vim.fn.cursor(3, 0)")

    -- Act
    child.lua("M.target_action()")

    -- Assert
    local filename = "/Users/tcrundall/Coding/GtdPlugin/tests/resources/next-actions.md"
    local bufnr = child.lua_get("vim.fn.bufadd('" .. filename .. "')")
    child.lua("vim.api.nvim_set_current_buf(...)", { bufnr })
    expect.reference_screenshot(child.get_screenshot())
end

T["targeting valid action"]["tags action as targeted"] = function(action_line)
    child.o.lines, child.o.columns = 25, 80
    child.bo.readonly = false

    local lines = { action_line, action_line }

    -- Arrange
    child.lua("vim.api.nvim_buf_set_lines(...)", { 0, 0, 1, false, lines })
    child.lua("vim.fn.cursor(4, 0)")

    -- Act
    child.lua("M.target_action()")

    -- Assert
    local actual_line = child.lua_get("vim.api.nvim_buf_get_lines(0, 1, 2, false)")[1]
    local target_pattern = " %[◎%]"
    local start_ix, end_ix = actual_line:find(target_pattern)
    eq(start_ix, #action_line + 1)
    eq(end_ix, #actual_line)
    expect.reference_screenshot(child.get_screenshot())
end

T["targeting valid untagged action"] = new_set({
    parametrize = {
        { "- [ ] targeted action " },
        { "    - [ ] targeted action " },
        { "- [ ] targeted action " },
    },
})
T["targeting valid untagged action"]["adds id tag and target tag"] = function(action_line)
    child.o.lines, child.o.columns = 25, 80
    child.bo.readonly = false

    -- Arrange
    child.lua("vim.api.nvim_buf_set_lines(...)", { 0, 0, 1, false, { action_line, action_line } })
    child.lua("vim.fn.cursor(2, 0)")

    -- Act
    child.lua("M.target_action()")

    -- Assert
    local actual_line = child.lua_get("vim.api.nvim_buf_get_lines(0, 1, 2, false)")[1]
    local target_pattern = " %[◎%]"
    local id_tag_pattern = "%[%]%([%a%d]+%)"
    local target_tag_ix = actual_line:find(target_pattern)
    local id_tag_ix = actual_line:find(id_tag_pattern)

    neq(target_tag_ix, nil)
    neq(id_tag_ix, nil)
end

T["targeting invalid action"] = new_set({
    parametrize = {
        { "- targeted action " },
        { "    - [x] targeted action" },
        { "- [  ] targeted action" },
    },
})
T["targeting invalid action"]["does not change line"] = function(action_line)
    -- Arrange
    child.lua("vim.api.nvim_buf_set_lines(...)", { 0, 0, 1, false, { action_line } })
    child.lua("vim.fn.cursor(1, 0)")

    -- Act
    child.lua("M.target_action()")

    -- Assert
    local actual_line = child.lua_get("vim.api.nvim_buf_get_lines(0, 0, 1, false)")[1]
    eq(actual_line, action_line)
end
T["targeting invalid action"]["does not add to Next Actions"] = function(action_line)
    child.o.lines, child.o.columns = 25, 80

    -- Arrange
    child.lua("vim.api.nvim_buf_set_lines(...)", { 0, 0, 1, false, { action_line } })
    child.lua("vim.fn.cursor(1, 0)")

    -- Act
    child.lua("M.target_action()")

    -- Assert
    local filename = "/Users/tcrundall/Coding/GtdPlugin/tests/resources/next-actions.md"
    local bufnr = child.lua_get("vim.fn.bufadd('" .. filename .. "')")
    child.lua("vim.api.nvim_set_current_buf(...)", { bufnr })
    expect.reference_screenshot(child.get_screenshot())
end

T["targeting already targeted action"] = new_set({
    parametrize = {
        { "- [ ] targeted and missing from next actions [](targmiss) [◎]" },
        { "- [ ] untargeted and present in next actions [](ntarpres)" },
        { "- [ ] untargeted and missing in next actions [](ntarmiss)" },
        { "- [ ] targeted and present in next actions [](targpres) [◎]" },
        { "- [ ] oddly targeted [◎] and missing in next actions [](otarmiss)" },
    },
})
-- TODO: Check
-- - target is present
-- - tag is in next-actions
-- - no targets are in next-actions
T["targeting already targeted action"]["adds target if missing and adds to next actions"] = function(
    action_line
)
    child.o.lines, child.o.columns = 25, 80
    child.bo.readonly = false
    local lines = { "## Target Practice", "", action_line }
    local next_actions_file = "/Users/tcrundall/Coding/GtdPlugin/tests/resources/next-actions.md"

    -- Arrange
    child.lua("vim.api.nvim_buf_set_lines(...)", { 0, 0, 1, false, lines })
    child.lua("vim.fn.cursor(3, 0)")

    -- Act
    child.lua("M.target_action()")

    -- Assert
    local action_line_after = child.lua_get("vim.api.nvim_get_current_line()")
    eq(child.lua_get("M.is_action_tagged_as_targeted(...)", { action_line_after }), true)
    local bufnr = child.lua_get("vim.fn.bufadd(...)", { next_actions_file })
    child.lua("vim.api.nvim_set_current_buf(...)", { bufnr })
    expect.reference_screenshot(child.get_screenshot())
end

return T
