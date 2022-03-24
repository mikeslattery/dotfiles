set timeout
set timeoutlen=1000

if has_key(g:plugs, 'vim-which-key')

  noremap <silent> <leader> <Cmd>execute('WhichKey "'.g:mapleader.'"')<CR>

elseif has_key(g:plugs, 'which-key.nvim')
  lua << EOF
    require("which-key").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
EOF
  " workaround for missing mappings
  nnoremap <c-w>p <c-w>p
  nnoremap <c-w><c-p> <c-w><c-p>

  " top level mappings
  noremap <leader>vm <cmd>lua require('which-key').show()<cr>

endif

" TODO: spelling = { enabled = true, suggestions = 12 }
