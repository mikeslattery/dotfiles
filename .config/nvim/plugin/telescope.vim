" https://github.com/nvim-telescope/telescope.nvim

if has_key(g:plugs, 'telescope.nvim')
  noremap <leader>fb <cmd>Telescope buffers<cr>
  noremap <leader>m <cmd>Telescope oldfiles<cr>
  noremap <leader>fp <cmd>Telescope git_files<cr>
  noremap <leader>ff <cmd>Telescope find_files<cr>
  noremap <leader>fh <cmd>Telescope help_tags<cr>
  noremap <leader>fk <cmd>Telescope marks<cr>
  noremap <leader>fg <cmd>Telescope live_grep<cr>
  noremap <leader>fj <cmd>Telescope jumplist<cr>
  noremap <leader>fc :changes<cr>
elseif has_key(g:plugs, 'fzf.vim')
  noremap <leader>fb :Buffers<CR>
  noremap <leader>m :History<CR>
  noremap <leader>fp :GFiles<CR>
  noremap <leader>fk :Marks<CR>
  noremap <leader>fl :BLines<CR>
  if executable('rg')
    noremap <leader>fg :Rg<space>
  else
    noremap <leader>fg :grep<space>
  endif
  noremap <leader>fj :Jumps<cr>
  noremap <leader>fc :Changes<cr>

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
  noremap <leader>fb :CtrlPBuffer<cr>
  noremap <leader>m :CtrlPMRU<cr>
  noremap <leader>fp :CtrlP<cr>
  noremap <leader>fk :marks<cr>
  noremap <leader>fl /
  noremap <leader>fg :grep<space>
  noremap <leader>fj :jumps<cr>
  noremap <leader>fc :changes<cr>
else
  " no git or internet?
  noremap <leader>fb :ls<cr>:b<tab>
  noremap <leader>m :browse old<cr>
  noremap <leader>fp :find **<left>
  noremap <leader>fk :marks<cr>
  noremap <leader>fl /
  noremap <leader>fg :grep<space>
  noremap <leader>fj :jumps<cr>
  noremap <leader>fc :changes<cr>
endif

