"vimrc"

" vundle plugin manager configuration
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree.git'
Plugin 'itchyny/lightline.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'godlygeek/tabular'
Plugin 'xolox/vim-misc'
Plugin 'henrik/vim-indexed-search'
Plugin 'tpope/vim-commentary' 
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/syntastic'
Plugin 'will133/vim-dirdiff'
Plugin 'raimondi/delimitmate'
Plugin 'yggdroot/indentline'
Plugin 'sheerun/vim-polyglot'

call vundle#end()
filetype plugin indent on
syntax on

set showmatch
set showmode
set laststatus=2
set wildmenu
set title
set cursorline
set noswapfile
set nobackup
set nowritebackup
set modifiable

" search (highlight results, ignore case, search while typing, regex)
set hlsearch
set incsearch
set ignorecase
set smartcase
set magic

" tabs (use spaces, number of spaces, indendation width, intend on new line)
set expandtab
set shiftwidth=4
set tabstop=4
set smartindent
set autoindent

" enable mouse highlight and copy to clipboard on arch linux
set mouse-=a
set clipboard=unnamed

" line (highlight, autobreak, number of characters, show column, color column)
" set cursorline
" set linebreak
" set textwidth=100
" set colorcolumn=100
" highlight ColorColumn ctermbg=0 guibg=DarkGray

" general (history size, swap interval, undo levels, completion menu, autoread file, file encoding)
set history=100
set updatetime=250
set undolevels=100
set hidden
set autoread
set encoding=utf8
set ffs=unix

" show invisible characters
set listchars=tab:▸\ ,trail:·,eol:¬,nbsp:_,extends:>,precedes:<
set list
set showcmd

" show relative numbers on the left side
set number
if exists("&relativenumber")
    set relativenumber
    au BufReadPost * set relativenumber
endif

" ignore files in wildmenu
set wildignore=*.o,*~,*.pyc,*/.git/*,*.class,*/target/*

" leader key
let mapleader=","
let g:mapleader=","

" automatic reload file when changed outside of vim
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
autocmd FileChangedShellPost * echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

nnoremap <leader>w :wincmd w<cr>
nnoremap <leader>e :tabNext<cr>
nnoremap <leader>s :w!<cr>
nnoremap <leader>q :q!<cr>
nnoremap <leader>o :CtrlP<cr>
nnoremap <leader>p :CtrlPTag<cr>
nnoremap <leader>t <C-]>
nnoremap <leader>z <C-t>
nnoremap <leader>n ]c
nnoremap <leader>b [c
nnoremap <F2> :NERDTreeToggle<cr>
" save file which you forgot to open with sudo
cnoremap w!! w !sudo tee % >/dev/null
" clear highlighting on escape in normal mode
nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[
" select entry from completion menu on enter
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" better backspace
set backspace=eol,start,indent

" completion menu configuration
set concealcursor=n
set conceallevel=0
set completeopt=menu,menuone,preview

" statusline configuration
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" syntactic configuration
let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=0
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=1
let g:syntastic_mode_map = { 'passive_filetypes': ['c', 'cpp'] }

" lightline configuration
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'filename': 'LightLineFilename',
      \   'gitbranch': 'fugitive#head'
      \ }
      \ }

function! LightLineFilename()
    let filename = expand('%')
    if filename == ''
        return '[No Name]'
    else
        return filename
    endif
endfunction

" indentline configuration
let g:indentLine_setConceal=0
