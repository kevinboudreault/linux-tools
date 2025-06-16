set nocompatible

" Show line numbers
set number

" Status bar
set laststatus=2

" Line wrap
set wrap

" Encoding
set encoding=utf-8

" Call .vimrc.plug file
if filereadable(expand("~/.vimrc.plug"))
    source ~/.vimrc.plug
endif


