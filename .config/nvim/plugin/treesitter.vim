if has_key(g:plugs, 'nvim-treesitter')
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()

  lua <<HL
  require'nvim-treesitter.configs'.setup {
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  }
HL
endif
