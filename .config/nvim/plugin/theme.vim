
" https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
" https://vimhelp.org/term.txt.html#xterm-true-color
set termguicolors
colorscheme dracula

" darker background
" https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim
highlight Normal cterm=NONE ctermbg=233 gui=NONE guibg=#121212
highlight CursorLine cterm=NONE ctermbg=234 gui=NONE guibg=#1c1c1c
highlight CursorColumn cterm=NONE ctermbg=234 gui=NONE guibg=#1c1c1c

set cursorline

set colorcolumn=100

if has("win32unix")
  " block cursor in cygwin
  " https://github.com/mintty/mintty/wiki/Tips#mode-dependent-cursor-in-vim
  let &t_ti.="\e[1 q"
  let &t_SI.="\e[5 q"
  let &t_EI.="\e[1 q"
  let &t_te.="\e[0 q"
endif
let g:airline_powerline_fonts=1
set noshowmode

