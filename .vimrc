"exec" ~/.config/nvim/init.vim "$@"

" This .vimrc sets NeoVim's defaults for Vim
" then it loads NeoVim's init.vim

if has('nvim') || exists('g:loaded_nvim_defaults')
  " Put this function in your init.vim,
  " in case you stop using this plugin, but still need it
  function! Stdpath(id)
    return stdpath(a:id)
  endfunction
  finish
endif

let g:loaded_nvim_defaults = 1

" OPTIONS
" :help nvim-defaults

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

" Vim 7, 8 options that differ

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
" TODO: 'fillchars' defaults (in effect) to "vert:│,fold:·,sep:│"
set fillchars=
set formatoptions=tcqj
let &keywordprg=":Man"
set nofsync
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
set hidden
set history=10000
set hlsearch
set nojoinspaces
set laststatus=2
set listchars=tab:>\ ,trail:-,nbsp:+
set maxcombine=6
set mouse=a
set scroll=13
set scrolloff=0
set sessionoptions-=options
set shortmess=filnxtToOF
set sidescroll=1
set smarttab
set tabpagemax=50
set tags=./tags;,tags
set notitle
set switchbuf=uselast
set titleold=
set ttimeout
set ttimeoutlen=50
set ttyfast
"TODO: set viewoptions+=unix,slash
set viewoptions-=options
set viminfo+=!
let &wildoptions="tagfile"

let g:vimsyn_embed='l'

if exists('$TMUX')
  set ttymouse=xterm2

  " https://vimhelp.org/term.txt.html#xterm-true-color
  " https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
  " if tmux and not(gVim) and termguicolors
  autocmd VimEnter * if !has('gui_running') && has('termguicolors') && &termguicolors
      \| let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
      \| let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    \| endif
endif

" DIRECTORIES

" These don't always necessarily exist in neovim,
" but are convenient to have for Stdpath()

if ! exists('$XDG_CACHE_HOME')
  if has('win32')
    let $XDG_CACHE_HOME=$TEMP
  else
    let $XDG_CACHE_HOME=$HOME . '/.cache'
  endif
endif

if ! exists('$XDG_CONFIG_HOME')
  if has('win32')
    let $XDG_CONFIG_HOME=$LOCALAPPDATA
  else
    let $XDG_CONFIG_HOME=$HOME . '/.config'
  endif
endif

if ! exists('$XDG_DATA_HOME')
  if has('win32')
    let $XDG_DATA_HOME=$LOCALAPPDATA
  else
    let $XDG_DATA_HOME=$HOME . '/.local/share'
  endif
endif

" Similar to nvim's stdpath(id)
" Unfortunately, user functions can't use lowercase
function! Stdpath(id)
  if a:id == 'data'
    if has('win32')
      return $XDG_DATA_HOME . '/nvim-data'
    else
      return $XDG_DATA_HOME . '/nvim'
    endif
  elseif a:id == 'data_dirs'
    return []
  elseif a:id == 'config'
    return $XDG_CONFIG_HOME . '/nvim'
  elseif a:id == 'config_dirs'
    return []
  elseif a:id == 'cache'
    return $XDG_CACHE_HOME . '/nvim'
  else
    throw '"' . a:id . '" is not a valid stdpath'
  endif
endfunction

let s:datadir    = Stdpath('data')
let &backupdir = s:datadir . '/backup//'
let &viewdir   = s:datadir . '/view//'
if ! executable('nvim')
  let &directory = s:datadir . '/swap//'
  let &undodir   = s:datadir . '/undo//'
else
  " Vim/NeoVim have different file formats
  let &directory = s:datadir . '/vimswap//'
  let &undodir   = s:datadir . '/vimundo//'
endif

let &viminfo.=',n' . s:datadir . '/viminfo'

" NeoVim creates directories if they don't exist
function! s:MakeDirs()
  for dir in [&backupdir, &directory, &undodir, &viewdir]
    call mkdir(dir, "p")
  endfor
endfunction
autocmd VimEnter * call s:MakeDirs()

" Add user config dirs to search paths
let s:configdir   = Stdpath('config')
let s:pathprefix  = s:configdir . ',' . s:datadir . '/site,'
let s:pathpostfix = ',' . s:configdir . '/after,' . s:datadir . '/site/after'
let &packpath     = s:pathprefix . &packpath .    s:pathpostfix
let &runtimepath  = s:pathprefix . &runtimepath . s:pathpostfix

" DEFAULT-MAPPINGS
" :help default-mappings

nnoremap Y y$
nnoremap <C-L> <Cmd>nohlsearch<Bar>diffupdate<CR><C-L>
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>

" Implement Q
let g:qreg='@'
function! RecordAndStop()
  if reg_recording() == ''
    echo 'Enter register to record to: '
    let g:qreg=getcharstr()
    if g:qreg != "\e"
      execute 'normal! q'.g:qreg
    endif
  else
    normal! q
    call setreg(g:qreg, substitute(getreg(g:qreg), "q$", "", ""))
  endif
endfunction

noremap q <Cmd>call RecordAndStop()<cr>
noremap Q <Cmd>execute 'normal! @'.g:qreg<cr>

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

" If this is the .vimrc, not a plugin, then load init.vim
if $MYVIMRC == expand('<sfile>:p')
  let $MYVIMRC = s:configdir . '/init.vim'
  source $MYVIMRC
endif

" See also:
" https://github.com/noahfrederick/vim-neovim-defaults/blob/master/plugin/neovim_defaults.vim
" https://neovim.io/doc/user/starting.html#startup
" https://neovim.io/doc/user/vim_diff.html
" https://github.com/vim/vim/blob/master/runtime/defaults.vim
" https://github.com/neovim/neovim/blob/master/src/nvim/os/stdpaths.c
" Options were partially determined by running ~/.config/dotfiles/nvim-diff.sh
" TODO:
" default-autocmds
" partial lua support (hard)

