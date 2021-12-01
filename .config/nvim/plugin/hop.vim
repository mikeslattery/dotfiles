" https://github.com/phaazon/hop.nvim

if has_key(g:plugs, 'hop.nvim')
  lua require'hop'.setup()

  noremap f :HopChar1AC<cr>
  noremap t :HopChar1BC<cr>

  noremap <leader>g2 :HopChar2<cr>
  noremap <leader>gw :HopWord<cr>
  noremap <leader>g/ :HopPattern<cr>

  noremap <leader>gf f
  noremap <leader>gt t
else
  " Just for muscle memory.  Not very useful
  noremap <leader>g2 f
  noremap <leader>gf f
  noremap <leader>gt t
  noremap <leader>gw /
  noremap <leader>g/ /
endif

