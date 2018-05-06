"vimrc"

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
Plugin 'xolox/vim-misc'
Plugin 'henrik/vim-indexed-search'
Plugin 'tpope/vim-commentary' 
Plugin 'kien/ctrlp.vim'
Plugin 'valloric/youcompleteme'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'scrooloose/syntastic'
Plugin 'valloric/listtoggle'
Plugin 'will133/vim-dirdiff'
Plugin 'raimondi/delimitmate'
Plugin 'chase/vim-ansible-yaml'
Plugin 'gre/play2vim'
Plugin 'othree/html5.vim'
Plugin 'yggdroot/indentline'

" Plugin 'ervandew/supertab'
" Plugin 'rip-rip/clang_complete'

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

function! UpdateCTags()
    if filereadable("tags")
        let current_path = getcwd()
        call system("ctags -R --fields=+l " . current_path) " --field=+l is needed by ycm (ycm_collect_identifiers_from_tags_files)
        unlet current_path
    endif
endfunction

" update tags
autocmd BufWritePost * call UpdateCTags()
" automatic reload file when changed outside of vim
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
autocmd FileChangedShellPost * echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" automatic reload win configuration
" autocmd BufWritePost .vimrc source %

nnoremap <leader>w :wincmd w<cr>
nnoremap <leader>s :w!<cr>
nnoremap <leader>q :q!<cr>
nnoremap <leader>o :CtrlP<cr>
nnoremap <leader>p :CtrlPTag<cr>
nnoremap <leader>t <C-]>
nnoremap <leader>z <C-t>
nnoremap <leader>n ]c
nnoremap <leader>b [c
nnoremap <F8> :TagbarToggle<cr>
nnoremap <F2> :NERDTreeToggle<cr>
" save file which you forgot to open with sudo
cnoremap w!! w !sudo tee % >/dev/null
" clear highlighting on escape in normal mode
nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[
" select entry from completion menu on enter
" inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" nnoremap <leader>h :wincmd h<cr>
" nnoremap <leader>j :wincmd j<cr>
" nnoremap <leader>k :wincmd k<cr>
" nnoremap <leader>l :wincmd l<cr>

" better backspace
set backspace=eol,start,indent

" completion menu configuration
set concealcursor=vin
set conceallevel=2
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

" checkers for c not needed because of ycm
" let g:syntastic_c_checkers=['gcc']
" let g:syntastic_c_compiler_options='-std=gnu11 -Wall -Werror -D_GNU_SOURCE'
" let g:syntastic_c_config_file='.clang_complete'

" youcompleteme configuration
let g:ycm_server_python_interpreter="/usr/bin/python2"
let g:ycm_global_ycm_extra_conf="~/.vim/.ycm_extra_conf.py"
let g:ycm_collect_identifiers_from_tags_files=1
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_always_populate_location_list=1
let g:ycm_key_list_select_completion=['<down>']
let g:ycm_key_list_previous_completion=['<up>']

" listtoggle configuration
let g:lt_location_list_toggle_map='<F3>'
let g:lt_quickfix_list_toggle_map='<F4>'
let g:lt_height=10

" ultisnips configuration
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<leader>n"
let g:UltiSnipsJumpBackwardTrigger="<leader>b"

" clang-complete configuration
" let g:clang_library_path='/usr/lib/libclang.so'
" let g:clang_auto_select=0
" let g:clang_snippets=1
" let g:clang_conceal_snippets=1
" let g:clang_user_options='-std=c11'
" let g:clang_complete_copen=1
" let g:clang_snippets_engine='clang_complete'
" let g:clang_use_library=1

" supertab configuration
" let g:SuperTabDefaultCompletionType="context"
