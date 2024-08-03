MiniTest = require("mini.test") -- only here to supress Undefined global warnings

-- Define helper aliases
local new_set = MiniTest.new_set
local expect, eq, neq = MiniTest.expect, MiniTest.expect.equality, MiniTest.expect.no_equality

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
            child.lua([[M = require('gtd.target')]])
        end,
        -- This will be executed one after all tests from this set are finished
        post_once = child.stop,
    },
})

T["if action is tagged as targeted"] = new_set({
    parametrize = {
        { "action [◎]" },
        { "- [ ] action [◎]" },
        { "- [x] action ()[asdfasdf] [◎]" },
        { "[◎]" },
    },
})
T["if action is tagged as targeted"]["it is correctly identified"] = function(action_line)
    eq(child.lua_get("M.is_action_tagged_as_targeted(...)", { action_line }), true)
end
T["if action is tagged as targeted"]["does not gain tag when tagged"] = function(action_line)
    local result_line = child.lua_get("M.tag_action_as_targeted(...)", { action_line })
    eq(result_line, action_line)
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

return T
