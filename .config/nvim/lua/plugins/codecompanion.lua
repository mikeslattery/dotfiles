return {
  {
    "olimorris/codecompanion.nvim",
    enabled = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- "nvim-treesitter/nvim-treesitter",
      -- { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
      {
        'Saghen/blink.cmp',
        opts = {
          sources = {
            default = { 'codecompanion' },
            -- per_filetype = {
            --   codecompanion = { "codecompanion" },
            -- }
          },
        },
      },
    },
    -- config = true,
    opts = {
      strategies = {
        chat = {
          adapter = "sonnet",
        },
        inline = {
          adapter = "sonnet",
        },
      },
      strategies = {
        chat = {
          slash_commands = {
            ["help"] = {
              opts = {
                provider = "snacks", -- fzf_lua or snacks
              },
            },
          },
        },
      },
      adapters = {
        sonnet = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "https://openrouter.ai/api/v1",
              chat_url = "/chat/completions",
              api_key = os.getenv("OPENROUTER_API_KEY"),
            },
            schema = {
              model = {
                -- default = "anthropic/claude-3.5-sonnet:beta",
                default = "google/gemini-flash-1.5",
              },
            },
          })
        end,
        flash = function()
          return require("codecompanion.adapters").extend("gemini", {
            name = "flash",
            schema = {
              model = {
                default = "gemini-1.5-flash",
              },
            },
          })
        end,
      },
    },
  },
}
