MiniTest = require("mini.test") -- only here to supress Undefined global warnings
-- local random_tags = require("gtd.random_tags")

local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

-- Create (but not start) child Neovim object
local child = MiniTest.new_child_neovim()

-- Define main test set of this file
local T = new_set({
    hooks = {
        pre_case = function()
            child.restart({ "-u", "scripts/minimal_init.lua" })
            child.lua([[M = require('gtd.random_tags')]])
        end,
        -- This will be executed one after all tests from this set are finished
        post_once = child.stop,
    },
})

T["digit converter"] = new_set({
    parametrize = {
        { 0, "0" },
        { 9, "9" },
        { 10, "a" },
        { 35, "z" },
        { 36, "A" },
        { 37, "B" },
        { 61, "Z" },
    },
})
T["digit converter"]["works"] = function(input_value, expected_char)
    eq(child.lua_get("M.map_base_62_digit_to_char(" .. input_value .. ")"), expected_char)
end

local function helper_base62_to_base10(digits)
    local unit, res = 1, 0
    for i = #digits, 1, -1 do
        res = res + unit * digits[i]
        unit = unit * 62
    end
    return res
end

T["base62 converter"] = new_set({
    parametrize = {
        { { 1, 50, 20 } },
        { { 5, 2, 3 } },
        { { 52, 10, 7 } },
        { { 52, 10, 0 } },
        { { 10, 0 } },
    },
})
T["base62 converter"]["works"] = function(expected_digits)
    local base10 = helper_base62_to_base10(expected_digits)
    eq(child.lua_get("M.base10_to_base62(" .. base10 .. ")"), expected_digits)
end

T["randomly generated tags"] = new_set({
    parametrize = {
        { 0, "NrGFqQvM" },
        { 1, "kKEoxS9l" },
        { 2, "vmky8DK6" },
    },
})
T["randomly generated tags"]["are random"] = function(rng_seed, expected_tag)
    child.lua("math.randomseed(...)", { rng_seed })
    eq(child.lua_get("M.generate_random_tag()"), expected_tag)
end

T["randomly generated tags are of length 8"] = function()
    for _ = 1, 10000, 1 do
        eq(#child.lua_get("M.generate_random_tag()"), 8)
    end
end

return T
