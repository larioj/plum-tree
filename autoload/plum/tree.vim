function! plum#tree#Directory()
  return s:PlumTree_DirectoryAction()
endfunction

function! plum#tree#File()
  return s:PlumTree_FileAction()
endfunction

function! s:GetCharUnderCursor()
  return matchstr(getline('.'), '\%' . col('.') . 'c.')
endfunction

function! s:IsTrunkChar(c)
  return a:c ==# '├' ||
       \ a:c ==# '│' ||
       \ a:c ==# '└'
endfunction

function! s:TreePathUnderCursor()
  let original = winsaveview()
  let sep = ''
  let path = ''
  let lastPathPos = [-1, -1, -1, -1, -1]
  while lastPathPos[1] !=# getpos('.')[1]
    let lastPathPos = getpos('.')
    let section = plum#extensions#GetPath()
    if section == ''
      call winrestview(original)
      return path
    else
      let path = section . sep . path
      let sep = '/'
    endif

    let lastColPos = []
    while !s:IsTrunkChar(s:GetCharUnderCursor()) && lastColPos !=# getpos('.')
      let lastColPos = getpos('.')
      execute 'normal! h'
    endwhile

    let lastRowPos = []
    while s:IsTrunkChar(s:GetCharUnderCursor()) && lastRowPos !=# getpos('.')
      let lastRowPos = getpos('.')
      execute 'normal! k'
    endwhile
  endwhile
  call winrestview(original)
  return path
endfunction

function! s:MatchTreePathContent(ctx)
  let ctx = a:ctx
  if ctx.mode !=# 'i' || ctx.mode !=# 'n'
    let ctx.match = s:TreePathUnderCursor()
    return 1
  endif
  return 0
endfunction

function! s:MatchTreeDir(ctx)
  return plum#matchers#MatchFso(a:ctx, function('plum#system#DirExists'),
        \ function('s:MatchTreePathContent'))
endfunction

function! s:MatchTreeFile(ctx)
  return plum#matchers#MatchFso(a:ctx, function('plum#system#FileExists'),
        \ function('s:MatchTreePathContent'))
endfunction

function! s:PlumTree_FileAction()
  return {
        \ 'name' : 'PlumTreeFileAction',
        \ 'matcher' : function('s:MatchTreeFile'),
        \ 'action' : function('plum#actions#File'),
        \ }
endfunction

function! s:PlumTree_DirectoryAction()
  return {
        \ 'name' : 'PlumTreeDirectoryAction',
        \ 'matcher' : function('s:MatchTreeDir'),
        \ 'action' : function('plum#actions#Dir'),
        \ }
endfunction
