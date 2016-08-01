# vim-pipe-preview

vim-pipe-preview provides a way to pipe a buffer through an external command
and display the output in a separate split.

I wrote this plugin in order to preview Markdown files using
[terminal_markdown_viewer](https://github.com/axiros/terminal_markdown_viewer)
within vim, but this plugin can pipe buffer contents through an arbitrary
configured external command.

This plugin was developed and tested on Linux.

![](/img/screenshot.png)

## Installation

To install with [vim-plug](https://github.com/junegunn/vim-plug),
add an entry to your `~/.vimrc`:

```vim
Plug('smkent/vim-pipe-preview')
```

Restart vim (or reload your `~/.vimrc`) and run `:PlugInstall`.

## Dependencies

If [AnsiEsc](https://github.com/vim-scripts/AnsiEsc.vim) is installed, ANSI
color escape codes will be evaluated in the preview window automatically.

## Configuration and Usage

Specify the external pipe command to be used by setting
`g:pipe_preview_command`.

For example, to preview using
[terminal_markdown_viewer](https://github.com/axiros/terminal_markdown_viewer),
set the following in your `~/.vimrc`:

```vim
let g:pipe_preview_command = 'mdv -'
```

Preview a buffer with the configured external command by running:

```vim
:PipePreview
```

Once the preview window is active, its contents will be updated automatically
using the configured external command each time the parent buffer is saved.

The `:PipePreview` command may also be mapped for easier use. For example:

```vim
nnoremap <silent> ,pp :<C-U>PipePreview<CR>
```

Please see [the vim-pipe-preview help file](/doc/vim-pipe-preview.txt) for full
documentation.

## Inspiration

This was partially inspired by
[vim-fugitive](https://github.com/tpope/vim-fugitive); particularly `:Gblame`
which creates a [`scrollbind`
window](http://vim.wikia.com/wiki/Scrolling_synchronously) with `git blame`
output.

## License

This plugin is released under the GNU General Public License, version 3. See
[`LICENSE`](/LICENSE) and [`COPYING`](/COPYING) for license information.
