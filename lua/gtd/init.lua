-- Here for easy development
vim.cmd("set rtp+=" .. vim.fn.getcwd())
package.loaded["gtd.checkboxes"] = nil
package.loaded["gtd.sync"] = nil
--

local checkboxes = require("gtd.checkboxes")
local sync = require("gtd.sync")

M = {}

M.setup = function() end

M.cycle_checkbox = checkboxes.cycle_checkbox
M.scrape_actions = sync.scrape_actions

vim.api.nvim_create_user_command("CycleCheckbox", function(opts)
    local bool_val = opts.fargs[1] == "true"
    M.cycle_checkbox(bool_val)
end, { nargs = 1 })

return M
