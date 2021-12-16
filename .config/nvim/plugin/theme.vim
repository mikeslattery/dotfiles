
" https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
if has('nvim')
  " I don't know why this doesn't work in Vim, but meh
  set termguicolors
endif
colorscheme dracula

" darker background
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

