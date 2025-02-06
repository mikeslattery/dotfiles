-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

require("state").setup()
require("ash").setup()

vim.api.nvim_create_user_command("LspOff", function()
  if vim.fn.exists(":LspStop") == 2 then
    vim.cmd("LspStop")
  else
    vim.g.lsp_enabled = 0
  end
end, {})

vim.cmd.Dotenv(vim.fs.joinpath(tostring(vim.fn.stdpath("config")), ".env"))
vim.cmd.Dotenv(".env")

-- Load .env from current directory after changing directory
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    if vim.fn.expand("%:e") == "env" then
      vim.cmd("source <afile>")
    end
  end,
})

-- vim.api.nvim_create_autocmd("DirChanged", {
--   pattern = "*",
--   callback = function()
--     vim.cmd.DotEnv(".env")
--   end,
-- })
