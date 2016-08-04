# vim-pipe-preview

vim-pipe-preview provides a way to pipe a buffer through an external command
and display the output in a separate split, which scrolls together with the
source buffer.

This plugin can pipe buffer contents through any command that reads from
standard input and returns results on standard output. My original motivation
for writing this plugin was to preview Markdown files using
[terminal_markdown_viewer](https://github.com/axiros/terminal_markdown_viewer)
within vim.

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

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

See [`LICENSE`](/LICENSE) for the full license text.
