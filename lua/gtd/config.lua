local M = {}

M.default_opts = {
    notes_dir = "~/gtd-notes/",
    next_actions_file = "~/gtd-notes/next-actions.md",
}
M.is_initialized = false

M.opts = {}

M.setup = function(opts)
    if M.is_initialized then
        error("Already initialized")
    end
    M.opts = vim.tbl_deep_extend("force", M.default_opts, opts)
    M.is_initialized = true
end

return M
