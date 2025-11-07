-- lua/extex/init.lua

-- Neovim plugin that updates environmental variables
-- to give spawned apps more context

local M = {}

local function setenv(name, value)
    vim.fn.setenv(name, value or '')
end

-- Function to update environment variables based on current buffer
local function update_env_vars()
    setenv('NVIM_BUFNAME', vim.fn.expand('%:p'))
    setenv('NVIM_FILETYPE', vim.bo.filetype)
    setenv('NVIM_BUFTYPE', vim.bo.buftype)
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
        callback = function()
            update_env_vars()
        end,
    })

    setenv('NVIM_PID', tostring(vim.uv.os_getpid()))
    update_env_vars()
end

return M
