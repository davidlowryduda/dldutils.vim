" autoload/dldutils/mdanchor.vim
"
" Open markdown links with anchor support
"
" Copyright © 2026 David Lowry-Duda <david@lowryduda.com>
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the "Software"),
" to deal in the Software without restriction, including without limitation
" the rights to use, copy, modify, merge, publish, distribute, sublicense,
" and/or sell copies of the Software, and to permit persons to whom the
" Software is furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included
" in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
" OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
" IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
" DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
" TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
" OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if exists('g:autoloaded_dldutils_mdanchor')
  finish
endif
let g:autoloaded_dldutils_mdanchor = 1

" Find markdown link under cursor
" Returns the URL part (inside parentheses) or empty string
function! s:find_link_under_cursor() abort
  let l:line = getline('.')
  let l:col = col('.') - 1  " 0-indexed

  " Pattern for markdown link: [text](url)
  let l:pattern = '\[.\{-}\](.\{-})'
  let l:start = 0

  while 1
    let l:match_start = match(l:line, l:pattern, l:start)
    if l:match_start == -1
      return ''
    endif

    let l:match_str = matchstr(l:line, l:pattern, l:start)
    let l:match_end = l:match_start + len(l:match_str) - 1

    " Check if cursor is within this match
    if l:col >= l:match_start && l:col <= l:match_end
      " Extract URL from inside parentheses
      let l:url = matchstr(l:match_str, '(\zs.\{-}\ze)$')
      return l:url
    endif

    let l:start = l:match_start + 1
  endwhile
endfunction

" Convert anchor to a case-insensitive regex pattern
" Reverses the anchor generation: some-section -> matches "Some Section", "some section!", etc.
function! s:anchor_to_pattern(anchor) abort
  " Split anchor by hyphens
  let l:parts = split(a:anchor, '-')
  if empty(l:parts)
    return ''
  endif

  " Build pattern for each part (just the alphanumeric content)
  " Join with pattern that matches: any punctuation, whitespace, or hyphens
  let l:separator = '[[:punct:][:space:]-]*'
  let l:pattern = '\c^#\+\s*' . l:separator . join(l:parts, l:separator) . l:separator . '\s*#*\s*$'

  return l:pattern
endfunction

" Main function: open markdown link under cursor
function! dldutils#mdanchor#open() abort
  let l:url = s:find_link_under_cursor()

  if empty(l:url)
    echohl WarningMsg
    echom '[OpenMDAnchor] No markdown link found under cursor'
    echohl None
    return
  endif

  " Split URL into filepath and anchor
  let l:hash_pos = stridx(l:url, '#')
  if l:hash_pos == -1
    let l:filepath = l:url
    let l:anchor = ''
  elseif l:hash_pos == 0
    let l:filepath = ''
    let l:anchor = strpart(l:url, 1)
  else
    let l:filepath = strpart(l:url, 0, l:hash_pos)
    let l:anchor = strpart(l:url, l:hash_pos + 1)
  endif

  " Open file if specified
  if !empty(l:filepath)
    " Resolve path relative to current file's directory
    let l:current_dir = expand('%:p:h')
    let l:fullpath = simplify(l:current_dir . '/' . l:filepath)

    if !filereadable(l:fullpath)
      echohl ErrorMsg
      echom '[OpenMDAnchor] File not found: ' . l:fullpath
      echohl None
      return
    endif

    execute 'edit ' . fnameescape(l:fullpath)
  endif

  " Search for anchor if specified
  if !empty(l:anchor)
    let l:pattern = s:anchor_to_pattern(l:anchor)
    " Move to top of file and search forward
    normal! gg
    let l:found = search(l:pattern, 'cW')
    if !l:found
      echohl WarningMsg
      echom '[OpenMDAnchor] Anchor not found: #' . l:anchor
      echohl None
    endif
  endif
endfunction
