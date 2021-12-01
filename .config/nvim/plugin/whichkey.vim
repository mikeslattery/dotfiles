set timeout
set timeoutlen=1000

if has_key(g:plugs, 'vim-which-key')
  noremap <silent> <leader> :execute('WhichKey ","')<CR>

  noremap <silent> <leader> :execute('WhichKey "'.g:mapleader.'"')<CR>

  noremap <silent> <leader>f :execute('WhichKey "'.g:mapleader.'f"')<CR>
  noremap <silent> <leader><leader> :execute('WhichKey "'.g:mapleader.g:mapleader.'"')<CR>

  noremap <silent> f :<c-u>WhichKey "f"<CR>
  noremap <silent> g :<c-u>WhichKey "g"<CR>
  noremap <silent> c :<c-u>WhichKey "c"<CR>
  noremap <silent> [ :<c-u>WhichKey "["<CR>
  noremap <silent> ] :<c-u>WhichKey "]"<CR>
  noremap <silent> y :<c-u>WhichKey "y"<CR>
  noremap <silent> z :<c-u>WhichKey "z"<CR>

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

endif

