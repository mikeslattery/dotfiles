-- This Neovim plugin manages session persistence by saving and loading the editor's state.
-- It allows users to automatically save their session when exiting or losing focus, and
-- restore it upon reopening. The plugin supports specifying a custom directory for storing
-- session files and can be toggled on or off using command-line arguments.

-- This plugin is usually not lazy.  It has to run as part of Neovim startup.

local M = {
    options = {},
}

local DEFAULT_OPTIONS = {
    dir = "./.nvim",
    session = "Session.vim",
    shada = "main.shada",
    -- set to true to enable state by default.  +NoState can override on CLI.
    load = false,
}

local _stateful = false

local _last_shada_mtime = 0

local function _rshada()
    if vim.fn.filereadable(vim.o.shadafile) == 1 then
        vim.schedule(function()
            local mtime = vim.fn.getftime(vim.o.shadafile)
            if mtime > _last_shada_mtime then
                vim.cmd.rshada()
                _last_shada_mtime = mtime
            end
        end)
    end
end

local function _wshada()
    vim.schedule(function()
        vim.cmd.wshada()
        _last_shada_mtime = vim.fn.getftime(vim.o.shadafile)
    end)
end

local function _rsession()
    local dir = M.options.dir
    local session_path = dir .. "/" .. M.options.session
    if vim.fn.filereadable(session_path) == 1 then
        vim.schedule(function()
            local last_write = vim.fn.getftime(session_path)
            if not M._last_session_write or last_write > M._last_session_write then
                vim.cmd.source(session_path)
            end
        end)
    end
end

local function _wsession()
    vim.schedule(function()
        local session_path = M.options.dir .. "/" .. M.options.session
        vim.cmd("mksession! " .. session_path)
        M._last_session_write = vim.fn.getftime(session_path)
    end)
end


-- load state, from options.dir
local function _load()
    local dir = M.options.dir
    _stateful = true
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
    if vim.fn.filereadable(dir .. "/.gitignore") == 0 then
        vim.fn.writefile({ "*" }, dir .. "/.gitignore")
    end
    if vim.fn.filereadable(dir .. "/.dockerignore") == 0 then
        vim.fn.writefile({ "*" }, dir .. "/.dockerignore")
    end

    vim.o.shadafile = dir .. "/" .. M.options.shada
    _rsession()
end

-- Loads state and set location of state
function M.load(dir)
    M.options.dir = dir or M.options.dir
    if _stateful then
        M.save()
    end
    _load()
    -- since this function is run after initialization, we need to force load
    _rshada()
end

function M.save()
    _wshada()
    _wsession()
end

function M.disable()
    _stateful = false
end

function M.setup(options)
    M.options = vim.tbl_deep_extend("force", DEFAULT_OPTIONS, options or {})
    -- absolute path, in case the current directory were to change
    M.options.dir = vim.fn.fnamemodify(M.options.dir, ":p"):gsub("[/\\]$", "")

    -- 'load = true' will make it to always load/save state,
    -- otherwise `+State` must be on command line
    if (M.options.load or vim.tbl_contains(vim.v.argv, "+State"))
        and not vim.tbl_contains(vim.v.argv, "NoState") then
        _load()
    end

    -- save whenever leaving Neovim, or making a significant state change
    vim.api.nvim_create_autocmd({ "VimLeavePre", "FocusLost", "FileType" }, {
        callback = function()
            if _stateful then
                M.save()
            end
        end,
    })

    vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
            if _stateful then
                _rshada() -- sync with other nvim processes
                vim.cmd.checktime()
            end
        end,
    })

    vim.api.nvim_create_user_command("State", function()
        -- This is here in case `:State` is manually used after `M.disable()`
        -- Normally _stateful would already be true.
        if not _stateful then
            M.load()
        end
    end, {})

    vim.api.nvim_create_user_command("NoState", function()
        M.disable()
    end, {})
end

return M
