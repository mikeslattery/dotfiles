-- lua/extex/init.lua

-- Neovim plugin that updates environmental variables
-- to give spawned apps more context

--- shell script how-tos
--- nvim --headless --clean --server $NVIM_SOCKET \
---    --remote <file>
---    --remote-send '<keystrokes>'
---    --remote-expr '<vimscript-expression>'

local M = {}

local setenv = vim.fn.setenv

-- Function to update environment variables based on current buffer
local function update_env_vars()
    setenv('NVIM_BUFNAME', vim.fn.expand('%:p'))
    setenv('NVIM_FILETYPE', vim.bo.filetype)
    setenv('NVIM_BUFTYPE', vim.bo.buftype)
    setenv('NVIM_BUFNR', tostring(vim.api.nvim_get_current_buf()))
    setenv('NVIM_SOCKET', vim.v.servername)
end

function M.setup()
    -- Create autocommands for buffer events
    local context_group = vim.api.nvim_create_augroup('ContextEnvVars', { clear = true })
    vim.api.nvim_create_autocmd({
        'BufEnter',
        'BufWritePost',
        'FileType'
    }, {
        group = context_group,
        callback = update_env_vars
    })

    setenv('NVIM_PID', tostring(vim.uv.os_getpid()))
    update_env_vars()
end

return M
