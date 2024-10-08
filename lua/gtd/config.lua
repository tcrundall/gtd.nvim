local M = {}

M.default_opts = {
    notes_dir = "~/gtd-notes/",
    next_actions_file = "~/gtd-notes/next-actions.md",
}
M.is_initialized = false

M.opts = {}

M.setup = function(opts)
    print("Setting up!")
    if M.is_initialized then
        print("warning: already initialized")
        -- error("Already initialized")
    end
    print("Setting up gtd!")
    M.opts = vim.tbl_deep_extend("force", M.default_opts, opts)
    M.is_initialized = true
    print(vim.inspect(M.opts))
end

return M
