" https://github.com/phaazon/hop.nvim

if has_key(g:plugs, 'hop.nvim')
  lua require'hop'.setup( { keys = 'asdfghlqwertyuiopzxcvbnm' } )
  noremap f :HopChar1AC<cr>
  noremap F :HopChar1BC<cr>

  noremap g2 :HopChar2<cr>
  noremap gw :HopWord<cr>
  noremap g/ :HopPattern<cr>
elseif has_key(g:plugs, 'vim-easymotion')
  let g:EasyMotion_do_mapping = 0
  " TODO: tfTF
  map f <Plug>(easymotion-f)
  map F <Plug>(easymotion-F)
  map t <Plug>(easymotion-t)
  map T <Plug>(easymotion-T)

  map g2 <Plug>(easymotion-f2)
  map gw <Plug>(easymotion-w)
  map g/ <Plug>(easymotion-sn)
else
  " Just for muscle memory.  Not very useful
  noremap g2 f
  noremap gw /
  noremap g/ /
endif

" Keep original functionality available
noremap gf f
noremap gt t
noremap gF F
noremap gT T

