return {
  {
    dir = "~/src/my/genie",
    lazy = true,
    cmd = { "Wish" },
    opts = {
      model = 'anthropic/claude-3.5-sonnet:beta',
      -- model = 'gpt-4o',
    },
  },
  {
    dir = "~/src/my/ax",
    lazy = true,
    cmd = {
      "Ax",
      "AxMove",
      "AxForget",
      "AxMoved",
      "AxAudit",
    },
  },
  {
    "ellisonleao/dotenv.nvim",
    lazy = false,
    -- workaround: needed or it wont load. idkw
    opts = {},
  },
  { "dracula/vim", as = "dracula", lazy = false },
  {
    "christoomey/vim-tmux-navigator",
    lazy = true,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
}

-- TODO:
-- # Lazier
-- genie - Wish commands
-- ax - Ax commands
-- # Old plugins to consider adding
-- Plug 'ggandor/leap.nvim'
-- Plug 'norcalli/nvim-colorizer.lua'
-- Plug 'chentoast/marks.nvim'
