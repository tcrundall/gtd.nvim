MiniTest = require("mini.test") -- only here to supress Undefined global warnings

local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

-- Create (but not start) child Neovim object
local child = MiniTest.new_child_neovim()

-- Define main test set of this file
local T = new_set({
    hooks = {
        pre_case = function()
            child.restart({ "-u", "scripts/minimal_init.lua" })
            child.lua([[M = require('gtd.checkboxes')]])
        end,
        -- This will be executed one after all tests from this set are finished
        post_once = child.stop,
    },
})

local test_name = "getting next checkbox format in cycle"
T[test_name] = new_set({
    parametrize = {
        { "", "- [ ] " },
        { " ", "- [ ] " },
        { "Some text", "- [ ] Some text" },
        { "   Some text", "- [ ] Some text" },

        { "- ", "- [ ] " },
        { "   - ", "   - [ ] " },
        { "- Some text", "- [ ] Some text" },
        { "    - Some text", "    - [ ] Some text" },

        { "- [ ]", "- [x] " },
        { "- [ ] ", "- [x] " },
        { "- [ ] Some text", "- [x] Some text" },
        { "  - [ ] Some text", "  - [x] Some text" },

        { "- [x]", "- " },
        { "- [x] ", "- " },
        { "- [x] Some text", "- Some text" },
        { "     - [x] ", "     - " },
    },
})
T[test_name]["works"] = function(current_checkbox, expected_next)
    eq(child.lua_get("M.cycle_checkbox_format('" .. current_checkbox .. "')"), expected_next)
end

T[test_name]["integrated"] = function(current_checkbox, expected_next)
    -- arrange
    child.o.lines, child.o.columns = 15, 50
    child.bo.readonly = false
    local initial_lines = { "# Original", current_checkbox, "# Afer cycle", current_checkbox }
    child.lua("vim.api.nvim_buf_set_lines(...)", { 0, 0, 1, false, initial_lines })
    child.lua("vim.fn.cursor(4, 0)")

    -- act
    child.lua("M.cycle_checkbox()")

    -- assert
    eq(child.lua_get("vim.api.nvim_buf_get_lines(0, 0, 4, false)")[4], expected_next)
    expect.reference_screenshot(child.get_screenshot())
end

return T
