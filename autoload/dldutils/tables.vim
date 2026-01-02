" autoload/dldutils/tables.vim
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

if exists('*dldutils#tables#tabulate_selection')
  finish
endif

" Format a range of lines as a Markdown pipe table.
"
" Each line is treated as CSV (comma-separated), the first line as headers.
" Uses Python3's `tabulate` library:
"   pip install tabulate
"
" Arguments:
"   a:first  - first line of range
"   a:last   - last line of range
function! dldutils#tables#tabulate_selection(first, last) range
  " Get the selected lines
  let l:lines = getline(a:first, a:last)
  if empty(l:lines)
    echohl WarningMsg
    echom '[dldutils] No lines in selection.'
    echohl None
    return
  endif

  " Join lines with newlines for stdin to python
  let l:input = join(l:lines, "\n")

  " Python snippet: read CSV from stdin and print a markdown pipe table
  let l:py = [
        \ 'import sys, csv',
        \ 'from tabulate import tabulate',
        \ 'rows = list(csv.reader(sys.stdin))',
        \ 'if not rows:',
        \ '    sys.exit(0)',
        \ 'print(tabulate(rows, headers="firstrow", tablefmt="pipe"))',
        \ ]

  let l:cmd = 'python3 -c ' . shellescape(join(l:py, ';'))

  " Call python with the selection as stdin
  let l:out = system(l:cmd, l:input)

  " Basic error reporting if python exits non-zero
  if v:shell_error != 0
    echohl ErrorMsg
    echom '[dldutils] python3/tabulate error (exit code ' . v:shell_error . ').'
    echom '[dldutils] Is the "tabulate" package installed for python3?'
    echohl None
    return
  endif

  " Replace the original lines with the output
  let l:out_lines = split(l:out, "\n", 1)

  " In case python produced nothing, avoid deleting everything silently
  if empty(l:out_lines)
    echohl WarningMsg
    echom '[dldutils] No output from python3/tabulate.'
    echohl None
    return
  endif

  call setline(a:first, l:out_lines)

  " Delete any leftover original lines if output is shorter
  let l:new_last = a:first + len(l:out_lines) - 1
  if l:new_last < a:last
    execute (l:new_last + 1) . ',' . a:last . 'delete _'
  endif
endfunction
