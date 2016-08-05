function! pipepreview#install_autocommands()
    augroup pipe_preview_commands
        autocmd!
        autocmd WinEnter * call pipepreview#winenter()
        autocmd BufWinEnter * call pipepreview#reuse_or_close_preview()
        autocmd BufWinLeave *
            \ execute getwinvar(+bufwinnr(+expand('<abuf>')),
            \ 'pipe_preview_close_restore')
        if !empty(g:pipe_preview_update_on_save)
            autocmd BufWritePost * :PipePreviewUpdate
        endif
    augroup END
    let g:pipe_preview_autocommands_installed = 1
endfunction

function! pipepreview#start_preview(horizontal_split)
    let l:command = pipepreview#get_preview_command()
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
    if a:horizontal_split
        keepalt rightbelow new
    else
        keepalt rightbelow vnew
    endif
    wincmd l
    let w:pipe_preview_close_restore =
        \ 'call setwinvar(bufwinnr(' . l:buf_nr . '), ' . '"&scrollbind", 0)' .
        \ '| call setbufvar(' . l:buf_nr . ', "pipe_preview_buffer", 0)'
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
        \ 'wincmd w | setlocal scrollbind'
    syncbind

    let w:pipe_preview_close_restore =
        \ 'let w:pipe_preview_buffer = ' . b:pipe_preview_buffer
endfunction

function! pipepreview#check_command_exists(command)
    if executable(split(a:command)[0])
        return a:command
    endif
endfunction

function! pipepreview#get_preview_command()
    let l:buffer_local_command = get(b:, 'pipe_preview_command', '')
    if !empty(l:buffer_local_command)
        return pipepreview#check_command_exists(l:buffer_local_command)
    endif
    let l:ft_command = get(g:, 'pipe_preview_' . &filetype . '_command', '')
    if !empty(l:ft_command)
        return pipepreview#check_command_exists(l:ft_command)
    endif
    return pipepreview#check_command_exists(get(g:, 'pipe_preview_command', ''))
endfunction

function! pipepreview#execute_command()
    execute ':%d _'
    let l:cont = getbufline(b:pipe_preview_parent_buffer, 0, '$')
    call append(line('0'), l:cont)
    silent execute ':%!' . b:pipe_preview_command
endfunction

function! pipepreview#update_preview_command_wrapper(line_top, line_pos)
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

function! pipepreview#update_preview()
    let l:pipe_preview_buf = get(b:, 'pipe_preview_buffer')
    if !l:pipe_preview_buf
        return
    endif
    let l:line_top = line('w0') + &scrolloff
    let l:line_pos = line('.')
    setlocal noscrollbind
    execute +bufwinnr(l:pipe_preview_buf)
        \ . 'wincmd w | call pipepreview#update_preview_command_wrapper('
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

" Get the preview buffer from a parent buffer or vice versa
function! pipepreview#get_matching_buffer()
    let l:preview_buffer = get(b:, 'pipe_preview_buffer', 0)
    if !empty(l:preview_buffer)
        return l:preview_buffer
    endif
    let l:parent_buffer = get(b:, 'pipe_preview_parent_buffer', 0)
    if !empty(l:parent_buffer)
        return l:parent_buffer
    endif
    return 0
endfunction

function! pipepreview#winenter()
    let l:matching_buffer = pipepreview#get_matching_buffer()
    let l:pipe_preview_parent_buffer = get(b:, 'pipe_preview_parent_buffer', 0)
    let l:max_winnr = winnr('$')
    if !empty(l:pipe_preview_parent_buffer)
        if +bufwinnr(l:pipe_preview_parent_buffer) == -1
            " Parent window is closed, close the preview window
            q
        endif
    endif
    if l:max_winnr <= 1
        return
    endif
    if empty(l:matching_buffer)
        return
    endif
    let l:return_winnr = winnr()
    for win_nr in range(1, winnr('$'))
        execute win_nr . 'wincmd w'
        if !empty(l:matching_buffer)
            set noscrollbind
        endif
    endfor
    if !empty(l:matching_buffer)
        execute +bufwinnr(l:matching_buffer) . 'wincmd w | setlocal scrollbind'
    endif
    execute l:return_winnr . 'wincmd w'
    setlocal scrollbind
endfunction

function! pipepreview#reuse_or_close_preview()
    let l:existing_preview_buffer = get(w:, 'pipe_preview_buffer', 0)
    if empty(l:existing_preview_buffer)
        return
    endif
    unlet w:pipe_preview_buffer
    let l:existing_preview_win_nr = +bufwinnr(l:existing_preview_buffer)
    if l:existing_preview_win_nr == -1
        return
    endif
    let l:command = pipepreview#get_preview_command()
    if empty(l:command)
        " Close existing preview window
        let l:restore_win_nr = winnr()
        execute l:existing_preview_win_nr . 'wincmd w | q'
        execute l:restore_win_nr . 'wincmd w'
        return
    endif
    " Reuse existing preview window
    call setbufvar(l:existing_preview_buffer, "pipe_preview_parent_buffer",
        \ bufnr('%'))
    call setbufvar(l:existing_preview_buffer, "pipe_preview_command", l:command)
    let b:pipe_preview_buffer = l:existing_preview_buffer
    call pipepreview#update_preview()
    syncbind
endfunction
