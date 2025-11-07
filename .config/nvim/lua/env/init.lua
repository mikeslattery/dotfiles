M = {}

function M.setup()
  vim.cmd.Dotenv(vim.fs.joinpath(tostring(vim.fn.stdpath("config")), ".env"))
  vim.cmd.Dotenv(".env")

  local group = vim.api.nvim_create_augroup("Env", { clear = true })

  -- env-var "sh" filetype
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = group,
    pattern = ".env.*",
    callback = function()
      vim.bo.filetype = "sh"
    end,
  })

  -- Load .env from current directory after changing directory
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
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
end

return M
