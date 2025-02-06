-- see also https://github.com/yetone/avante.nvim/blob/main/lua/avante/config.lua

local enabled = false

local opts = {
  provider = "openrouter",
  auto_suggestions_provider = "gemini",
  vendors = {
    ["openrouter"] = {
      __inherited_from = "openai",
      endpoint = "https://openrouter.ai/api/v1",
      model = "anthropic/claude-3.5-sonnet:beta",
      timeout = 30000, -- milliseconds
      temperature = 0,
      max_tokens = 8000,
    },
    ["deepseek-v3"] = {
      __inherited_from = "openai",
      endpoint = "https://api.deepseek.com",
      api_key = os.getenv("DEEPSEEK_API_KEY"),
      model = "deepseek-chat",
      timeout = 30000, -- milliseconds
      temperature = 0,
      max_tokens = 8000,
    },
    ["deepseek-r1"] = {
      __inherited_from = "openai",
      endpoint = "https://api.deepseek.com",
      api_key = os.getenv("DEEPSEEK_API_KEY"),
      model = "deepseek-reasoner",
      timeout = 30000, -- milliseconds
      temperature = 0,
      max_tokens = 8000,
    },
  },
  gemini = {
    -- model = "gemini-exp-1206",
    model = "gemini-1.5-flash",
    temperature = 0.2,
    max_tokens = 4096,
  },
  ---Specify the behaviour of avante.nvim
  ---1. auto_focus_sidebar              : Whether to automatically focus the sidebar when opening avante.nvim. Default to true.
  ---2. auto_suggestions = false, -- Whether to enable auto suggestions. Default to false.
  ---3. auto_apply_diff_after_generation: Whether to automatically apply diff after LLM response.
  ---                                     This would simulate similar behaviour to cursor. Default to false.
  ---4. auto_set_keymaps                : Whether to automatically set the keymap for the current line. Default to true.
  ---                                     Note that avante will safely set these keymap. See https://github.com/yetone/avante.nvim/wiki#keymaps-and-api-i-guess for more details.
  ---5. auto_set_highlight_group        : Whether to automatically set the highlight group for the current line. Default to true.
  ---6. jump_to_result_buffer_on_finish = false, -- Whether to automatically jump to the result buffer after generation
  ---7. support_paste_from_clipboard    : Whether to support pasting image from clipboard. This will be determined automatically based whether img-clip is available or not.
  ---8. minimize_diff                   : Whether to remove unchanged lines when applying a code block
  behaviour = {
    auto_suggestions = false, -- Experimental stage
    auto_suggestions_respect_ignore = false,
    auto_apply_diff_after_generation = false,
    jump_result_buffer_on_finish = false,
    support_paste_from_clipboard = false,
  },
}

local function pr()
  -- https://github.com/LazyVim/LazyVim/pull/4440/files
  return {
    {
      "yetone/avante.nvim",
      event = "VeryLazy",
      dependencies = {
        "stevearc/dressing.nvim",
        "ibhagwan/fzf-lua",
      },
      opts = {
        -- Default configuration
        hints = { enabled = false },

        ---@alias AvanteProvider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
        provider = "claude",                  -- Recommend using Claude
        auto_suggestions_provider = "claude", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-3-5-sonnet-20241022",
          temperature = 0,
          max_tokens = 4096,
        },

        -- File selector configuration
        --- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | "telescope" | string
        file_selector = {
          provider = "fzf", -- Avoid native provider issues
          provider_opts = {},
        },
      },
      build = LazyVim.is_win() and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" or "make",
    },
    {
      "saghen/blink.cmp",
      lazy = true,
      dependencies = { "saghen/blink.compat" },
      opts = {
        sources = {
          default = { "avante_commands", "avante_mentions", "avante_files" },
          compat = {
            "avante_commands",
            "avante_mentions",
            "avante_files",
          },
          -- LSP score_offset is typically 60
          providers = {
            avante_commands = {
              name = "avante_commands",
              module = "blink.compat.source",
              score_offset = 90,
              opts = {},
            },
            avante_files = {
              name = "avante_files",
              module = "blink.compat.source",
              score_offset = 100,
              opts = {},
            },
            avante_mentions = {
              name = "avante_mentions",
              module = "blink.compat.source",
              score_offset = 1000,
              opts = {},
            },
          },
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      optional = true,
      ft = function(_, ft)
        vim.list_extend(ft, { "Avante" })
      end,
      opts = function(_, opts)
        opts.file_types = vim.list_extend(opts.file_types or {}, { "Avante" })
      end,
    },
    {
      "folke/which-key.nvim",
      optional = true,
      opts = {
        spec = {
          { "<leader>a", group = "ai" },
        },
      },
    },
  }
end

local result = {}
if enabled then
  result = pr()
  result[1].opts = vim.tbl_deep_extend("force", result[1].opts, opts)
end

return result
