local new_set = MiniTest.new_set
local expect, eq, neq = MiniTest.expect, MiniTest.expect.equality, MiniTest.expect.no_equality

local child = MiniTest.new_child_neovim()

local T = new_set({
    hooks = {
        pre_case = function()
            child.restart({ "-u", "scripts/minimal_init.lua" })
            child.lua([[M = require('gtd.config')]])
            child.lua([[M.is_initialized = false]])
        end,
        post_once = child.stop,
    },
})

T["initializing config works"] = function()
    -- arrange
    local user_opts = {
        notes_dir = "~/example-dir/",
        next_actions_file = "~/example-dir/next-actions.md",
    }

    -- act
    child.lua("M.setup(...)", { user_opts })

    -- assert
    eq(child.lua_get("M.opts.notes_dir"), user_opts.notes_dir)
    eq(child.lua_get("M.opts.next_actions_file"), user_opts.next_actions_file)
end

T["setting up with empty opts yields defaults"] = function()
    -- arrange
    local user_opts = {}

    -- act
    child.lua("M.setup(...)", { user_opts })

    -- assert
    eq(child.lua_get("M.opts.notes_dir"), child.lua_get("M.default_opts.notes_dir"))
    eq(child.lua_get("M.opts.next_actions_file"), child.lua_get("M.default_opts.next_actions_file"))
end

T["minimal_init worked"] = function()
    -- assert
    eq(child.lua_get("M.opts.notes_dir"), "tests/resources/")
    eq(child.lua_get("M.opts.next_actions_file"), "tests/resources/next-actions.md")
end

return T
