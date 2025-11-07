-- https://github.com/milanglacier/minuet-ai.nvim
-- https://ai.google.dev/gemini-api/docs/models

local PROVIDER = 'gemini'
local MODEL = 'gemini-2.5-flash'
local ENABLE_AUTO_COMPLETE = false

return {
  {
    'milanglacier/minuet-ai.nvim',
    -- enabled = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "Saghen/blink.cmp",
        opts = {
          keymap = {
            -- workaround:
            ['<M-y>'] = { function(cmp) cmp.show { providers = { 'minuet' } } end },
            -- ['<A-y>'] = return require('minuet').make_blink_map()
          },
          sources = {
            -- Enable minuet for autocomplete
            default = { 'minuet' },
            -- For manual completion only, remove 'minuet' from default
            providers = {
              minuet = {
                name = 'minuet',
                module = 'minuet.blink',
                score_offset = 8, -- Gives minuet higher priority among suggestions
              },
            },
          },
          -- Recommended to avoid unnecessary request
          completion = { trigger = { prefetch_on_insert = false } },
        }
      },
    },
    opts = {
      cmp = {
        enable_auto_complete = false,
      },
      blink = {
        enable_auto_complete = ENABLE_AUTO_COMPLETE,
      },
      n_completions = 5,
      provider = PROVIDER,
      provider_options = {
        gemini = {
          model = MODEL,
          -- system = "see [Prompt] section for the default value",
          -- few_shots = "see [Prompt] section for the default value",
          -- chat_input = "See [Prompt Section for default value]",
          -- stream = true,
          -- api_key = 'GEMINI_API_KEY',
          keymap = {
            -- Manually invoke minuet completion.
            ['<A-y>'] = function()
              require('minuet').make_blink_map()
            end,
          },

          optional = {
            generationConfig = {
              maxOutputTokens = 512,
            },
            safetySettings = {
              {
                -- HARM_CATEGORY_HATE_SPEECH,
                -- HARM_CATEGORY_HARASSMENT
                -- HARM_CATEGORY_SEXUALLY_EXPLICIT
                category = 'HARM_CATEGORY_DANGEROUS_CONTENT',
                -- BLOCK_NONE
                threshold = 'BLOCK_ONLY_HIGH',
              },
            },
          },
        },
      },
    },
  },
}

-- TODO:
-- high temperature
-- hotkeys to change settings: max output, autocomplete
