function! GetCharUnderCursor()
  return matchstr(getline('.'), '\%' . col('.') . 'c.')
endfunction

function! IsTrunkChar(c)
  return a:c ==# '├' ||
       \ a:c ==# '│' ||
       \ a:c ==# '└'
endfunction

function! TreePathUnderCursor()
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
    while !IsTrunkChar(GetCharUnderCursor()) && lastColPos !=# getpos('.')
      let lastColPos = getpos('.')
      execute 'normal! h'
    endwhile

    let lastRowPos = []
    while IsTrunkChar(GetCharUnderCursor()) && lastRowPos !=# getpos('.')
      let lastRowPos = getpos('.')
      execute 'normal! k'
    endwhile
  endwhile
  call winrestview(original)
  return path
endfunction

function! MatchTreePathContent(ctx)
  let ctx = a:ctx
  if ctx.mode !=# 'i' || ctx.mode !=# 'n'
    let ctx.match = TreePathUnderCursor()
    return 1
  endif
  return 0
endfunction

function! MatchTreeDir(ctx)
  return plum#matchers#MatchFso(a:ctx, function('plum#system#DirExists'),
        \ function('MatchTreePathContent'))
endfunction

function! MatchTreeFile(ctx)
  return plum#matchers#MatchFso(a:ctx, function('plum#system#FileExists'),
        \ function('MatchTreePathContent'))
endfunction

function! PlumTree_FileAction()
  return {
        \ 'name' : 'PlumTreeFileAction',
        \ 'matcher' : function('MatchTreeFile'),
        \ 'action' : function('plum#actions#File'),
        \ }
endfunction

function! PlumTree_DirectoryAction()
  return {
        \ 'name' : 'PlumTreeDirectoryAction',
        \ 'matcher' : function('MatchTreeDir'),
        \ 'action' : function('plum#actions#Dir'),
        \ }
endfunction
