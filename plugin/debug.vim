" File:        debug.vim
" Version:     0.0.1
" Description: vim plugin to toggle debug code
" Maintainer:  Christian Persson <c0r73x@gmail.com>
" Repository:  https://github.com/c0r73x/vim-debug-comment
" License:     Copyright (C) 2016 Christian Persson
"              Released under the MIT license

if exists("g:loaded_debug_comment")
    finish
endif

let g:loaded_debug_comment = 1

let s:debugging = 0

let s:comment_map = {
            \   "c": '\/\/',
            \   "cpp": '\/\/',
            \   "go": '\/\/',
            \   "java": '\/\/',
            \   "javascript": '\/\/',
            \   "lua": '--',
            \   "scala": '\/\/',
            \   "php": '\/\/',
            \   "python": '#',
            \   "ruby": '#',
            \   "rust": '\/\/',
            \   "sh": '#',
            \   "desktop": '#',
            \   "fstab": '#',
            \   "conf": '#',
            \   "profile": '#',
            \   "bashrc": '#',
            \   "bash_profile": '#',
            \   "mail": '>',
            \   "eml": '>',
            \   "bat": 'REM',
            \   "ahk": ';',
            \   "vim": '"',
            \   "tex": '%',
            \ }

function! debug#debugToggle(curr, line, cft, cprefix, toggle)
    let l:match = matchstr(a:line, a:cprefix)

    if(empty(l:match) && !a:toggle)
        call setline(
                    \ a:curr,
                    \ substitute(
                    \   a:line,
                    \   '^\(\s*\)\(.*\)',
                    \   '\1' . a:cft . ' \2',
                    \   '')
                    \ )
    elseif(!empty(l:match) && a:toggle)
        call setline(
                    \ a:curr,
                    \ substitute(
                    \   a:line,
                    \   '^\(\s*\)' . a:cft . '\s\(.*\)',
                    \   '\1\2',
                    \   '')
                    \ )
    end
endfunction

function! debug#debug(toggle) range
    let l:cft = s:comment_map[&filetype]
    let l:prefix = '.*' . l:cft
    let l:cprefix = '^\s*' . l:cft
    let l:in_debug = 0

    for l:curr in range(a:firstline, a:lastline)
        let l:line = getline(l:curr)

        if l:in_debug == 0
            let l:match = matchstr(l:line, l:prefix . ' DEBUG START$')
            if(!empty(l:match))
                let l:in_debug = 1
            else
                let l:match = matchstr(l:line, l:prefix . ' DEBUG$')
                if(!empty(l:match))
                    call debug#debugToggle(
                                \ l:curr,
                                \ l:line,
                                \ l:cft,
                                \ l:cprefix,
                                \ a:toggle)
                endif
            endif
        else
            let l:match = matchstr(l:line, l:prefix . ' DEBUG END$')
            if(!empty(l:match))
                let l:in_debug = 0
            else
                call debug#debugToggle(
                            \ l:curr,
                            \ l:line,
                            \ l:cft,
                            \ l:cprefix,
                            \ a:toggle)
            endif
        endif
    endfor
endfunction

function! debug#toggleDebug()
    if s:debugging
        let s:debugging = 0
        echom 'Ending debug'
    else
        let s:debugging = 1
        echom 'Starting debug'
    endif

    exec '1,$call debug#debug(' . s:debugging . ')'
endfunction

command! -range=% StartDebug call debug#debug(1)
command! -range=% EndDebug call debug#debug(0)
command! ToggleDebug call debug#toggleDebug()

let g:loaded_debug_comment = 2
