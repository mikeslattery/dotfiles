" VUNDLE STUFF
" To install Vundle: git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" To install/update plugins: vim +PluginInstall +qall
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

" Themeing
let g:airline_powerline_fonts = 1

" Whitespace
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab

" Searching
set showmatch
set incsearch
set hlsearch
nnoremap ,b :CtrlPBuffer<CR>
nnoremap ,m :CtrlPMRU<CR>
nnoremap ,p :CtrlP ~/src/mect<CR>
nnoremap ,x :bd<CR>
nnoremap ,e :e %:p:h<CR>
nnoremap ,k :bp<CR>
nnoremap ,j :bn<CR>

" Editing
"   add single character
nmap <C-i> i<space><esc>r
vmap <C-j> <Plug>MoveBlockDown
vmap <C-k> <Plug>MoveBlockUp
nmap <C-j> <Plug>MoveLineDown
nmap <C-k> <Plug>MoveLineUp

" Files
set autoread
nmap ,w :w<CR>
set directory=$HOME/.vim/swap//
set backupdir=$HOME/.vim/swap//

" Browsing
set foldenable
nnoremap j gj
nnoremap k gk
set mouse=a
inoremap jj <esc>

" copy/paste
vmap <C-c> "+yi
vmap <C-C> "+yi
vmap <C-x> "+c
vmap <C-v> c<ESC>"+p
imap <C-v> <ESC>"+pa

" L&F
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

