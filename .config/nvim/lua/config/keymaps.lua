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
  pcall(vim.api.nvim_del_keymap, mode, lhs)
end

-- unmaps

unmap(',')

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

" Very limited.  Must use nmap.  Can't map both quote and backtick.
nmap ' `

nnoremap <leader>i :execute "silent !curl -fs 'http://localhost:63342/api/file/".expand("%")."?line=".line(".")."&column=".col(".")."'"<cr>

nnoremap <space>st ?class<space><cr>
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
map("n", "\\", function()
  print("Type global mark: ")
  -- TODO: a TUI of buffers
  local mark = vim.fn.getcharstr()
  if not mark:match("^%u$") then return end
  local filepath = vim.api.nvim_get_mark(mark, {})[4]
  vim.cmd.edit(filepath)
end, { noremap = true, silent = true })

-- j/k - 1) add long skips to jumplist, 2) single-step over wrapped lines
local function skipper(char)
  map({ "n", "x" }, char, function()
    if vim.v.count == 0 then
      return "g" .. char
    elseif vim.v.count > 5 then
      -- add to jumplist
      return "m'" .. vim.v.count .. char
    else
      return vim.v.count .. char
    end
  end, { expr = true })
end

skipper('j')
skipper('k')
