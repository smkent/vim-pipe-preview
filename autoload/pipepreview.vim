function! pipepreview#install_autocommands()
    augroup pipe_preview_commands
        autocmd!
        autocmd BufWinLeave *
            \ execute getwinvar(+bufwinnr(+expand('<abuf>')),
            \ 'pipe_preview_close_restore')
        autocmd BufWritePost * silent call pipepreview#update()
    augroup END
    let g:pipe_preview_autocommands_installed = 1
endfunction

function! pipepreview#start()
    let l:command = pipepreview#get_command()
    if empty(l:command)
        return
    endif
    if &filetype == 'pipe_preview_buffer'
        return
    endif
    let l:pipe_preview_buffer = get(b:, 'pipe_preview_buffer', 0)
    if !empty(l:pipe_preview_buffer)
        if +bufwinnr(l:pipe_preview_buffer) != -1
            return
        endif
    endif
    if empty(get(g:, 'pipe_preview_autocommands_installed'))
        call pipepreview#install_autocommands()
    endif
    let l:buf_name = bufname('%')
    let l:buf_nr = bufnr('%')
    let l:parent_line_pos = line('.')

    keepalt rightbelow vnew
    wincmd l
    let l:restore =
        \ 'call setwinvar(bufwinnr(' . l:buf_nr . '), ' . '"&scrollbind", 0)' .
        \ '| call setbufvar(' . l:buf_nr . ', "pipe_preview_buffer", 0)'
    let w:pipe_preview_close_restore = l:restore
    call setbufvar(l:buf_nr, 'pipe_preview_buffer', bufnr('%'))
    let b:pipe_preview_parent_buffer = l:buf_nr
    let b:pipe_preview_command = l:command
    setlocal filetype=pipe_preview_buffer buftype=nofile bufhidden=delete
        \ noswapfile nobuflisted nonumber norelativenumber modifiable
    call pipepreview#execute_command()
    if exists(':AnsiEsc')
        AnsiEsc
    endif

    execute l:parent_line_pos
    setlocal nomodified nomodifiable scrollbind
    execute +bufwinnr(b:pipe_preview_parent_buffer) .
        \ 'windo! setlocal scrollbind'
    syncbind
endfunction

function! pipepreview#get_command()
    let l:buffer_local_command = get(b:, 'pipe_preview_command', '')
    if !empty(l:buffer_local_command)
        return l:buffer_local_command
    endif
    let l:ft_command = get(g:, 'pipe_preview_' . &filetype . '_command', '')
    if !empty(l:ft_command)
        return l:ft_command
    endif
    return get(g:, 'pipe_preview_command', '')
endfunction

function! pipepreview#execute_command()
    execute ':%d _'
    let l:cont = getbufline(b:pipe_preview_parent_buffer, 0, '$')
    call append(line('0'), l:cont)
    silent execute ':%!' . b:pipe_preview_command
endfunction

function! pipepreview#refresh(line_top, line_pos)
    setlocal modifiable
    if !exists('b:pipe_preview_parent_buffer')
        return
    endif
    let l:prev_line_top = line('w0')
    let l:prev_line = line('.')

    setlocal noscrollbind
    if exists(':AnsiEsc')
        AnsiEsc
    endif
    call pipepreview#execute_command()
    if exists(':AnsiEsc')
        AnsiEsc
    endif
    execute l:prev_line
    setlocal scrollbind
    setlocal nomodified nomodifiable
endfunction

function! pipepreview#update()
    let l:pipe_preview_buf = get(b:, 'pipe_preview_buffer')
    if !l:pipe_preview_buf
        return
    endif
    let l:line_top = line('w0') + &scrolloff
    let l:line_pos = line('.')
    setlocal noscrollbind
    execute +bufwinnr(l:pipe_preview_buf)
        \ . 'windo! call pipepreview#refresh('
        \ . l:line_top . ', ' . l:line_pos . ')'
    wincmd p
    setlocal scrollbind
    syncbind
    execute l:line_pos
    " Enabling AnsiEsc on update causes the vim-airline status to lose its
    " color codes. Refreshing the Airline status restores the correct format.
    if exists(':AirlineRefresh')
        AirlineRefresh
    endif
endfunction
