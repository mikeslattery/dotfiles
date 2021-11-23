" https://github.com/phaazon/hop.nvim

if has_key(g:plugs, 'hop.nvim')
  lua require'hop'.setup()

  noremap <leader>f1 :HopChar1AC<cr>
  noremap <leader>ft :HopChar1BC<cr>
  noremap <leader>f2 :HopChar2<cr>
  noremap <leader>fw :HopWord<cr>
  noremap <leader>f/ :HopPattern<cr>
else
  noremap <leader>f1 f
  noremap <leader>ft t
  noremap <leader>f2 f
  noremap <leader>fw /
  noremap <leader>f/ /
endif

