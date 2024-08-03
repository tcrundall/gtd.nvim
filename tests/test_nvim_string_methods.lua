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
        end,
        post_once = child.stop,
    },
})

T["gmatch behaviour in loop"] = function()
    local str = "# Context name"
    local pattern = "[#]+ (.*)"
    local expected_match = "Context name"

    for match in str:gmatch(pattern) do
        eq(expected_match, match)
    end
end

T["gmatch behaviour as call"] = function()
    local str = "# Context name"
    local pattern = "[#]+ (.*)"
    local expected_match = "Context name"
    local match = str:gmatch(pattern)()
    eq(expected_match, match)
end

return T
