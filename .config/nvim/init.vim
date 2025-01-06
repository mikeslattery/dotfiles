":" Running this as a bash script will install Neovim on Linux and update plugins
"exec" "$HOME/bin/nvim-upgrade"

" Requires: neovim or vim, curl or wget
" Optional: git, rg, fd, node, npm, watchman, tmux
" Optional Vim: fzf
" Unsupported: Windows gVim

" To update nvim: bash ~/.config/nvim/nvim.init

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
let g:plugs={}
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \| PlugUpdate --sync | source $MYVIMRC
  \| endif

call plug#begin()

if has('nvim')
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'folke/which-key.nvim'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'chentoast/marks.nvim'
  Plug 'ggandor/leap.nvim'
  Plug 'norcalli/nvim-colorizer.lua'

  Plug '~/src/my/genie'
  Plug '~/src/my/ax'
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
" silently run a shell command, and only show output on error
if has('nvim')
  function! g:Silent(cmdline)
    let l:result = execute('!' . a:cmdline)
    if l:result =~ 'shell returned'
      echo l:result
    endif
  endfunction
else
  function! g:Silent(cmdline)
    execute 
      \ 'silent !(' . a:cmdline .') || (echo -n "Hit enter: "; read)' 
    redraw!
  endfunction
endif
command! -nargs=1 Silent call g:Silent(<q-args>)

"TODO: ShellWrite, similar to :'<,'>:w ! but works without selection

" Execute command in terminal in new tab
function! s:Term(args)
  if has('nvim')
    tabnew
    execute 'terminal ' . a:args
    " no left gutter
    setlocal signcolumn=no
    setlocal norelativenumber
    setlocal nonumber
    " if no errors, auto-close
    autocmd! TermClose <buffer=abuf> if !v:event.status | exec 'bd! '..expand('<abuf>') | endif | checktime
    startinsert
  elseif has('terminal')
    " Vim 8
    execute 'tab terminal ++close ' . a:args
  else
    " Vim 7
    call s:Silent(a:args != '' ? a:args : $SHELL)
  endif
endfunction
command! -nargs=? Terminal call s:Term(<q-args>)

" Tab management

let g:lasttab = 1
autocmd TabLeave * let g:lasttab = tabpagenr()
nnoremap <Leader>tl :execute 'tabn ' . g:lasttab<cr>
" LUA equivalent:
" vim.g.lasttab = 1
" vim.api.nvim_create_autocmd("TabLeave", { pattern = "*", callback = function() vim.g.lasttab = vim.api.nvim_tabpage_get_number(0) end })
" vim.keyset.set('n', '<Leader>tl', '', function() vim.cmd.tabn(vim.g.lasttab) end)

nnoremap <Leader>t^ :tabn 1<cr>
nnoremap <Leader>tn :tabnext<CR>
nnoremap <Leader>tp :tabprev<CR>
nnoremap <Leader>tc :tabclose<CR>
nnoremap <Leader>t% :tabnew #<CR>

" code completion
vnoremap <leader>r<tab> :!{ echo $'Complete:\n```%:e'; cat; } \| gpt \| sed -n '/^```/, /^```/ { /```/ \!p; };'<cr>
" Inject last zsh command
nnoremap <leader>r$ : r !sed -rn '$ { s/^[^;]*;//; p; }' ~/.zsh_history<cr>
" Run line in shell and inject output
vnoremap <leader>r! y:'<,'>!tweak \| bash \| tweak<cr>P
nnoremap <leader>r! yy:.!bash<cr>P
nnoremap <leader>rw :up\|Silent pandoc % -o /tmp/vim.pdf<cr>
vnoremap <leader>rw :'<,'>w /tmp/vim.md\|Silent pandoc /tmp/vim.md -o /tmp/vim.pdf<cr>
nnoremap <leader>rp :Silent pomostart<cr>
nnoremap <leader>rd :Silent tmux-start debug<cr>
nnoremap <leader>rD :Silent tmux-start undebug<cr>
nnoremap <leader>rc :Silent md2rt-clip<cr>
vnoremap <leader>rc y:Silent md2rt-clip<cr>
nnoremap <leader>rv :Silent rt2md-clip<cr>p
nnoremap <leader>rf :Silent wtfs start-timer<space>
nnoremap <leader>rt :silent !tmux send-keys -t 'top:0.1' '' Enter<S-left><left><left>
nnoremap <leader>rt :silent !tmux send-keys -t 'top:0.1' '' Enter<left><left><left><left><left><left><left>
nnoremap <leader>rl :execute('silent !tmux send-keys -t "top:0.1" "' . escape(getline("."), '$"!\') . '" Enter')<cr>
nnoremap <leader>rX j?test('<cr>"+yi'<c-o>k:!tmux send-keys -t 'top:0.1' 'jest "%" -t "<c-r>+"' Enter<cr>
nnoremap <leader>rr :echo system("cut -c16- ~/.zsh_history \| fzf --tac")<cr>
vnoremap <leader>rs y:execute 'silent !xsel -o -b\|ssh phone termux-tts-speak &'<cr>
"TODO: vnoremap <leader>rs :'<,'>:w !ssh phone termux-tts-speak<cr>
"TODO: vnoremap <leader><leader>q :<c-U>execute '!tmux send-keys -t 1 "'.escape(join(getline(getpos("'<")[1],getpos("'>")[1]), "\n"), '"#').'" Enter'<cr>
" ignore any further error formats.  (hopefully this doesn't break any plugins)
set errorformat+=%-G%.%#

" SESSION AND CONFIG MANAGEMENT
nnoremap <leader>r. :execute getline('.')<CR>j
nnoremap <leader>ra :source $MYVIMRC<CR>
nnoremap <leader>ru :PlugUpdate --sync\|PlugUpgrade\|CocUpdateSync<cr>
" Needed for coc-explorer
set sessionoptions-=blank
set sessionoptions+=terminal
" set sessionoptions-=help
" set sessionoptions+=options
" load source.  Save current first, and remember the filename for Obsession

" State management.  Use cases:
" nvim -S           # global state
" nvim              # Won't save global session on exit
" nvim +State       # local directory project
" :ChProject <dir>  # Change/Set project
" :Source <file>    # Change session
" :SaveState        # Save (in case of crash)

" Load another session and update it on exit.
command! -complete=file -nargs=1 Source call s:Source(<f-args>)
function! s:Source(file)
  call s:SaveSession()
  if filereadable(a:file)
    execute 'source ' . a:file
  endif
  let v:this_session = a:file
endfunction
autocmd VimLeavePre * call s:SaveState()
autocmd FocusLost * call SaveStateTimer(0)

" Set Project
function! s:SetProject(dir)
  " TODO: source before <cwd>/.vim/leaverc, after <dir>/.vim/vimrc
  " TODO: .vim/.gitignore with main.shada .viminfo, if none
  let s:session_dir  = a:dir . '/.vim/sessions/'
  call s:Source(s:session_dir . 'Session.vim')
  if has('nvim')
    set shadafile=.vim/main.shada
  else
    set viminfofile=.vim/.viminfo
  endif

  " project specific config
  if filereadable(a:dir . '/.vim/.nvimrc')
    execute 'source ' . a:dir . '/.vim/.nvimrc'
  endif
  " Ignore in project
  if ! filereadable(a:dir . '/.vim/.gitignore')
    call writefile(['*', ''], a:dir . '/.vim/.gitignore', 'b')
  endif
endfunction
command! -nargs=1 -complete=dir ChProject call s:ChProject(<f-args>)
function! s:ChProject(dir)
  call s:SaveState()
  call s:SetProject(a:dir)
  rviminfo!
endfunction

" Save state
command! -nargs=0 SaveState call s:SaveState()
function! SaveStateTimer(tid)
  call s:SaveSession()
  wviminfo!
endfunction
function! s:SaveState()
  call SaveStateTimer(0)
endfunction
function s:SaveSession()
  if !empty(v:this_session)
    execute 'mksession! ' . v:this_session
  endif
endfunction

call timer_start(30 * 60000, function('SaveStateTimer'), {'repeat': -1})

" Init.
if index(v:argv, '+State') >= 0
  " To start in a project: nvim +State
  call s:SetProject(getcwd())
  " no-op
  command! -nargs=0 State execute ''
else
  let s:session_dir = s:data_dir . '/sessions/'
endif
call mkdir(s:session_dir, 'p')

" Switch projects and sessions
execute 'nnoremap <leader><leader>s :mksession! ' . s:session_dir
execute 'nnoremap <leader><leader>r :Source '     . s:session_dir
nnoremap <leader><leader>c :ChProject ~/src/

nnoremap <leader><leader>w :update\|silent! make -s\|redraw!\|cc<cr>
nnoremap <leader><leader>q :execute 'silent !tmux send-keys -t 1 "'.escape(getline('.'), '"#').'" Enter'<cr>:redraw!<cr>

" Simulate tmux widnows/panes
nnoremap <c-w><c-^> <c-w>p
" splits
nnoremap <c-w>% <c-w>v<c-w>l:bp<cr>
nnoremap <c-w>" <c-w>s<c-w>j:bp<cr>
" resize
nnoremap <c-w><c-left> <c-w>>
nnoremap <c-w><c-right> <c-w><
nnoremap <c-w><c-up> <c-w>-
nnoremap <c-w><c-down> <c-w>+
nnoremap <c-w>z :tabnew #<cr>

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
nnoremap <leader>x :bn\|bd#<CR>
inoremap <M-x> <esc>ZZ
nnoremap <M-x> ZZ
"   browse files in same dir as current file
function! g:DeleteThisFile()
  update
  call mkdir('/tmp/vim', 'p')
  execute 'silent !mv '.expand('%').' /tmp/vim/'.expand('%:t')
  bp
  bdelete #
endfunction
noremap <leader><leader>rm <Cmd>call g:DeleteThisFile()<cr>
noremap <leader><leader>grm <Cmd>exec 'silent !git rm '.expand('%')\|bdelete!<CR>
" select all
nnoremap <leader>ga ggyG<c-o>
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
noremap <leader>d ""d
noremap c ""c
noremap x "_x
nnoremap <leader>q @q

set clipboard=unnamedplus
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

" CREATE/SAVE FILES
nnoremap <leader><leader>t :exec "e ".system('mktemp -p /var/tmp --suffix=.md')<cr>
nnoremap <leader>w :up<CR>
nnoremap <leader>W :wa<CR>
nnoremap <c-s> :up<cr>
set autoread
set hidden
set undofile
set noswapfile
set backup
let &backupdir = s:data_dir . '/backup//'

" file type mappings
autocmd BufRead,BufNewFile Dockerfile setlocal filetype=sh

" On save, if the file starts with shebang and isn't already executable,
" run !chmod +x % and reload
augroup make_executable
  autocmd!
  autocmd BufWritePost * if getline(1) =~ "^#!" && !executable(expand('%')) 
    \ | execute 'silent !chmod +x %'
    \ | call timer_start(100, 'TimerEdit', {'repeat': -1})
    \ | endif
augroup END
function! TimerEdit(timer)
  if expand('%') != ''
    edit %
  endif
endfunction

vnoremap <leader>r. y<cmd>execute substitute(@", '\n *\(\\ \|\)\?', ' \| ', 'gm')<cr>

" AI
augroup ai
  autocmd!
  autocmd BufRead,BufNewFile *.gpt
    \ setlocal filetype=markdown
    \ | nnoremap <leader>rw :up\|execute 'silent !~/src/ai/mdgpt '.expand('%')\|e<cr>
    \ | nnoremap <leader>ra Go><space>
    \ | nnoremap <silent> <leader>rv ?```<cr>kVnj
augroup END
" TODO:
" In insert mode, while in a quote block, auto-indent with `< `

vnoremap <leader>rs :w! /tmp/mimic \| silent !mimic3 < /tmp/mimic<cr>

nnoremap <M-v> <cmd>r !vtt<cr>
inoremap <M-v> <c-o><cmd>execute "normal! i". system("vtt")<cr>
" Perform AI on selected text
vnoremap <M-v> :'<,'>!set -euo pipefail; { vtt \| tweak; echo 'The text: '; cat; } \| noprompt gpt<cr>
nnoremap <M-v> <cmd>r !vtt<cr>
" TODO:
" ask GPT a question and it answers

augroup md
  autocmd!
  autocmd FileType markdown setlocal spell
  autocmd BufRead /tmp/tuir_*.txt
    \ setlocal filetype=markdown
    \ | silent! execute '1 | /Enter your reply below/,/link text/ d _'
    \ | silent! execute '%s/^  |/> /'
    \ | execute 'normal Go'
    \ | nnoremap <leader>Q :u0<cr>:wq<cr>
augroup END
" TODO: 
" If replying to the same comment again, after a failure, reload prior comment

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
nnoremap <LeftMouse> m'<LeftMouse>
" double click check box
"TODO: uncheck. autocmd md. only check if brackets.  single click
"nnoremap <2-LeftMouse> rx
"TODO: remove jk
inoremap jk <esc>
nnoremap <C-Space> i
nnoremap <C-@> i
inoremap <C-Space> <Esc>
inoremap <C-@> <Esc>
inoremap <C-c> <esc>

nnoremap <leader>zn :setlocal relativenumber! number<CR>
nnoremap <leader>zN :setlocal norelativenumber nonumber<CR>
nnoremap <leader>zs :setlocal spell!<CR>
nnoremap <leader>zb :setlocal breakindent!<CR>
nnoremap <silent> <leader>z= z=1<cr><cr>
nnoremap <leader>zm :setlocal showmatch!<CR>
nnoremap <leader>zw :setlocal wrap!<CR>
nnoremap <leader>zl :setlocal list!<CR>
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

" Open marks A-E in new windows
nnoremap <leader>vg :silent vsplit\|wincmd l\|execute "normal 'A"\|split\|wincmd j\|execute "normal 'B"\|split\|wincmd j\|execute "normal 'C"\|split\|wincmd j\|execute "normal 'D"\|split\|wincmd j\|execute "normal 'E"\|wincmd h<cr>
" Close marks A-E windows.  (right, 5 close)
noremap <leader>,vG :wincmd l\|wincmd c\|wincmd c\|wincmd c\|wincmd c\|wincmd c<cr>
noremap <leader>vR ,vG,vg


" luafile ~/.config/nvim/plugin/shell.lua
" luafile ~/.config/nvim/config.lua



"TODO
" next
"   run inline code
"     invoke the right runtime, based on filetype
"     use environment.  imports, libraries
"     vnoremap <leader>r! y:'<,'>!bash<cr>P
"     nnoremap <leader>r! yy:.!bash<cr>P
"   [m, ]m -  [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects#text-objects-move)
"   unit tests
"     RED/GREEN status
"   status line
"     better plugin
"     base file name, line number, diagnostics count+color
"   mini scripts
"     convert link in clipboard to markdown link (:r !~/bin/mdlink)
"     show current markdown in browser  (pandoc, xdg-open)
"     save live preview: pdf, docx, 
"   mini commands
"     remove buffers that don't have existing files
"   startup
"     after start, remove buffers that don't have existing files
"   https://github.com/michaelb/sniprun
"   https://github.com/nvim-treesitter/nvim-treesitter-context
"   Find better alternative: https://github.com/hotoo/jsgf.vim/blob/master/doc/jsgf.txt
"   checktime on autocmd focus
"     https://github.com/tmux-plugins/vim-tmux-focus-events
"     https://stackoverflow.com/a/20418591
"   markdown
"     https://github.com/dkarter/bullets.vim
"     https://www.reddit.com/r/linuxquestions/comments/ye0n93/comment/itwlqi5/
"     https://github.com/iamcco/markdown-preview.nvim
"   galaxyline
"   css plugin in lua + tree sitter
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
" Smart yank plugin
"   On TextYankPost autocmd, record filetype
"   On paste, detect if different filetypes and see what can be done
"     if in:code out:markdown, insert code block, unindented
"     if in:lua out:vimscript, put into lua block
"     if in:vimscript out:lua, put into vim.cmd multi-line string
"     if in:javascript out:html, stript tag, unless already in one
"     if incompatible code langs, put into multi-line string
"     Various pandoc in/out formats
"   Multiline, single string sytax for various languages
"   Smart translation
"     Use GPT3 to translate
"     code-to-code
"   Pop-up for conversion type
"     types: gpt, string embed, language-in-language embed
"   Extensible combinations
"     Alias group arrays (js:js,ts,jsx)
"   References
"     https://github.com/Perthys/LuaOpenAI
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
" ec, fixme/todo search pre-push hook
" telescope extension or PR
"   bash picker: search(text), preview(), pick(text)
"   git status, exlude index.  git diff --name-only --diff-filter=AM -- .
"   telescope-npm - run commands, find packages
"   changes, based off jumps
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
"   ALE? Neovim?
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


