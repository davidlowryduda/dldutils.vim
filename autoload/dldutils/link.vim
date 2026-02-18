" autoload/dldutils/link.vim
"
" Markdown link generation utilities
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

if exists('g:autoloaded_dldutils_link')
  finish
endif
let g:autoloaded_dldutils_link = 1

" Generate a markdown anchor from header text
" - Lowercase
" - Spaces to hyphens
" - Strip non-alphanumeric (except hyphens)
" - Collapse consecutive hyphens
" - Strip leading/trailing hyphens
function! s:generate_anchor(header_text) abort
  let l:anchor = a:header_text
  " Lowercase
  let l:anchor = tolower(l:anchor)
  " Spaces to hyphens
  let l:anchor = substitute(l:anchor, ' ', '-', 'g')
  " Strip non-alphanumeric except hyphens
  let l:anchor = substitute(l:anchor, '[^a-z0-9-]', '', 'g')
  " Collapse consecutive hyphens
  let l:anchor = substitute(l:anchor, '-\+', '-', 'g')
  " Strip leading/trailing hyphens
  let l:anchor = substitute(l:anchor, '^-\+\|-\+$', '', 'g')
  return l:anchor
endfunction

" Extract header text from an ATX-style header line
" Returns empty string if not a header
function! s:extract_header_text(line) abort
  " Match ATX headers: # Header or ## Header ## (with optional trailing #)
  let l:match = matchlist(a:line, '^#\+\s*\(.\{-}\)\s*#*\s*$')
  if empty(l:match)
    return ''
  endif
  return l:match[1]
endfunction

" Get the relative path from CWD to the current file
" Uses ./ prefix if file is in CWD
function! s:get_relative_path() abort
  let l:filepath = expand('%:p')
  let l:cwd = getcwd()

  " Ensure cwd ends with /
  if l:cwd !~# '/$'
    let l:cwd = l:cwd . '/'
  endif

  " Check if file is under CWD
  if l:filepath =~# '^' . escape(l:cwd, '.\')
    let l:relpath = strpart(l:filepath, len(l:cwd))
    return './' . l:relpath
  endif

  " File is not under CWD, use fnamemodify for relative path
  return fnamemodify(l:filepath, ':.')
endfunction

" Main function: generate markdown link and copy to system clipboard
function! dldutils#link#make() abort
  let l:relpath = s:get_relative_path()
  let l:filename = expand('%:t')
  let l:current_line = getline('.')

  let l:header_text = s:extract_header_text(l:current_line)

  if !empty(l:header_text)
    " On a header line: use header text as link text, add anchor
    let l:anchor = s:generate_anchor(l:header_text)
    let l:link = '[' . l:header_text . '](' . l:relpath . '#' . l:anchor . ')'
  else
    " Not on a header: use filename as link text
    let l:link = '[' . l:filename . '](' . l:relpath . ')'
  endif

  " Copy to system clipboard
  let @+ = l:link
  echo 'Copied: ' . l:link
endfunction
