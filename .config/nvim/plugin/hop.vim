" https://github.com/phaazon/hop.nvim

if has_key(g:plugs, 'hop.nvim')
  " lua require'hop'.setup( { keys = 'asdfghjklzxcvbnmqwertyuiop', jump_on_sole_occurrence = false, perm_method = require'hop.perm'.TermSeqBias, term_seq_bias = 0.5 } )
  lua require'hop'.setup( { jump_on_sole_occurrence = false } )
  noremap f :HopChar1AC<cr>
  noremap F :HopChar1BC<cr>
  " TODO: fix position
  noremap t :HopChar1AC<cr>
  noremap T :HopChar1BC<cr>

  noremap g2 :HopChar2<cr>
  noremap gw :HopWord<cr>
  noremap g/ :HopPattern<cr>
elseif has_key(g:plugs, 'vim-easymotion')
  let g:EasyMotion_do_mapping = 0

  map f <Plug>(easymotion-f)
  map F <Plug>(easymotion-F)
  map t <Plug>(easymotion-t)
  map T <Plug>(easymotion-T)

  map g2 <Plug>(easymotion-f2)
  map gw <Plug>(easymotion-w)
  map gb <Plug>(easymotion-b)
  map g/ <Plug>(easymotion-sn)
else
  " Just for muscle memory.  Not very useful
  noremap g2 :call search(nr2char(getchar()) . nr2char(getchar()))<cr>
  noremap gw /
  noremap g/ /
endif

" Keep original functionality available
noremap <leader>gf f
noremap <leader>gt t
noremap <leader>gF F
noremap <leader>gT T
noremap <leader>g; ;
noremap <leader>g, ,

