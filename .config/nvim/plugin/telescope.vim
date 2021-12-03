" https://github.com/nvim-telescope/telescope.nvim

if has_key(g:plugs, 'telescope.nvim')
  noremap <leader>b <cmd>Telescope buffers<cr>
  if executable('fd')
    noremap <leader>ff <cmd>Telescope fd<cr>
  else
    noremap <leader>ff <cmd>Telescope find_files<cr>
  endif
  noremap <leader>m <cmd>Telescope oldfiles<cr>
  noremap <leader>fp <cmd>Telescope git_files<cr>
  noremap <leader>fh <cmd>Telescope help_tags<cr>
  noremap <leader>fg <cmd>Telescope live_grep<cr>
  noremap <leader>g' <cmd>Telescope marks<cr>
  noremap <leader>gj <cmd>Telescope jumplist<cr>
  noremap <leader>gc :changes<cr>
  noremap <leader>gl <cmd>Telescope current_buffer_fuzzy_find<cr>

  lua require('telescope').load_extension('coc')
elseif has_key(g:plugs, 'fzf.vim')
  noremap <leader>b :Buffers<CR>
  noremap <leader>m :History<CR>
  noremap <leader>fp :GFiles<CR>
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
  noremap <leader>b :CtrlPBuffer<cr>
  noremap <leader>m :CtrlPMRU<cr>
  noremap <leader>fp :CtrlP<cr>
  noremap <leader>gl /
  noremap <leader>g' :marks<cr>
  noremap <leader>fg :grep<space>
  noremap <leader>gj :jumps<cr>
  noremap <leader>gc :changes<cr>
else
  " no git or internet?
  noremap <leader>b :ls<cr>:b<space>
  noremap <leader>m :browse old<cr>
  noremap <leader>fp :find<space>
  noremap <leader>gl /
  noremap <leader>fg :grep<space>
  noremap <leader>g' :marks<cr>
  noremap <leader>gj :jumps<cr>
  noremap <leader>gc :changes<cr>
endif

