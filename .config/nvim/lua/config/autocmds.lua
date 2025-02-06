-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- -- Use this for all autocmds,
-- -- so when you reload this file they will all be redefined
-- local group = vim.api.nvim_create_augroup("Init", { clear = true })

-- -- Example
-- vim.api.nvim_create_autocmd("DirChanged", {
--   group = group,
--   pattern = "*",
--   callback = function()
--     vim.cmd.DotEnv(".env")
--   end,
-- })
--
