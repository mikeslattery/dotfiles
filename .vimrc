" This .vimrc sets NeoVim's defaults for Vim
" then it loads NeoVim's init.vim

" Windows gVim is not supported.

" OPTIONS

" Vim 7 options that differ

set nocompatible
if has('autocmd')
  filetype plugin indent on
endif

set backspace=indent,eol,start
set encoding=utf-8
set incsearch
set nolangremap
let &nrformats="bin,hex"
set showcmd
set ruler
set wildmenu

" Vim 8 options that differ

set autoindent
set autoread
set background=dark
set belloff=all
set cdpath=,.,~/src,~/
set clipboard=
set cmdheight=1
set complete=.,w,b,u,t
set cscopeverbose
set diffopt=internal,filler
set display=lastline
set fillchars=
set formatoptions=tcqj
let &keywordprg=":Man"
set nofsync
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
set history=10000
set hlsearch
set laststatus=2
set listchars=tab:>\ ,trail:-,nbsp:+
set maxcombine=6
set scroll=13
set scrolloff=0
set sessionoptions-=options
set shortmess=filnxtToOF
set sidescroll=1
set smarttab
set tabpagemax=50
set tags=./tags;,tags
set notitle
set titleold=
set ttimeout
set ttimeoutlen=50
set ttyfast
set viminfo+=!
let &wildoptions="tagfile"

" DIRECTORIES

" These don't necessarily exist in neovim,
" but are convenient to have for Stdpath()

if ! exists('$XDG_CACHE_HOME')
  let $XDG_CACHE_HOME=$HOME . '/.cache'
endif

if ! exists('$XDG_CONFIG_HOME')
  let $XDG_CONFIG_HOME=$HOME . '/.config'
endif

if ! exists('$XDG_DATA_HOME')
  let $XDG_DATA_HOME=$HOME . '/.local/share'
endif

"" Put this in your init.vim to standardize on the name:
" if has('nvim')
"   function! Stdpath(id) | return stdpath(id) | endfunction
" endif

function! Stdpath(id)
  "let progname = v:progname
  let progname = 'nvim'
  if a:id == 'data'
    return $XDG_DATA_HOME . '/' . progname
  elseif a:id == 'data_dirs'
    return []
  elseif a:id == 'config'
    return $XDG_CONFIG_HOME . '/' . progname
  elseif a:id == 'config_dirs'
    return []
  elseif a:id == 'cache'
    return $XDG_CACHE_HOME . '/' . progname
  else
    throw '"' . a:id . '" is not a valid stdpath'
  endif
endfunction

let datadir    = Stdpath('data')
let &backupdir = datadir . '/backup//'
let &directory = datadir . '/swap//'
let &undodir   = datadir . '/undo//'
let &viewdir   = datadir . '/view//'

function! MakeDirs()
  for dir in [&backupdir, &directory, &undodir, &viewdir]
    call mkdir(dir, "p")
  endfor
endfunction
autocmd VimEnter * call MakeDirs()

let configdir    = Stdpath('config')
let &packpath    = configdir . ',' . configdir . '/after,' . &packpath
let &runtimepath = configdir . ',' . configdir . '/after,' . &runtimepath

" DEFAULT-MAPPINGS

nnoremap Y y$
nnoremap <C-L> <Cmd>nohlsearch<Bar>diffupdate<CR><C-L>
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>

" DEFAULT-AUTOCMDS - won't implement

" DEFAULT PLUGINS

if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif
if exists(":Man") != 2
  runtime! ftplugin/man.vim
endif

" LOAD init.vim

let $MYVIMRC = $XDG_CONFIG_HOME . '/nvim/init.vim'
"set noloadplugins   "uncomment for testing purposes
source $MYVIMRC

" See also:
" https://github.com/noahfrederick/vim-neovim-defaults/blob/master/plugin/neovim_defaults.vim
" https://neovim.io/doc/user/starting.html#startup
" https://neovim.io/doc/user/vim_diff.html
" https://github.com/vim/vim/blob/master/runtime/defaults.vim

" These settings were determined by running ~/bin/nvim-diff.sh

