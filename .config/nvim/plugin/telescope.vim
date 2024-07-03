" https://github.com/nvim-telescope/telescope.nvim

if has_key(g:plugs, 'telescope.nvim')

  " Search word under cursor
  nnoremap <leader>* <cmd>execute 'normal yiw' \| lua require('telescope.builtin').live_grep({default_text = vim.fn.getreg()})<cr>
  " Search selected text
  vnoremap <leader>* <cmd>lua vim.cmd('noau normal! "vy"');require('telescope.builtin').live_grep({default_text = vim.fn.getreg("v")})<cr>

  noremap <leader>fb <cmd>lua require('telescope.builtin').buffers({sort_mru=true})<cr>
  noremap <leader>b <cmd>lua require('telescope.builtin').buffers({sort_mru=true, ignore_current_buffer=true, show_all_buffers=false})<cr>
  noremap <leader>B <cmd>lua require('telescope.builtin').buffers({sort_mru=true, ignore_current_buffer=true, show_all_buffers=true})<cr>
  if executable('fd')
    noremap <leader>ff <cmd>Telescope fd<cr>
  else
    noremap <leader>ff <cmd>Telescope find_files<cr>
  endif
  noremap <leader>fm <cmd>Telescope oldfiles<cr>
  " TODO: do not show directories (netrw).  Only show files
  noremap <leader>m <cmd>lua require('telescope.builtin').oldfiles({only_cwd=true})<cr>
  if g:hasgit
    if has_key(g:plugs, 'coc.nvim')
      noremap <leader>e :CocCommand explorer<cr>
      noremap <leader>fq :Telescope coc workspace_diagnostics<cr>
      lua require('telescope').load_extension('coc')
    endif
    noremap <leader>fp <cmd>Telescope git_files<cr>
  else
    noremap <leader>e :let @/=expand('%:t')<cr>:Explore<cr>
    noremap <leader>fp <cmd>Telescope find_files<cr>
    noremap <leader>fq :copen<cr>
  endif
  noremap <leader>fT <cmd>Telescope builtin<cr>
  noremap <leader>fg <cmd>Telescope live_grep<cr>
  noremap <leader>f. <cmd>Telescope resume<cr>
  noremap <leader>g' <cmd>Telescope marks<cr>
  noremap <leader>gj <cmd>Telescope jumplist<cr>
  noremap <leader>vj <c-w>v<c-w>p:Telescope jumplist<cr>
  noremap <leader>v' <c-w>v<c-w>p:Telescope marks<cr>
  noremap <leader>vk <Cmd>Telescope keymaps<cr>
  noremap <leader>vh :execute 'tab help'\|Telescope help_tags<cr>
  noremap <leader>gc :changes<cr>
  noremap <leader>gl <cmd>Telescope current_buffer_fuzzy_find<cr>

elseif has_key(g:plugs, 'fzf.vim')
  noremap <leader>e :let @/=expand('%:t')<cr>:Explore<cr>
  noremap <leader>b :Buffers<CR>
  noremap <leader>fq :copen<cr>
  noremap <leader>m :History<CR>
  if g:hasgit
    noremap <leader>fp :GFiles<CR>
  else
    noremap <leader>fp :Files<CR>
  endif
  noremap <leader>ff :Files<CR>
  noremap <leader>g' :Marks<CR>
  noremap <leader>gl :BLines<CR>
  noremap <leader>gj :Jumps<cr>
  if executable('rg')
    noremap <leader>fg :Rg<space>
  else
    noremap <leader>fg :grep<space>
  endif
  noremap <leader>gc :Changes<cr>

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

elseif has_key(g:plugs, 'ctrlp.vim')
  noremap <leader>e :let @/=expand('%:t')<cr>:Explore<cr>
  noremap <leader>b :CtrlPBuffer<cr>
  noremap <leader>m :CtrlPMRU<cr>
  noremap <leader>fq :copen<cr>
  noremap <leader>fp :CtrlP<cr>
  noremap <leader>ff :CtrlP<cr>
  noremap <leader>gl /
  noremap <leader>g' :marks<cr>
  noremap <leader>fg :grep<space>
  noremap <leader>gj :jumps<cr>
  noremap <leader>gc :changes<cr>
else
  " no git or internet?
  noremap <leader>e :let @/=expand('%:t')<cr>:Explore<cr>
  noremap <leader>b :ls<cr>:b<space>
  noremap <leader>m :browse old<cr>
  noremap <leader>fq :copen<cr>
  noremap <leader>fp :find<space>
  noremap <leader>ff :find<space>
  noremap <leader>gl /
  noremap <leader>fg :grep<space>
  noremap <leader>g' :marks<cr>
  noremap <leader>gj :jumps<cr>
  noremap <leader>gc :changes<cr>
endif

" Universal

"   browse files in project dir
nnoremap <leader>fe :Explore .<cr>
nnoremap <leader>ft :checktime<CR>
nnoremap <leader>vc <c-w>h<c-w>c
nnoremap <leader>vM :silent !meld . &<cr>
nnoremap <leader>vZ :Term lazygit<cr>
" Create file in directory of buffer
nnoremap <leader>fd :e %:h/
" Internet search
noremap <leader>vC :r !curl -s 'https://cheat.sh/?T'<left><left><left>
noremap <leader>vD :Term ddgr<space>
noremap <leader>vO :Term socli<space>
