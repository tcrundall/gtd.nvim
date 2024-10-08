local M = {}

M.default_opts = {
    notes_dir = "~/gtd-notes/",
    next_actions_list_file = "~/gtd-notes/next-actions.md",
}
local is_initialized = false

M.opts = {}

M.setup = function(opts)
    if is_initialized then
        print("warning: already initialized")
    end
    print("Setting up gtd!")
    M.opts = vim.tbl_deep_extend("force", M.default_opts, opts)
    is_initialized = true
    print(vim.inspect(M.opts))
end

return M
