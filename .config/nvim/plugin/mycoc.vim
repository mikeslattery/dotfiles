" COC AND ALE CUSTOM CONFIGURATION


if !has_key(g:plugs, 'coc.nvim')
  finish
endif

" Avoid conflicts with ALE
" it might be better to disable for coc file types
" see https://github.com/dense-analysis/ale#faq-coc-nvim
let g:ale_disable_lsp = 1

" coc-css
autocmd FileType scss setl iskeyword+=@-@

"TODO: nnoremap <leader>fl :CocList<cr>

let g:coc_global_extensions = [
  \'coc-tsserver',
  \'coc-vetur',
  \'coc-lists',
  \'coc-eslint',
  \'coc-html',
  \'coc-css',
  \'coc-jest',
  \'coc-json',
  \'coc-prettier',
  \'coc-yaml',
  \'coc-pairs',
  \'coc-explorer',
  \ ]
"  \'coc-graphql',
"  \'coc-git',
"  \'coc-snippets',
"  \'coc-sh',
"  \'coc-markdownlint',
"  \'coc-toml',
"  \'coc-go',
"  \'coc-fzf-preview',
"  \'coc-fzf',
"  \'coc-explorer',
"  \'coc-yank',
"  \'coc-diagnostic',
"  \'coc-emmet',
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


"TODO: coc-snippets
"TODO: coc-list working like fzf
"{
"  "coc.preferences.useQuickfixForLocations": true,
"  "coc.preferences.snippets.enable": true,
"  "coc.preferences.extensionUpdateCheck": "never",
"  "suggest.disableMenu": true,
"  "suggest.snippetIndicator": ""
"}

