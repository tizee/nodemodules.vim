function! s:is_command_exist(cmd)
  let res = system("command -v " . a:cmd)
  if empty(res)
    return v:false
  endif 
  return v:true
endfunction

function! nodemodules#getNodeModulesPath()
  let npm_cmd = "npm --loglevel silent root"
  let yarn_cmd = "yarnpkg bin"
  let is_npm_exist = s:is_command_exist("npm")
  let is_yarn_exist = s:is_command_exist("yarn")
  if !is_npm_exist && !is_yarn_exist
    echoerr "No package manager found: npm or yarn"
    return
  endif 

  if is_npm_exist
    let path = system(npm_cmd)
    let path = substitute(path,'\n$','','')
    return [path,isdirectory(path)]
  else
    let path = system(yarn_cmd)
    let path = substitute(path,'\/.bin\n$','','')
    return [path,isdirectory(path)]
  endif 
endfunction

function! s:remove_prefix(path,prefix)
  return substitute(a:path,a:prefix,"","")
endfunction

" get list of node_modules
function! nodemodules#getPackages(path,pattern)
  if has("patch-8.1.1120") " vim support readdir
    let files = readdir(a:path)
    return map(files,{_,val -> s:build_path_entry(a:path,val,"")})
  elseif s:is_command_exist("fd")
    let cmd = ["fd","\"".a:pattern."\"","--full-path","\"".a:path."\"","-t d -d 1"]
    let output = system(join(cmd," "))
    let files = split(output,'\n')
    return map(files,{_,val -> s:remove_prefix(val,a:path."/")})
  else
    let cmd = ["find","\"".a:path."\"","-depth 1 -type d -iname",a:pattern]
    let output = system(join(cmd," "))
    let files = split(output,'\n')
    return map(files,{_,val -> s:remove_prefix(val,a:path."/")})
  endif
endfunction
