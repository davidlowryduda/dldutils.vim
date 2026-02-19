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

  " Store input for Python to access, and prepare result variables
  let s:_tabulate_input = l:lines
  let s:_tabulate_result = []
  let s:_tabulate_error = ''

python3 << EOF
import vim
import csv
import io

try:
    from tabulate import tabulate

    lines = vim.eval('s:_tabulate_input')
    csv_text = '\n'.join(lines)
    rows = list(csv.reader(io.StringIO(csv_text)))

    if rows:
        result = tabulate(rows, headers="firstrow", tablefmt="pipe")
        # Store result back to Vim
        vim.command("let s:_tabulate_result = " + repr(result.split('\n')))
except ImportError:
    vim.command("let s:_tabulate_error = 'tabulate package not installed'")
except Exception as e:
    vim.command("let s:_tabulate_error = " + repr(str(e)))
EOF

  " Check for errors
  if s:_tabulate_error != ''
    echohl ErrorMsg
    echom '[dldutils] python3/tabulate error: ' . s:_tabulate_error
    echohl None
    return
  endif

  " In case python produced nothing, avoid deleting everything silently
  if empty(s:_tabulate_result)
    echohl WarningMsg
    echom '[dldutils] No output from python3/tabulate.'
    echohl None
    return
  endif

  call setline(a:first, s:_tabulate_result)

  " Delete any leftover original lines if output is shorter
  let l:new_last = a:first + len(s:_tabulate_result) - 1
  if l:new_last < a:last
    execute (l:new_last + 1) . ',' . a:last . 'delete _'
  endif
endfunction
