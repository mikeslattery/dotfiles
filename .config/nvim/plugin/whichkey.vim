set timeout
set timeoutlen=1000

if has_key(g:plugs, 'which-key.nvim')
  lua << EOF
    require("which-key").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      -- TODO: spelling = { enabled = true, suggestions = 12 }

      -- plugins = {
      --   marks = false, -- shows a list of your marks on ' and `
      -- }
      plugins = {
        -- See ~/.config/nvim/lua/which-key/plugins/briefmarks.lua
        briefmarks = true,
        marks = false, -- shows a list of your marks on ' and `

        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        spelling = {
          enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
          suggestions = 20, -- how many suggestions should be shown in the list?
        },
        presets = {
          operators = true, -- adds help for operators like d, y, ...
          motions = true, -- adds help for motions
          text_objects = true, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g
        },
      },
    }
EOF
  " top level mappings
  nnoremap <M-k> <cmd>WhichKey<cr>
  vnoremap <M-k> <cmd>WhichKey '' v<cr>
  inoremap <M-k> <cmd>WhichKey '' i<cr>
  cnoremap <M-k> <cmd>WhichKey '' c<cr>

  " workaround for missing mappings
  nnoremap <c-w>p <c-w>p
  nnoremap <c-w><c-p> <c-w><c-p>

  autocmd VimEnter * nnoremap ' <Cmd>lua require("which-key").show("`", {mode = "n", auto = true})<CR>

elseif has_key(g:plugs, 'vim-which-key')

  noremap <silent> <leader> <Cmd>execute('WhichKey "'.g:mapleader.'"')<CR>
  " row,col marks more convenient
  noremap ' `

else
  noremap ' `
endif
