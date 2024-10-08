-- Here for easy development
vim.cmd("set rtp+=" .. vim.fn.getcwd())
package.loaded["gtd.checkboxes"] = nil
package.loaded["gtd.sync"] = nil
package.loaded["gtd.random_tags"] = nil
package.loaded["gtd.target"] = nil
package.loaded["gtd.helpers"] = nil
package.loaded["gtd.config"] = nil
--

local checkboxes = require("gtd.checkboxes")
local sync = require("gtd.sync")
local target = require("gtd.target")
local helpers = require("gtd.helpers")
local config = require("gtd.config")

local M = {}

M.setup = config.setup

M.cycle_checkbox = checkboxes.cycle_checkbox
M.check_action = checkboxes.check_action
M.uncheck_action = checkboxes.uncheck_action
M.toggle_check = checkboxes.toggle_action_check
M.scrape_actions = sync.scrape_actions
M.target_action = target.target_action
M.untarget_action = target.untarget_action
M.toggle_action = target.toggle_target

vim.api.nvim_create_user_command("GtdCycleCheckbox", function(opts)
    local bool_val = opts.fargs[1] == "true"
    M.cycle_checkbox(bool_val)
end, { nargs = "?" })

vim.api.nvim_create_user_command("GtdCheckAction", function()
    M.check_action()
    helpers.write_all_files()
end, {})

vim.api.nvim_create_user_command("GtdUncheckAction", function()
    M.uncheck_action()
    helpers.write_all_files()
end, {})

vim.api.nvim_create_user_command("GtdToggleCheck", function()
    M.toggle_check()
    helpers.write_all_files()
end, {})

vim.api.nvim_create_user_command("GtdTargetAction", function()
    local res = M.target_action()
    if res ~= nil then
        helpers.write_all_files()
    end
end, {})

vim.api.nvim_create_user_command("GtdUntargetAction", function()
    local res = M.untarget_action()
    if res ~= nil then
        helpers.write_all_files()
    end
end, {})

vim.api.nvim_create_user_command("GtdToggleTargetAction", function()
    local res = M.toggle_action()
    if res ~= nil then
        helpers.write_all_files()
    end
end, {})

return M
