set timeout
set timeoutlen=1000

if has_key(g:plugs, 'which-key.nvim')
  lua << EOF
    require("which-key").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      -- TODO: spelling = { enabled = true, suggestions = 12 }
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
