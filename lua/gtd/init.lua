-- Here for easy development
vim.cmd("set rtp+=" .. vim.fn.getcwd())
package.loaded["gtd.checkboxes"] = nil
package.loaded["gtd.sync"] = nil
package.loaded["gtd.random_tags"] = nil
package.loaded["gtd.target"] = nil
package.loaded["gtd.helpers"] = nil
--

local checkboxes = require("gtd.checkboxes")
local sync = require("gtd.sync")
local target = require("gtd.target")

local M = {}

M.setup = function() end

M.cycle_checkbox = checkboxes.cycle_checkbox
M.scrape_actions = sync.scrape_actions
M.target_action = target.target_action
M.untarget_action = target.untarget_action

vim.api.nvim_create_user_command("CycleCheckbox", function(opts)
    local bool_val = opts.fargs[1] == "true"
    M.cycle_checkbox(bool_val)
end, { nargs = "?" })

vim.api.nvim_create_user_command("GtdTargetAction", function()
    M.target_action()
end, {})

vim.api.nvim_create_user_command("GtdUntargetAction", function()
    M.untarget_action()
end, {})

return M
