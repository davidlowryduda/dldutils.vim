" plugin/dldutils.vim
"
" Personal Utilities
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

if exists('g:loaded_dldutils')
  finish
endif
let g:loaded_dldutils = 1

" Ensure python3 support
if !executable('python3')
  echohl WarningMsg
  echom '[dldutils] python3 executable not found; some commands will not work.'
  echohl None
endif

" --------------
"  Commands
" --------------

" Format visually selected CSV lines as markdown pipe using tabulate
"
" Usage:
"   :'<,'>TabulateSelection
command! -range TabulateSelection call dldutils#tables#tabulate_selection(<line1>, <line2>)

" Next and Previous Todo items
command! NextTodo call dldutils#todo#next()
command! PrevTodo call dldutils#todo#prev()
