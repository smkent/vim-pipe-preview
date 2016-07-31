function! pipepreview#start()
    if empty(get(g:, 'pipe_preview_command', ''))
        return
    endif
    if get(b:, 'pipe_preview_buffer', 0)
        return
    endif
    if &filetype == 'pipe_preview_buffer'
        return
    endif
    let l:buf_name = bufname('%')
    let l:buf_nr = bufnr('%')
    let l:parent_line_pos = line('.')

    augroup pipe_preview_parent_buffer_commands
        autocmd!
        autocmd BufWritePost <buffer> silent call pipepreview#update()
    augroup END

    keepalt rightbelow vnew
    wincmd l
    let l:restore =
        \ 'call setwinvar(bufwinnr(' . l:buf_nr . '), ' . '"&scrollbind", 0)' .
        \ '| call setbufvar(' . l:buf_nr . ', "pipe_preview_buffer", 0)'
    let w:pipe_preview_close_restore = l:restore
    call setbufvar(l:buf_nr, 'pipe_preview_buffer', bufnr('%'))
    let b:pipe_preview_parent_buffer = l:buf_nr
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

function! pipepreview#execute_command()
    execute ':%d _'
    let l:cont = getbufline(b:pipe_preview_parent_buffer, 0, '$')
    call append(line('0'), l:cont)
    silent execute ':%!' . g:pipe_preview_command
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
    execute +bufwinnr(l:pipe_preview_buf) .
        \ 'windo! call pipepreview#refresh('
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
