"exec" vim +PlugInstall +qa
set nocompatible

" Autoinstall plugin manager
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !mkdir -p ~/.vim/{sessions,templates,backup}
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
" Install missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \| PlugInstall --sync | source $MYVIMRC
  \| endif

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'dense-analysis/ale'
Plug 'bling/vim-airline'
if executable('git')
  Plug 'airblade/vim-gitgutter'
  "Plug 'tpope/vim-fugitive'
endif
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

"Plug 'tfnico/vim-gradle'
"Plug 'tpope/vim-dispatch'
"Plug 'tpope/vim-rsi'

"TODO: consider:
"TODO:  terminus, fugitive, surround, tagbar,
"TODO:  repeat, easymotion
"TODO:  lsp
"TODO: replacements:
"TODO:  neomake, coc, dispatch
"TODO: diy
"TODO:  vim-sensible, fzf, vim-airline
"TODO: put vim-sensible settings in this file.

call plug#end()

" MY CUSTOM STUFF "
" See:
"   http://dougblack.io/words/a-good-vimrc.html


" EXECUTION
command! -nargs=1 Silent execute 'silent !' . <q-args> | execute 'redraw!'
nnoremap ,v :execute getline('.')<CR>
nnoremap ,,v :source $MYVIMRC<CR>
nnoremap ,,u :PlugClean\|PlugUpgrade\|PlugUpdate<cr>
nnoremap ,,s :mksession! $HOME/.vim/sessions/
nnoremap ,,r :so $HOME/.vim/sessions/
nnoremap ,,w :update\|silent! make -s\|redraw!\|cc<cr>
nnoremap ,,q :execute 'silent !tmux send-keys -t 1 "'.escape(getline('.'), '"#').'" Enter'<cr>:redraw!<cr>
"TODO: vnoremap ,,q :<c-U>execute '!tmux send-keys -t 1 "'.escape(join(getline(getpos("'<")[1],getpos("'>")[1]), "\n"), '"#').'" Enter'<cr>
" ignore any further error formats.  (hopefully this doesn't break any plugins)
set errorformat+=%-G%.%#

" WHITESPACE
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab
set autoindent

" SEARCHING FOR FILES
set showmatch
set incsearch
"set hlsearch
set ignorecase
set smartcase
nnoremap ,i :execute "silent !curl -fs 'http://localhost:63342/api/file/".expand("%")."?line=".line(".")."&column=".col(".")."'"\|redraw!<cr>

if executable('fzf')
  nnoremap ,b :Buffers<CR>
  nnoremap ,m :History<CR>
  nnoremap ,p :GFiles<CR>
  nnoremap ,k :Marks<CR>
  nnoremap ,l :BLines<CR>
  if executable('rg')
    nnoremap ,g :Rg<space>
  else
    nnoremap ,g :grep<space>
  endif
else
  nnoremap ,b :ls<cr>:b
  nnoremap ,m :browse oldfiles<cr>
  nnoremap ,p :find **/**<left>
  nnoremap ,k :marks<cr>
  nnoremap ,l /
  nnoremap ,g :grep<space>
endif
vnoremap ,c :I#<ESC><C-i>
"   close current buffer
nnoremap ,x :bp\|bd #<CR>
"   browse files in same dir as current file
nnoremap ,e :let curfile=expand('%')<cr>:e %:p:h<CR>:execute '/\V'.curfile.'\$'<cr>:noh<cr>
nnoremap ,,e :checktime<CR>
nnoremap ,,rm :call delete(expand('%'))\|bdelete!<CR>
nnoremap ,,grm :!git rm %\|bdelete!<CR>
set wildignore+=.git/*,*/target/*,*.class,*.png,*.gif,*.pdf,*.exe,*.so,*.jar,*.war,*.ear,*.dll,*.swp,*.zip
set path+=**
let g:netrw_liststyle=4
let g:netrw_bufsettings='relativenumber nomodifiable nomodified readonly nobuflisted'

" SEARCHING FILE CONTENTS
if executable("rg")
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
augroup myvimrc
  autocmd!
  autocmd QuickFixCmdPost [^l]* cwindow
  autocmd QuickFixCmdPost l*    lwindow
augroup END
nnoremap ,/ :noh<cr>

" EDITING
"nnoremap <cr> o<esc>
"nnoremap <space> i<space><esc>l
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
nnoremap ,d "_d
vnoremap ,d "_d
set clipboard=unnamed,unnamedplus
" delete previous word
inoremap <C-h> <C-w>
inoremap <C-bs> <C-w>
" Capitalize previous word
inoremap <C-\> <esc>b~wi
" readline-like mappings
inoremap <C-a> <C-o>^
inoremap <C-e> <C-o>A
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-k> <C-o>d$
inoremap <esc>b <S-Left>
inoremap <esc>f <S-Right>
inoremap <esc>d <C-o>dw
" ideavim
"inoremap <A-b> <C-o>b
"inoremap <A-f> <C-o>w
"inoremap <A-d> <C-o>dw
" built-in: c-u, c-w
" conflicts: c-a, c-k
" excluded: c-b

" TERMINAL
nnoremap <c-w>% :rightbelow vertical terminal<cr>
nnoremap <c-w>" :below terminal<cr>
nnoremap ,h :rightbelow vertical help<space>
nnoremap ,,l :call term_sendkeys(bufnr($SHELL),getline('.') . "\n")<cr>

" CREATE/SAVE FILES
nnoremap ,,t :exec "e ".system('mktemp -p /var/tmp')<cr>
nnoremap ,w :up<CR>
nnoremap ,,java :-1read $HOME/.vim/templates/template.java<CR>/REPLACEME<CR>
set autoread
set hidden
set undofile
set undodir=$HOME/.vim/undo//
set backup
set backupdir=$HOME/.vim/backup//
set noswapfile

" BROWSING TEXT
set foldenable
set mouse=a
inoremap jk <esc>
nnoremap ,n :set relativenumber!<CR>
set number
set relativenumber
set wrap linebreak nolist
set tw=480

" SOURCE CODE
let g:ale_linters={'java': []}

" L&F
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
set cmdheight=1
if has('gui_running')
  highlight Normal guifg=white guibg=black
endif

"TODO
" On save, if %.watch exists, run it.
" Ale + LSP. Jetbrains mappings
