-- Add current directory to 'runtimepath' to be able to use 'lua' files
vim.cmd([[let &rtp.=','.getcwd()]])
local gtd = require("gtd")

NOTES_DIR = "tests/resources/"
NEXT_ACTIONS_FILE = "tests/resources/next-actions.md"
EXAMPLE_PROJECT_FILE = "tests/resources/projects/example.md"

gtd.setup({
    notes_dir = NOTES_DIR,
    next_actions_file = NEXT_ACTIONS_FILE,
})

-- Set up 'mini.test' only when calling headless Neovim (like with `make test`)
if #vim.api.nvim_list_uis() == 0 then
    -- Add 'mini.nvim' to 'runtimepath' to be able to use 'mini.test'
    -- Assumed that 'mini.nvim' is stored in 'deps/mini.nvim'
    vim.cmd("set rtp+=deps/mini.nvim")

    -- Set up 'mini.test'
    require("mini.test").setup()
end
