function! CopyIntoComponent()
  "normal d
  let filename = input('New Component: ')
  "execute 'edit components/' . filename . '.vue'
  "normal i<template><cr><div><cr><esc>Po</div></template><esc>
  normal pp
endfunction

command! CopyIntoComponent d * call CopyIntoComponent()
command! -range CopyIntoComponent normal d

