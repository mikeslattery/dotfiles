" VUNDLE STUFF
" To install Vundle: git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" To install/update plugins: vim +PluginInstall +qall
" To reload>  :so $MYVIMRC | redraw!
set nocompatible              " be iMproved, required
filetype off                  " required
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'tpope/vim-sensible'
Plugin 'scrooloose/syntastic'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-eunuch' " Unix commands
Plugin 'scrooloose/nerdcommenter'
Plugin 'matze/vim-move'
Plugin 'majutsushi/tagbar'

call vundle#end()            " required
filetype plugin indent on    " required

" MY CUSTOM STUFF
" See:
"   http://dougblack.io/words/a-good-vimrc.html

" WHITESPACE
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab

" SEARCHING FILES
set showmatch
set incsearch
set hlsearch
nnoremap ,b :CtrlPBuffer<CR>
nnoremap ,m :CtrlPMRU<CR>
nnoremap ,p :CtrlP ~/src/mect<CR>
"   close current buffer
nnoremap ,x :bp\|bd #<CR>
"   browse files in same dir as current file
nnoremap ,e :e %:p:h<CR>
"   next/prev buffer
nnoremap ,k :bp<CR>
nnoremap ,j :bn<CR>
set wildignore+=.git/*,*/target/*,*.class,*.png,*.gif,*.pdf,*.exe,*.so,*.jar,*.war,*.ear,*.dll,*.swp,*.zip

" EDITING
"   add single character
nmap <C-i> i<space><esc>r
vmap <C-j> <Plug>MoveBlockDown
vmap <C-k> <Plug>MoveBlockUp
nmap <C-j> <Plug>MoveLineDown
nmap <C-k> <Plug>MoveLineUp
set clipboard=unnamed,unnamedplus

" FILES
set autoread
"   quick save
nmap ,w :up<CR>
set directory=$HOME/.vim/swap//
set backupdir=$HOME/.vim/swap//

" BROWSING
set foldenable
nnoremap j gj
nnoremap k gk
set mouse=a
inoremap jj <esc>
set relativenumber
set number

" L&F
"   block cursor in cygwin
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"
"   use less cool default font
let g:airline_powerline_fonts=0

