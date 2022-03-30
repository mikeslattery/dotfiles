":" This will install NeoVim on Linux and update plugins
"export" nvim="$HOME/.local/bin/nvim"
"export" nvimurl="https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage"
"set" -xeu
"curl" -fL "$nvimurl" -o "$nvim" -z "$nvim"
"chmod" u+x "$nvim"
"$nvim" +PlugUpgrade +'PlugUpdate --sync'
"exit" 0

" Requires: neovim or vim, curl or wget
" Optional: git, fzf, rg, fd, node, watchman
" Unsupported: Windows gVim

" To update nvim: bash ~/.config/nvim/nvim.init
" nvim can't be in use during this.

if has('nvim')
  " This function should have been declared in ~/.vimrc
  function! Stdpath(id)
    return stdpath(a:id)
  endfunction
endif

let g:hasgit=!empty(glob('.git')) && executable('git')

" Autoinstall plugin manager
let s:data_dir     = Stdpath('data')
let g:plug_home    = s:data_dir . '/plugged'
let s:autoload_dir = s:data_dir . '/site/autoload'
let s:plugvim_file = s:autoload_dir . '/plug.vim'
if empty(glob(s:plugvim_file))
  call  mkdir(s:autoload_dir, 'p')
  let s:plugurl= 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  execute 'silent !curl -fsLo '.s:plugvim_file.' '.s:plugurl
    \ .' ||        wget -q -O '.s:plugvim_file.' '.s:plugurl
endif
" Install missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \| PlugUpdate --sync | source $MYVIMRC
  \| endif
let g:plugs={}

call plug#begin()

if has('nvim')
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'folke/which-key.nvim'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'chentau/marks.nvim'
  Plug 'ggandor/lightspeed.nvim'
  Plug 'norcalli/nvim-colorizer.lua'
else
  if executable('fzf')
    Plug 'junegunn/fzf.vim'
  else
    Plug 'ctrlpvim/ctrlp.vim'
  endif
  Plug 'kshenoy/vim-signature'
  Plug 'liuchengxu/vim-which-key'
  Plug 'easymotion/vim-easymotion'
  Plug 'unblevable/quick-scope'
  Plug 'ap/vim-css-color'
endif
Plug 'jiangmiao/auto-pairs'

if exists('$TMUX')
  Plug 'christoomey/vim-tmux-navigator'
endif

" Required for tmux-continuum
Plug 'tpope/vim-obsession'

if g:hasgit
  Plug 'airblade/vim-gitgutter'
  Plug 'tpope/vim-fugitive'

  if executable('node') && get(g:, 'coc_enabled', 1)
    " To disable: nvim --cmd 'let g:coc_enabled=0'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    if has_key(g:plugs, 'telescope.nvim') && has_key(g:plugs, 'coc.nvim')
      Plug 'fannheyward/telescope-coc.nvim'
    endif
  else
    Plug 'dense-analysis/ale'
  endif
endif
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'bling/vim-airline'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

call plug#end()

" MY CUSTOM STUFF "
" See:
"   http://dougblack.io/words/a-good-vimrc.html

let mapleader=','
let maplocalleader=mapleader

" EXECUTION
" silently run a command, and only show output on error
if has('nvim')
  command! -nargs=1 Silent execute 'silent !(' . <q-args> .')'
else
  command! -nargs=1 Silent execute 'silent !(' . <q-args> .') || (echo Hit enter:; read)' | execute 'redraw!'
endif
nnoremap <leader>rm :update\|Silent pandoc % -o /tmp/vim.pdf<cr>
nnoremap <leader>rp :Silent pomostart<cr>
nnoremap <leader>rr :echo system("cut -c16- ~/.zsh_history \| fzf --tac")<cr>
"TODO: vnoremap <leader><leader>q :<c-U>execute '!tmux send-keys -t 1 "'.escape(join(getline(getpos("'<")[1],getpos("'>")[1]), "\n"), '"#').'" Enter'<cr>
" ignore any further error formats.  (hopefully this doesn't break any plugins)
set errorformat+=%-G%.%#

" SESSION AND CONFIG MANAGEMENT
nnoremap <leader>r. :execute getline('.')<CR>
nnoremap <leader>ra :source $MYVIMRC<CR>
nnoremap <leader>ru :PlugUpdate --sync\|PlugUpgrade\|CocUpdateSync<cr>
" load source.  Save current first, and remember the filename for Obsession
function! s:Source(file)
  if !empty(v:this_session)
    mksession! v:this_session
  endif
  execute 'source ' . a:file
  let v:this_session = a:file
  let v:this_obsession = a:file
endfunction
command! Source -complete=file -nargs=1 execute s:Source(<f-args>)
if g:hasgit
  " save session and state locally
  let s:session_dir = '.vim/sessions/'
  let v:this_session=s:session_dir . 'Session.vim'
  if has('nvim')
    set shadafile=.vim/main.shada
  else
    set viminfofile=.vim/.viminfo
  endif
  if filereadable(v:this_session)
    execute 'source ' . v:this_session
  endif
else
  let s:session_dir = s:data_dir . '/sessions/'
endif
call mkdir(s:session_dir, 'p')
" use alternate session file
execute 'nnoremap <leader><leader>s :mksession! ' . s:session_dir
execute 'nnoremap <leader><leader>r :Source '     . s:session_dir
autocmd VimEnter * if ObsessionStatus('on', 'off') == 'off' | Obsession | endif
nnoremap <leader><leader>w :update\|silent! make -s\|redraw!\|cc<cr>
nnoremap <leader><leader>q :execute 'silent !tmux send-keys -t 1 "'.escape(getline('.'), '"#').'" Enter'<cr>:redraw!<cr>

" WHITESPACE
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smartindent
set breakindent

" SEARCHING FOR FILES
set showmatch
nnoremap <leader>/ :noh<cr>
set incsearch
set ignorecase
set smartcase
set nowrapscan
nnoremap <leader>i :execute "update\|silent !curl -fs 'http://localhost:63342/api/file/".expand("%")."?line=".line(".")."&column=".col(".")."'"\|redraw!<cr>

"TODO: what? vnoremap <leader>c :I#<ESC><C-i>
"   close current buffer
nnoremap <leader>x :bd<CR>
"   browse files in same dir as current file
nnoremap <leader><leader>rm :call delete(expand('%'))\|bdelete!<CR>
nnoremap <leader><leader>grm :silent !git rm %\|bdelete!<CR>
if g:hasgit
  let s:hide=netrw_gitignore#Hide()
  let s:hide.=',.git/,yarn.lock,package-lock.json'
  let s:hide=substitute(s:hide, '.env,', '', '')
  let g:netrw_list_hide=s:hide
  let &wildignore=substitute(g:netrw_list_hide, '/,', '/*,' ,'g')
  let &path=system('git ls-files | xargs -r dirname | sort -u | sed "s|/\\?$|/\\*|;" | paste -sd , -')
else
  set wildignore=**/.git/*
  set path=**
endif

let g:netrw_home=s:data_dir
" Toggle banner with: I
let g:netrw_banner=0
" Toggle style with: i
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
noremap <c-w><c-^> <c-w>p
noremap <leader>d "-d
nnoremap <leader>q @q

set clipboard=unnamed,unnamedplus
" ctrl-backspace to delete previous word
if has('gui_running') || has('nvim')
  inoremap <C-bs> <C-w>
  cnoremap <C-bs> <C-w>
else
  inoremap <C-h> <C-w>
  cnoremap <C-h> <C-w>
endif
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
nnoremap <leader>h :rightbelow vertical help<space>
nnoremap <leader><leader>l :call term_sendkeys(bufnr($SHELL),getline('.') . "\n")<cr>

" CREATE/SAVE FILES
nnoremap <leader><leader>t :exec "e ".system('mktemp -p /var/tmp')<cr>
nnoremap <leader>w :up<CR>
set autoread
set hidden
set undofile
set noswapfile
set backup
let &backupdir = s:data_dir . '/backup//'

" file type mappings
autocmd BufRead,BufNewFile Dockerfile setlocal filetype=sh
autocmd FileType markdown setlocal spell

" remove trailing spaces on save
"autocmd BufWritePre * %s/\s\+$//e

" BROWSING TEXT
set nofoldenable
set foldmethod=indent
set foldcolumn=1
set foldlevelstart=99
set foldnestmax=10
set foldlevel=2
" :help ft-markdown-plugin
let g:markdown_folding=1
set scrolloff=3
set mouse=a
" double click check box
"TODO: uncheck. autocmd md. only check if brackets.  single click
nnoremap <2-LeftMouse> rx
"TODO: remove jk
inoremap jk <esc>
nnoremap <C-Space> i
nnoremap <C-@> i
inoremap <C-Space> <Esc>
inoremap <C-@> <Esc>
inoremap <C-c> <esc>

nnoremap <leader>zn :set relativenumber!<CR>
nnoremap <leader>zs :set spell!<CR>
nnoremap <leader>zb :set breakindent!<CR>
nnoremap <silent> <leader>z= z=1<cr><cr>
nnoremap <leader>zm :set showmatch!<CR>
nnoremap <leader>zw :set wrap!<CR>
nnoremap <leader>zl :set list!<CR>
nnoremap <leader>zg :GitGutterToggle<CR>
set number
set relativenumber
set wrap linebreak nolist
set tw=480
if has('nvim')
  set signcolumn=yes:2
endif
" stay centered
nnoremap n nzzzv
nnoremap N Nzzzv
" add to jumplist on relative moves
nnoremap <expr> j (v:count > 5 ? "m'" . v:count . "j" : "j")
nnoremap <expr> k (v:count > 5 ? "m'" . v:count . "k" : "k")
nnoremap ]m ]mzz
nnoremap [m [mzz
nnoremap [M [Mzz
nnoremap ]M ]Mzz

"TODO
" next
"   zt goes to 1, but it should have a top margin
"   folds - autocmd - md indent, code treesitter
"   yaml - on comment don't autoindent so much.  treesitter?
"   checktime on focus.  test focus
"   cheat
"      execute "r!curl -s 'https://cht.sh/".&filetype."/".substitute(input("Query: "), ' ', '+', 'g')."?qT'"
"   coc
"     try out coc-action, coc-highlight, coc-snippet
"   airline
"     lua?
"     keep: mode, branch, lines, filename
"     shorten: base filename
"     add nav: ctrl-6 basename, jump index, c-o line num, marks
"     add status: unit test color, diagnostics, git status, toggles (spell, wrap)
"   editorconfig-vim
"   telescope buffers sort_mru
"   https://github.com/windwp/nvim-ts-autotag
"   https://alpha2phi.medium.com/neovim-for-beginner-auto-pairs-c09e87a4d511
"     nvim-autopairs, nvim-ts-autotag, nvim-treesitter-endwise
"   harpoon, marks.nvim, and/or mark-radar.nvim
"   coc-git or gitsigns
"   tabout
"   lightspeed?
"   vista
"   git-messenger (blame)
"   refactoring plugins in src/research/nvim
"   better plan out leader mappings
"     f - files
"     c - change text
"     g - movements
"       see telecope.vim
"       j,c  - jumps, changes
"     z - display
"     c-w - windows
"     a - actions
"     r - run
"     [] - forward/backward
" ftFT helpers
"   shot-f, quick-scope
"   sneak
" telescope sort buffers
"   https://github.com/nvim-telescope/telescope.nvim/blob/nvim-0.5.1/doc/telescope.txt#L1182
"   https://github.com/nvim-telescope/telescope.nvim/issues?q=sort_mru
" Q for vim
"   let s:lastreg = '@'
"   let s:recording=''
"   function! s:MacroToggle()
"     let s:recording = v:version < 800 ? s:recording : reg_recording()
"     if s:recording == ''
"       let s:recording = substitute(getcharstr(), '[^A-Za-z0-9"]', '', 'g')
"       return s:recording == '' ? '' : 'q'.s:recording
"     else
"       let s:lastreg = s:recording
"       let s:recording = ''
"       return 'q'
"     endif
"   endfunction
"
"   nnoremap q <silent> <expr> s:MacroToggle()
"   nnoremap Q <silent> <expr> '@'.s:lastreg
" firefox
"   https://github.com/glacambre/firenvim
" markdown
"   https://github.com/vim-pandoc/vim-pandoc-syntax
"   on paste, convert github urls to links
"   on paste of link, get title
" hop config (or lightspeed)
"   Plug 'phaazon/hop.nvim'
"   https://github.com/phaazon/hop.nvim/issues/198
"   hop.lua
"   F, T
"   consistent keys?
"   never autojump
" ec, fixme/todo search pre-commit hook
" next - telescope extension or PR
"   changes, based off jumps
"   buffers in mru order - look at fzf.vim
" next - coc/ale
"   see how to get ale and coc to live together
"   put autoinstall stuff into plugin/
"   remove anything here that's also in ~/.vimrc
"     including directories
"     remove g:data_dir stuff.  we are all-in for neovim
"   use s: for let vars here
"   ale example: https://github.com/mantoni/dotfiles/blob/master/.vimrc
"   vim-airline - Green/Red on success/failure of ec,lint,tests
" native lsp
"   ALE? NeoVim?
"   nvim-lspconfig
"   eslint_d
" learn
"   y/<search>/e
"   C-x C-n   (insert mode)
"   gv - re-highlight
" vimrc
"   execute 'silent !fzf > /tmp/file.txt'| if v:shell_error !=0 | echo readfile('/tmp/file.txt')[0] | endif
" neovim/coc
"   telescope (replace fzf)
"     remap like fzf
"   hop (vs easymotion)
" packaged
"   NvChad
"   Doom.nvim
"   lunarvim
" Refactoring
"   https://github.com/ThePrimeagen/refactoring.nvim
"   https://www.youtube.com/watch?v=Qb7v1MZSrFc
"   https://github.com/LucHermitte/vim-refactor
" Debugging
"   https://github.com/mfussenegger/nvim-dap
"   https://github.com/puremourning/vimspector
" Tabs
"   tabs: help, code, tdd, page
"   page tab:
"     left: component.vue
"     right top: page.vue
"     right bottom: model
"   tdd tab: keep windows in sync
"     left: test
"     right: code
"     bottom: quickfix
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
"  quick-scope
"  terminus, fugitive, surround, tagbar,
"  indent-blanklines
"  repeat
"  neovim lsp-config
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
" if filereadable('package.json') && g:hasgit
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
" apps: tig, ranger

"TODO: put at top
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

