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
        enable_auto_complete = false,
      },
      n_completions = 5,
      provider = 'gemini',
      provider_options = {
        gemini = {
          optional = {
            generationConfig = {
              maxOutputTokens = 256,
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
