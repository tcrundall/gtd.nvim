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
        { "- [x] action", false },
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

T["stripping actions"] = new_set({
    parametrize = {
        { "- [ ] unchecked action", "- [ ] unchecked action" },
        { "- [ ] tagged action [asdfasdf]()", "- [ ] tagged action [asdfasdf]()" },
        { "- [x] checked action", "- [x] checked action" },
        { "   - [x] indented action", "- [x] indented action" },
    },
})
T["stripping actions"]["works"] = function(raw_action, trimmed_action)
    eq(child.lua_get("M.strip_action(...)", { raw_action }), trimmed_action)
end

return T
