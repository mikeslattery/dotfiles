":" VUNDLE STUFF.
":" This file can be run as a bash script
"mkdir" -p ~/.vim/{bundle,swap,sessions,templates}
"test" -d ~/.vim/bundle/Vundle.vim || git clone git://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"vim" +PluginInstall +qall
"exit"
" To reload>  :so $MYVIMRC | redraw!
" To save a session> mksession! ~/mysession.ses
" To load a session> :so ~/mysession.ses
set nocompatible              " be iMproved, required
filetype off                  " required
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'tpope/vim-sensible'
Plugin 'scrooloose/syntastic'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rsi'
"TODO: fix babun.  Install Cygwin64
"TODO: consider:
"TODO:  terminus, fugative, surround, tagbar,
"TODO:  gitgutter, youcompleteme
"TODO:  ale, repeat, easymotion
"TODO:  lsp
"TODO: replacements:
"TODO:  ale, neomake, ack w/ripgrep, dispatch
"TODO: put vim-sensible settings in this file.

call vundle#end()            " required
filetype plugin indent on    " required

" MY CUSTOM STUFF
" See:
"   http://dougblack.io/words/a-good-vimrc.html

" EXECUTION
command! -nargs=1 Silent execute 'silent !' . <q-args> | execute 'redraw!'
nnoremap ,v :execute getline('.')<CR>

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
set ignorecase
set smartcase
nnoremap ,s :mksession! $HOME/.vim/sessions/
nnoremap ,r :so $HOME/.vim/sessions/
nnoremap ,i :execute "silent !cscript //b //nologo $(cygpath -wa ~/bin/idea.vbs) ".getcwd()." ".expand("%")." ".line(".")." ".col(".")\|redraw!<CR>
"if ctrlp not installed:
"nnoremap ,b :ls<cr>:b
"nnoremap ,m :browse oldfiles<cr>q
"nnoremap ,p :find *
nnoremap ,b :CtrlPBuffer<CR>
nnoremap ,m :CtrlPMRU<CR>
nnoremap ,p :CtrlP ~/src/mect<CR>
nnoremap ,d :redraw!<CR>
vnoremap ,c :I#<ESC><C-i>
"   close current buffer
nnoremap ,x :bp\|bd #<CR>
"   browse files in same dir as current file
nnoremap ,e :e %:p:h<CR>
nnoremap ,,rm :call delete(expand('%'))\|bdelete!<CR>
nnoremap ,,grm :!git rm %\|bdelete!<CR>
set wildignore+=.git/*,*/target/*,*.class,*.png,*.gif,*.pdf,*.exe,*.so,*.jar,*.war,*.ear,*.dll,*.swp,*.zip
set path+=**

" EDITING
"nnoremap <cr> o<esc>
"nnoremap <space> i<space><esc>l
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
set clipboard=unnamed,unnamedplus

" CREATE/SAVE FILES
nnoremap ,t :exec "e ".tempname()<cr>
nnoremap ,w :up<CR>
nnoremap ,,java :-1read $HOME/.vim/templates/template.java<CR>/REPLACEME<CR>
set autoread
set hidden
set undofile
set undodir=$HOME/.vim/swap//
set nobackup
set noswapfile
"set directory=$HOME/.vim/swap//

" BROWSING TEXT
set foldenable
set mouse=a
inoremap jj <esc>
nnoremap ,n :set relativenumber!<CR>
set number
set relativenumber
set wrap linebreak nolist
set tw=480
let g:netrw_liststyle=4

" SOURCE CODE
let g:loaded_syntastic_java_javac_checker=1
let g:loaded_syntastic_html_validator_checker=1
let g:syntastic_mode_map = { "mode": "active", "passive_filetypes": ["html"] }
" TODO: use -all-.jar
" let g:syntastic_java_checkstyle_classpath = "$HOME/.m2/repository/com/puppycrawl/tools/checkstyle/6.11.2/checkstyle-6.11.2.jar"
" let g:syntastic_java_checkstyle_conf_file = "$HOME/src/mect/checkstyle.xml"
" let g:syntastic_java_checkers = ["checkstyle"]

" L&F
"   block cursor in cygwin
"   https://github.com/mintty/mintty/wiki/Tips
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"
let g:airline_powerline_fonts=1
set noshowmode
set cmdheight=1

