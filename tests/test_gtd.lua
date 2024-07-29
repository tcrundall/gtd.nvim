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
            child.lua([[M = require('gtd')]])
        end,
        -- This will be executed one after all tests from this set are finished
        post_once = child.stop,
    },
})

T["is_action is correct"] = function()
    eq(child.lua_get([[M.is_action("- [ ] action")]]), true)
    eq(child.lua_get([[M.is_action("- [ ] ")]]), true)
    eq(child.lua_get([[M.is_action("- [ ]")]]), false)
    eq(child.lua_get([[M.is_action("- [x] action")]]), false)
    eq(child.lua_get([[M.is_action("")]]), false)
end

T["is_subheading is correct"] = function()
    eq(child.lua_get([[M.is_subheading("### some heading", 1)]]), true)
    eq(child.lua_get([[M.is_subheading("### some heading", 2)]]), true)
    eq(child.lua_get([[M.is_subheading("##### some heading", 2)]]), true)

    eq(child.lua_get([[M.is_subheading("some heading", 2)]]), false)
    eq(child.lua_get([[M.is_subheading("### some heading", 4)]]), false)
end

T["find_line is correct"] = function()
    eq(child.lua_get([[M.find_line({"line 1", "line 2", "line 3"}, "line 4")]]), vim.NIL)
    eq(child.lua_get([[M.find_line({}, "line 1")]]), vim.NIL)
    eq(child.lua_get([[M.find_line({"line 1", "line 2", "line 3"}, "line 2")]]), 2)
    eq(child.lua_get([[M.find_line({"# line 1", "## line 2", "### line 3"}, "[#]+ line 2")]]), 2)
end

T["find_heading is correct"] = function()
    eq(child.lua_get([[M.find_heading({"# line 1", "# line 2"}, "line 4")]]), vim.NIL)
    eq(child.lua_get([[M.find_heading({}, "line 1")]]), vim.NIL)
    eq(child.lua_get([[M.find_heading({"line 1", "### line 2", "line 3"}, "line 2")]]), 2)
    eq(child.lua_get([[M.find_heading({"# line 1", "## line 2", "### line 3"}, "line 2")]]), 2)
end

return T
