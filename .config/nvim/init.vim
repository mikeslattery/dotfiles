" Requires: vim or neovim, curl or wget
" Optional: git, fzf, rg, nodejs
" Windows gVim not supported

" Autoinstall plugin manager
let g:data_dir = has('nvim') ? stdpath('data') . '/site' : $HOME . '/.vim'
let g:plugged = '~/.vim/plugged'
if empty(glob(g:data_dir . '/autoload/plug.vim'))
  call  mkdir(g:data_dir . '/autoload', 'p')
  let s:plugurl= 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  silent execute '!curl -fsLo '.g:data_dir.'/autoload/plug.vim '.s:plugurl
    \ .' ||        wget -q -O '.g:data_dir.'/autoload/plug.vim '.s:plugurl
endif
" Install missing plugins
autocmd VimEnter * if getcwd() != $HOME && len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \| PlugClean | PlugUpdate --sync | source $MYVIMRC
  \| endif

"TODO:
"" Install missing apps, if possible
"if ! executable('neovim-node-host') && executable('npm')
"  silent !npm install -g neovim
"endif
"if ! executable('neovim-ruby-host') && executable('gem')
"  silent !gem install neovim
"endif
"if executable('python3')
"  silent !python3 -m pip uninstall neovim
"  silent !python3 -m pip install --user --upgrade pynvim
"endif

call plug#begin(g:plugged)

if !has('nvim')
  Plug 'noahfrederick/vim-neovim-defaults'
endif
Plug 'tpope/vim-sensible'
if executable('fzf')
  Plug 'junegunn/fzf.vim'
else
  Plug 'ctrlpvim/ctrlp.vim'
endif
" Required for tmux-continuum
Plug 'tpope/vim-obsession'
Plug 'dense-analysis/ale'
Plug 'bling/vim-airline'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
if isdirectory('.git') && executable('git')
  Plug 'airblade/vim-gitgutter'
  Plug 'tpope/vim-fugitive'
endif

call plug#end()

" MY CUSTOM STUFF "
" See:
"   http://dougblack.io/words/a-good-vimrc.html

let mapleader=','
let maplocalleader=mapleader

" EXECUTION
" silently run a command, and only show output on error
command! -nargs=1 Silent execute 'silent !(' . <q-args> .') || (echo Hit enter:; read)' | execute 'redraw!'
nnoremap ,,m :update\|Silent pandoc % -o /tmp/vim.pdf<cr>
nnoremap ,v  :execute getline('.')<CR>
nnoremap ,,v :source $MYVIMRC<CR>
nnoremap ,,u :PlugClean\|PlugUpdate --sync\|PlugUpgrade<cr>
call mkdir(g:data_dir.'/sessions', 'p')
noremap ,,s :execute 'mksession! '.g:data_dir.'/sessions/'<left>
nnoremap ,,r :execute 'so '.g:data_dir.'/sessions/'<left>
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
set autoindent
set backspace=indent,eol,start

" SEARCHING FOR FILES
set showmatch
nnoremap ,/ :noh<cr>
set incsearch
"set hlsearch
set ignorecase
set smartcase
nnoremap ,i :execute "update\|silent !curl -fs 'http://localhost:63342/api/file/".expand("%")."?line=".line(".")."&column=".col(".")."'"\|redraw!<cr>

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
  nnoremap <leader>j :Jumps<cr>
  nnoremap <leader>c :Changes<cr>
else
  nnoremap ,b :CtrlPBuffer<cr>
  nnoremap ,m :CtrlPMRU<cr>
  nnoremap ,p :CtrlP<cr>
  nnoremap ,k :marks<cr>
  nnoremap ,l /
  nnoremap ,g :grep<space>
  nnoremap <leader>j :jumps<cr>
  nnoremap <leader>c :changes<cr>
endif
"TODO: what? vnoremap ,c :I#<ESC><C-i>
"   close current buffer
nnoremap ,x :bd<CR>
"   browse files in same dir as current file
nnoremap ,e :let @/=expand('%:t')<cr>:Explore<cr>
"   browse files in project dir
nnoremap ,,e :Explore .<cr>
nnoremap ,,,e :checktime<CR>
nnoremap ,,rm :call delete(expand('%'))\|bdelete!<CR>
nnoremap ,,grm :silent !git rm %\|bdelete!<CR>
set wildignore+=.git/*,*/target/*,*/node_modules/*,dist/*,.nuxt/*
set path+=**
"TODO: let g:netrw_list_hide=netrw_gitignore#Hide()
"TODO: execute 'set wildignore+='.substitute(g:netrw_list_hide.',**/.git/*','/,','/*,','g')
"TODO: execute 'set path+='.system('git ls-files | xargs -r dirname | sort -u | sed "s|/\\?$|/\\*|;" | paste -sd , -')
" Toggle banner with: I
let g:netrw_banner=0
let g:netrw_liststyle=4
let g:netrw_bufsettings='relativenumber nomodifiable nomodified readonly nobuflisted'

" SEARCHING FILE CONTENTS
if executable("rg")
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
"TODO: what is this?
augroup myvimrc
  autocmd!
  autocmd QuickFixCmdPost [^l]* cwindow
  autocmd QuickFixCmdPost l*    lwindow
augroup END


" EDITING
"nnoremap <cr> o<esc>
"nnoremap <space> i<space><esc>l
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
nnoremap ,d "_d
vnoremap ,d "_d
nnoremap ,q @q

set clipboard=unnamed,unnamedplus
" ctrl-backspace to delete previous word
inoremap <C-h> <C-w>
cnoremap <C-h> <C-w>
inoremap <C-bs> <C-w>
cnoremap <C-bs> <C-w>
" Capitalize previous word while editing
inoremap <C-\> <esc>m'b~`'a
" Capitalize sentence
"TODO: inoremap <c-\> <esc>:silent s/\([\.\?]\s\s*\)\(\w\)/\1\u\2/ge<cr>^gUlo

" readline-like mappings
inoremap <C-a> <C-o>^
inoremap <C-e> <C-o>A
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-k> <C-o>d$
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
set autoread
set hidden
set undofile
call mkdir(g:data_dir.'/undo', 'p')
let &undodir=g:data_dir.'/undo//'
set backup
call mkdir(g:data_dir.'/backup', 'p')
let &backupdir=g:data_dir.'/backup//'
set noswapfile

" BROWSING TEXT
set nofoldenable
set foldmethod=indent
set foldcolumn=1
set foldlevelstart=99
set foldnestmax=10
set foldlevel=2
let g:markdown_folding=1
set mouse=a
" double click check box
"TODO: uncheck.  only check if brackets.  single click
nnoremap <2-LeftMouse> rx
"TODO: remove jk
inoremap jk <esc>
nnoremap <C-Space> i
nnoremap <C-@> i
inoremap <C-Space> <Esc>
inoremap <C-@> <Esc>
inoremap <C-c> <esc>

nnoremap ,n :set relativenumber!<CR>
set number
set relativenumber
set wrap linebreak nolist
set tw=480
" stay centered
nnoremap n nzzzv
nnoremap N Nzzzv
" add to jumplist on relative moves
nnoremap <expr> j (v:count > 5 ? "m'" . v:count . "j" : "j")
nnoremap <expr> k (v:count > 5 ? "m'" . v:count . "k" : "k")

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

" Functions

function GoTo(jumpline)
  let values = split(a:jumpline, ":")
  echo "e ".values[0]
  call cursor(str2nr(values[1]), str2nr(values[2]))
  execute "normal! zvzz"
endfunction

function GetLine(bufnr, lnum)
  let lines = getbufline(a:bufnr, a:lnum)
  if len(lines)>0
    return trim(lines[0])
  else
    return ''
  endif
endfunction

function! Jumps()
  " Get jumps with filename added
  let jumps = map(reverse(copy(getjumplist()[0])), 
    \ { key, val -> extend(val, {'name': expand('#'.(val.bufnr)) }) })

  let jumptext = map(copy(jumps), { index, val -> 
      \ (val.name).':'.(val.lnum).':'.(val.col+1).': '.GetLine(val.bufnr, val.lnum) })

  call fzf#run(fzf#vim#with_preview(fzf#wrap({
        \ 'source': jumptext,
        \ 'column': 1,
        \ 'options': ['--delimiter', ':', '--bind', 'alt-a:select-all,alt-d:deselect-all', '--preview-window', '+{2}-/2'],
        \ 'sink': function('GoTo')})))
endfunction

command! Jumps call Jumps()

function! Changes()
  let changes  = reverse(copy(getchangelist()[0]))

  let offset = &lines / 2 - 3
  let changetext = map(copy(changes), { index, val -> 
      \ expand('%').':'.(val.lnum).':'.(val.col+1).': '.GetLine(bufnr('%'), val.lnum) })

  call fzf#run(fzf#vim#with_preview(fzf#wrap({
        \ 'source': changetext,
        \ 'column': 1,
        \ 'options': ['--delimiter', ':', '--bind', 'alt-a:select-all,alt-d:deselect-all', '--preview-window', '+{2}-/2'],
        \ 'sink': function('GoTo')})))
endfunction

command! Changes call Changes()


"TODO
" Tabs
"   help tab
"   tabs: code, tdd
"   tdd tab: keep windows in sync
"     left: test, right: code, bottom: quickfix
"     keybinding to sync other tab.
"      when not in this tab, it will jump to it and then sync
"   fzf tabs
"   taboo plugin
"   tab name in status line
" On save, if %.watch exists, run it.
" Learn:
"   marks, registers, record/playback, quickfix lists
"   vim-easymotion, vim-surround, vim-commentary
"   browse/edit command history, tags
"   vimdiff, themes
" Source of other mappings
" https://www.youtube.com/watch?v=hSHATqh8svM

" consider plugins:
"  CoC.  Jetbrains mappings
"  quick-scope
"  terminus, fugitive, surround, tagbar,
"  repeat, easymotion
"  coc or neovim lsp-config
" replacements:
"  neomake, coc, dispatch
" diy
"  vim-sensible, fzf, vim-airline
" put vim-sensible and/or defaults.vim settings in this file.
"Plug 'unblevable/quick-scope' 
"Plug 'tpope/vim-fugitive'
"Plug 'tfnico/vim-gradle'
"Plug 'tpope/vim-dispatch'
"Plug 'tpope/vim-rsi'
" " Let's not install and start heavy IDE features if not necessary
" if filereadable('package.json') && isdirectory('.git')
"   if executable('node')
"     Plug 'neoclide/coc.nvim', {'branch': 'release'}
"     nnoremap <c-]> jump to mappings
"   elseif executable('ctags')
"     " ctags
"     " see https://vim.fandom.com/wiki/Vim_as_a_refactoring_tool_and_some_examples_in_C_sharp
"     Plug 'ludovicchabant/vim-gutentags'
"     Plug 'fvictorio/vim-extract-variable'
"   endif
" endif
" tags
"   https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html  
"   https://github.com/ludovicchabant/vim-gutentags
"TODO: check for 1:1 g:plugs to plugged directly match.  need to filter g:plugs on dirs in plugged
" another strategy, is to look for dirs in plugged not in g:plugs, and separately for dirs not in plugged
" if sort(split(globpath('~/.vim/plugged', '*'), "\n")) == sort(map(copy(values(g:plugs)), 'v:val.dir'))

