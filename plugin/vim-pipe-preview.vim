" vim-pipe-preview provides a way to pipe a buffer through an external command
" and display the output in a separate split

if exists('g:loaded_vim_pipe_preview')
    finish
endif
let g:loaded_vim_pipe_preview = 1

let g:pipe_preview_command = get(g:, 'pipe_preview_command', 0)

command! PipePreview :call pipepreview#start()
