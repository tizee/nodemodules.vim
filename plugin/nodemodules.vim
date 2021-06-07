" File: nodemodules.vim
" Author: tizee
" Email: 33030965+tizee@users.noreply.github.com
" Description: A plugin help navigate around node_modules for npm/yarn project
scriptencoding utf-8
if exists('loaded_nodemodules_vim')
  finish
endif
let g:loaded_nodemodules_vim = 1
let g:nodemodules_finder=get(g:,"nodemodules_finder","fzf")

" check if node_modules exists
function! s:has_nodemodules()
  return nodemodules#getNodeModulesPath()
endfunction

" choose between packages
function! s:select_in_packages(...)
  let [path, is_exist ]= s:has_nodemodules()
  if !is_exist
    echoerr "Fail to find node_modules at " . path
    return
  endif
  let target = a:0 > 0? a:1 : 'node_modules'
  let files = nodemodules#getPackages(path,target)
  " use your favorite fuzzy-finder
  if g:nodemodules_finder == "fzf" && g:loaded_fzf
    call s:fzf_finder(path,files)
  endif
endfunction

function! g:Nodemodules_open_action(path)
  execute(":lcd ".a:path)
  if g:loaded_nerd_tree
    execute(":NERDTreeCWD")
  endif
endfunction

function! s:open_pacakge(path,filename)
  let full_path = join([a:path,a:filename],"/")
  call g:Nodemodules_open_action(full_path)
endfunction

function! s:fzf_finder(path,files)
  if g:loaded_fzf
    call fzf#run(fzf#wrap({
      \ 'source': a:files,
      \ 'sink': {lines -> s:open_pacakge(a:path,lines)}
      \ }))
  endif 
endfunction

command! -nargs=* Nodemodules call <SID>select_in_packages(<q-args>)
