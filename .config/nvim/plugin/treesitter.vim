if has_key(g:plugs, 'nvim-treesitter')
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
endif
