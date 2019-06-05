function! plum#tree#OpenFso()
  return plum#CreateAction(
        \ 'plum#tree#OpenFso'
        \ function('plum#tree#IsTreePath'),
        \ function('plum#fso#ApplyOpenFso'))
endfunction

function! plum#tree#IsTreePath(context)
  if context.mode ==# 'i' || context.mode ==# 'n'
    let path = s:TreePathUnderCursor()
    let context.match = plum#fso#ResolveFso(path)
    return context.match !=# ''
  endif
  return 0
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

function! s:GetCharUnderCursor()
  return matchstr(getline('.'), '\%' . col('.') . 'c.')
endfunction

function! s:IsTrunkChar(c)
  return a:c ==# '├' ||
       \ a:c ==# '│' ||
       \ a:c ==# '└'
endfunction
