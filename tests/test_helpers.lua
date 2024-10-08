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
            child.lua([[M = require('gtd.helpers')]])
        end,
        post_once = child.stop,
    },
})

T["identifying valid actions"] = new_set({
    parametrize = {
        { "- [ ] action", true },
        { "- [ ] ", true },
        { "- [ ]", false },
        { "- [x] action", true },
        { "", false },
    },
})
T["identifying valid actions"]["works"] = function(action_str, result)
    eq(child.lua_get("M.is_action('" .. action_str .. "')"), result)
end

T["identifying valid headings"] = new_set({
    parametrize = {
        { "# Heading", true },
        { "### Another heading", true },
        { "Not a heading", false },
        { "- # still not a heading", false },
        { "#Also not a heading", false },
        { " #Also not a heading", false },
    },
})
T["identifying valid headings"]["works"] = function(heading_str, result)
    eq(child.lua_get("M.is_heading(...)", { heading_str }), result)
end

T["identifying nearest heading"] = new_set({
    parametrize = {
        { "# Heading", "Heading" },
        { "### Sub heading", "Sub heading" },
        { "", vim.NIL },
    },
})
T["identifying nearest heading"]["works"] = function(heading_line, heading_str)
    child.bo.readonly = false

    local lines = { heading_line, "line 2", "line 3" }
    local bufnr = 0

    -- Arrange
    child.lua("vim.api.nvim_buf_set_lines(...)", { bufnr, 0, 1, false, lines })

    -- Act
    eq(child.lua_get("M.get_nearest_heading(...)", { bufnr, 3 }), heading_str)
end

T["trimming actions"] = new_set({
    parametrize = {
        { "- [ ] unchecked action", "- [ ] unchecked action" },
        { "- [ ] tagged action [asdfasdf]()", "- [ ] tagged action [asdfasdf]()" },
        { "- [x] checked action", "- [x] checked action" },
        { "   - [x] indented action", "- [x] indented action" },
    },
})
T["trimming actions"]["works"] = function(raw_action, trimmed_action)
    eq(child.lua_get("M.trim_action(...)", { raw_action }), trimmed_action)
end

T["checking for id in file"] = new_set({
    parametrize = {
        { "asdfasdf", true },
        { "abcdefg", true },
        { "ASDFASDF", true },
        { "12341234", false },
    },
})
T["checking for id in file"]["works"] = function(tag, is_present)
    -- arrange
    local filename = "/Users/tcrundall/Coding/GtdPlugin/tests/resources/next-actions.md"

    -- act & assert
    eq(child.lua_get("M.is_tag_in_file(...)", { filename, tag }), is_present)
end

T["removing target"] = new_set({
    parametrize = {
        { "target at end [◎]", "target at end" },
        { "[◎] target at start", " target at start" },
        { "target [◎] in middle", "target in middle" },
        { "no target at all", "no target at all" },
    },
})
T["removing target"]["works"] = function(raw_action, targetless_action)
    eq(child.lua_get("M.remove_target(...)", { raw_action }), targetless_action)
end

return T
