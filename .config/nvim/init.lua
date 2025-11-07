-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- embedded plugins
require("state").setup()
require("ash").setup()
require("down").setup()
require("env").setup()
require("extex").setup()


vim.api.nvim_create_user_command("LspOff", function()
    if vim.fn.exists(":LspStop") == 2 then
        vim.cmd("LspStop")
    else
        vim.g.lsp_enabled = 0
    end
end, {})


-- These should be in a .env.nvim plugin
