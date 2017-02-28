execute pathogen#infect()
syntax on
filetype plugin indent on
set number
set colorcolumn=80
hi ColorColumn ctermbg=black guibg=black
set nowrap

set ts=2 sw=2 et

"### CtrlP
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>'],
    \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
    \ }
let g:ctrlp_max_files=0
let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }

"### Mapping pane commands
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

"### TabCloseRight
function! TabCloseRight(bang)
    let cur=tabpagenr()
    while cur < tabpagenr('$')
        exe 'tabclose' . a:bang . ' ' . (cur + 1)
    endwhile
endfunction

function! TabCloseLeft(bang)
    while tabpagenr() > 1
        exe 'tabclose' . a:bang . ' 1'
    endwhile
endfunction

command! -bang Tabcloseright call TabCloseRight('<bang>')
"command! -bang Tabcloseleft call TabCloseLeft('<bang>')

"### Whitespaces
"set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
"set list
set listchars=trail:·
set list

set directory=$HOME/.vim/swapfiles/
