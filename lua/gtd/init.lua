-- Here for easy development
-- vim.cmd("set rtp+=" .. vim.fn.getcwd())
-- package.loaded["gtd.checkboxes"] = nil
-- package.loaded["gtd.sync"] = nil
-- package.loaded["gtd.random_tags"] = nil
-- package.loaded["gtd.target"] = nil
-- package.loaded["gtd.helpers"] = nil
-- package.loaded["gtd.config"] = nil
--

local checkboxes = require("gtd.checkboxes")
local sync = require("gtd.sync")
local target = require("gtd.target")
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
end, {})

vim.api.nvim_create_user_command("GtdUncheckAction", function()
    M.uncheck_action()
end, {})

vim.api.nvim_create_user_command("GtdToggleCheck", function()
    M.toggle_check()
end, {})

vim.api.nvim_create_user_command("GtdTargetAction", function()
    M.target_action()
end, {})

vim.api.nvim_create_user_command("GtdUntargetAction", function()
    M.untarget_action()
end, {})

vim.api.nvim_create_user_command("GtdToggleTargetAction", function()
    M.toggle_action()
end, {})

return M
