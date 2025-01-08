" COC AND ALE CUSTOM CONFIGURATION

set wildmode=longest:list,full

if !has_key(g:plugs, 'coc.nvim')
  finish
endif

" Avoid conflicts with ALE
" it might be better to disable for coc file types
" see https://github.com/dense-analysis/ale#faq-coc-nvim
let g:ale_disable_lsp = 1

autocmd User EasyMotionPromptBegin silent! CocDisable
autocmd User EasyMotionPromptEnd   silent! CocEnable

noremap <leader>aR <Cmd>CocRestart<cr>
map <leader>an <Plug>(coc-rename)
map <leader>ar <Plug>(coc-refactor)

" coc-css
autocmd FileType scss setl iskeyword+=@-@

"TODO: nnoremap <leader>fl :CocList<cr>
"To search> :CocList marketplace

let g:coc_global_extensions = [
  \ 'coc-lists',
  \ 'coc-marketplace',
  \ 'coc-eslint',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-cssmodules',
  \ 'coc-json',
  \ 'coc-yaml',
  \ 'coc-explorer',
  \ 'coc-vetur',
  \ 'coc-tsserver',
  \ 'coc-helper',
  \ 'coc-tailwindcss',
  \ 'coc-python',
  \ ]
"  \'coc-prettier',
"  \'coc-jest',
"  \'coc-graphql',
"  \'coc-git',
"  \'coc-emmet',
"  \'coc-snippets',
"  \'coc-sh',
"  \'coc-markdownlint',
"  \'coc-toml',
"  \'coc-go',
"  \'coc-fzf-preview',
"  \'coc-fzf',
"  \'coc-yank',
"  \'coc-diagnostic',
"  \'coc-tasks',
"  \'coc-java',
"  \'coc-pyright',
"  \'coc-cmake',
"  \'coc-calc',
"  \'coc-tabnine',
"  \'coc-clangd',
"  \'coc-translator',
"  \'coc-docker',
"  \'coc-kotlin',
"  \'coc-pairs',


"TODO: coc-snippets
"TODO: coc-list working like fzf
" https://www.reddit.com/r/neovim/comments/ejznuz/what_do_your_coc_settings_look_like/
"{
"  "coc.preferences.useQuickfixForLocations": true,
"  "coc.preferences.snippets.enable": true,
"  "coc.preferences.extensionUpdateCheck": "never",
"  "suggest.disableMenu": true,
"  "suggest.snippetIndicator": ""
"}

