" https://github.com/phaazon/hop.nvim

if has_key(g:plugs, 'hop.nvim')
  lua require'hop'.setup()

  noremap <leader>1 :HopChar1AC<cr>
  noremap <leader>2 :HopChar2<cr>
  noremap <leader>ft :HopChar1BC<cr>
  noremap <leader>fw :HopWord<cr>
  noremap <leader>f/ :HopPattern<cr>
else
  " Just for muscle memory.  Not very useful
  noremap <leader>1 f
  noremap <leader>2 f
  noremap <leader>ft t
  noremap <leader>fw /
  noremap <leader>f/ /
endif

