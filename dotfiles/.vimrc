"vimrc"

syntax on

set showmatch
set showmode
set laststatus=2
set wildmenu
set title
set cursorline

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
set clipboard=unnamedplus

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

" fast save
nmap <leader>w :w!<cr>

" tagbar
nmap <F8> :TagbarToggle<CR>

" nerdtree
nmap <F2> :NERDTreeToggle<CR>

" better backspace
set backspace=eol,start,indent

" clear highlighting on escape in normal mode
nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[

" select entry from completion menu on enter
" inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" save file which you forgot to open with sudo
cnoremap w!! w !sudo tee % >/dev/null

" statusline configuration
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" syntactic configuration
let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0
let g:syntastic_c_checkers=['cppcheck']

" clang-complete configuration
" let g:clang_library_path='/usr/lib'
let g:clang_auto_select=1
let g:clang_snippets=1
let g:clang_conceal_snippets=1
let g:clang_user_options='-std=c++0x'
let g:clang_complete_copen=1
let g:clang_snippets_engine='clang_complete'
" let g:clang_use_library=1

set concealcursor=inv
set conceallevel=2
set completeopt=menu,menuone,longest

" supertab configuration
let g:SuperTabDefaultCompletionType="context"

" vundle plugin manager configuration
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree.git'
Plugin 'tpope/vim-markdown'
Plugin 'derekwyatt/vim-scala'
Plugin 'itchyny/lightline.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'majutsushi/tagbar'
Plugin 'godlygeek/tabular'
Plugin 'scrooloose/nerdcommenter'
Plugin 'rust-lang/rust.vim'
Plugin 'scrooloose/syntastic'
Plugin 'xolox/vim-easytags'
Plugin 'xolox/vim-misc'
Plugin 'henrik/vim-indexed-search'
Plugin 'ervandew/supertab'
Plugin 'rip-rip/clang_complete'

call vundle#end()
filetype plugin indent on
