-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- https://www.lazyvim.org/keymaps
-- ~/.local/share/LazyVim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua
-- ~/.local/share/LazyVim/lazy/LazyVim/lua/lazyvim/plugins/lsp/keymaps.lua
-- Add any additional keymaps here
-- Simple mappings

-- utilities
local map = vim.keymap.set
local function unmap(mode, lhs)
    if type(lhs) == "table" then
        for _, key in ipairs(lhs) do
            unmap(mode, key)
        end
        return
    else
        pcall(vim.api.nvim_del_keymap, mode, lhs)
    end
end


-- unmaps

unmap('n', ',')
unmap('n', { 'f', 'F', 't', 'T', ';' })

-- simple mappings in vimscript
vim.cmd([[

inoremap jk <esc>
nnoremap ,w <cmd>up<cr>
noremap  ,d "_d
noremap <c-s> <cmd>up<cr>
inoremap <c-s> <cmd>up<cr>

noremap <leader>um <cmd>setlocal filetype=markdown<cr>

noremap <leader>c. <cmd>execute getline('.')<CR>j

nmap ,b <leader>fb
nmap ,o <leader>fr
nmap ,e <leader>e
nmap ,t :exec "e ".system('mktemp -p /var/tmp --suffix=.md')<cr>

" Very limited.  Must use nmap.  Can't map both quote and backtick.
nmap ' `

nnoremap <leader>i :execute "silent !curl -fs 'http://localhost:63342/api/file/".expand("%")."?line=".line(".")."&column=".col(".")."'"<cr>

" nnoremap <space>st ?class<space><cr>

inoremap <M-x> <esc>ZZ
nnoremap <M-x> ZZ
]])


-- maps to functions

map({ "n", "i", "c", "v", "x", "o", "t", "s" }, "<M-k>", function()
    require("which-key").show({ mode = vim.api.nvim_get_mode().mode })
end)

-- toggle auto-pair
vim.g.minipairs_disable = true
vim.keymap.set({ "i", "n", "v" }, "<M-[>", function()
    local disabled = not vim.g.minipairs_disable
    vim.g.minipairs_disable = disabled
    vim.api.nvim_echo({ { "Autopairing: " .. tostring(not disabled) } }, true, {})
end, { desc = "Toggle pairing" })

-- \<mark>
-- Goes to the file of a global mark, but without going to the line
map("n", "\\", function()
    -- Prompt with list of global marks
    local marks_info = vim.fn.getmarklist()
    local global_marks = {}
    for _, m in ipairs(marks_info) do
        if m.mark:match("^'%u$") then
            table.insert(global_marks, m.mark:sub(2))
        end
    end
    table.sort(global_marks)
    print(table.concat(global_marks, ", ") .. " | Type global mark: ")

    -- get mark
    local mark = vim.fn.getcharstr():upper()

    -- go to the mark
    if not mark:match("^%u$") then return end
    local filepath = vim.api.nvim_get_mark(mark, {})[4]
    if #filepath > 0 then
        vim.cmd.edit(filepath)
    else
        print("Global mark " .. mark .. " doesn't exist")
    end
end, { noremap = true, silent = true })


-- relative jumps
for _, char in ipairs({ "j", "k" }) do
    map({ "n", "x" }, char, function()
        if vim.v.count == 0 then
            -- single-step over wrapped lines
            return "g" .. char
        elseif vim.v.count > 5 then
            -- add long jumps to jumplist
            return "m'" .. vim.v.count .. char
        else -- vim.v.count 1-5
            -- normal
            return char
        end
    end, { expr = true, silent = true, noremap = true })
end
