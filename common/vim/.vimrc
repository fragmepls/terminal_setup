" =========================
" BASIC SETTINGS
" =========================
set nocompatible
filetype plugin indent on
syntax on

set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent
set nowrap
set cursorline
set showcmd
set wildmenu
set incsearch
set hlsearch
set ignorecase
set smartcase
set mouse=a
set clipboard=unnamedplus
set splitbelow
set splitright
set updatetime=300
set termguicolors
set formatoptions+=o
set formatoptions+=r
set formatoptions-=cro

let mapleader = " "

" =========================
" PLUGINS (vim-plug)
" =========================
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-sensible'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-prettier'
Plug 'joshdick/onedark.vim'
Plug 'github/copilot.vim'
Plug 'airblade/vim-gitgutter'

call plug#end()

" =========================
" COLORS
" =========================
colorscheme onedark

" =========================
" COC EXTENSIONS
" =========================
let g:coc_global_extensions = [
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-json',
  \ '@yaegassy/coc-intelephense',
  \ 'coc-omnisharp'
  \ ]

" =========================
" PLUGIN CONFIG
" =========================
let g:NERDTreeMouseMode=2
let g:NERDTreeShowHidden=1
let g:NERDTreeMinimalUI=1
let g:airline_powerline_fonts = 1

set hidden
set nobackup
set nowritebackup
set cmdheight=2
set signcolumn=yes

" =========================
" COC COMPLETION
" =========================
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()

inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
      \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <expr><C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" =========================
" KEYMAPS
" =========================
nnoremap <leader>r :source ~/.vimrc<CR>

nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <leader>n :NERDTreeFocus<CR>

nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>f :Rg<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>sh :split<CR>

nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>h :nohlsearch<CR>

nmap gd <Plug>(coc-definition)
nmap gy <Plug>(coc-type-definition)
nmap gi <Plug>(coc-implementation)
nmap gr <Plug>(coc-references)

nmap <leader>rn <Plug>(coc-rename)

xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

xmap <leader>cf  <Plug>(coc-format-selected)
nmap <leader>cf  :call CocAction('format')<CR>

nnoremap <leader>p :CocCommand prettier.formatFile<CR>

nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    execute 'h ' . expand('<cword>')
  endif
endfunction

nmap <leader>ac  <Plug>(coc-codeaction)

" =========================
" AUTOCMDS
" =========================
augroup MyVimConfig
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   execute "normal! g`\"" |
    \ endif
  autocmd VimEnter * if argc() == 0 | NERDTree | endif
augroup END
