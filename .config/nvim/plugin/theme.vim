colorscheme dracula

" https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim
highlight Normal cterm=NONE ctermbg=233 gui=NONE guibg=#121212

if has("win32unix")
  " block cursor in cygwin
  " https://github.com/mintty/mintty/wiki/Tips
  let &t_ti.="\e[1 q"
  let &t_SI.="\e[5 q"
  let &t_EI.="\e[1 q"
  let &t_te.="\e[0 q"
endif
let g:airline_powerline_fonts=1
set noshowmode
