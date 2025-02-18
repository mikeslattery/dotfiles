return {
  -- disable trouble
  { "noice.nvim",         enabled = false },
  { "persistence.nvim",   enabled = false },
  { "todo-comments.nvim", enabled = false },
  -- mini.pairs is disabled/enabed in keymaps.lua
  -- { "mini.pairs",         enabled = false },
  { "conform.nvim",       enabled = false },
  {
    "snacks.nvim",
    opts = {
      -- see mini-starter.lua
      dashboard = { enabled = false },
      notifier = { enabled = false },
      -- -- better vim.ui.input
      -- input = { enabled = false },
      -- picker = { enabled = false },
    },
  },
}
