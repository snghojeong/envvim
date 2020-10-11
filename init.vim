"Read cscope file
if filereadable("vim.build/cscope.out")
  cs add vim.build/cscope.out
endif

"Read ctags file
if filereadable("vim.build/tags")
  set tags=vim.build/tags
endif

"syntax hilight
syntax enable

"fold
set foldmethod=syntax
set foldnestmax=1

"vim-plug
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'neoclide/coc.nvim', {'tag': '*', 'do': './install.sh'}
Plug 'tpope/vim-surround'
Plug 'vim-scripts/taglist.vim'
call plug#end()

colorscheme desert
set nowrap
set ignorecase
set nohlsearch
set number

"Auto indent
set expandtab
set shiftwidth=4
set softtabstop=4

"hot key - function key
map <F2> :tabnew<CR>
map <F3> :tabprev<CR>
map <F4> :tabnext<CR>
map <F5> :FZF<CR>
nnoremap <silent> <F9> :NERDTreeFind <CR>
map <F10> :TlistToggle <CR>
nnoremap <leader>dc :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>df :YcmCompleter GoToDefinition<CR>
nnoremap cw :cw<CR>
nnoremap cn :cn<CR>
nnoremap cp :cp<CR>

filetype plugin indent on

"NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
let NERDTreeQuitOnOpen = 1
let NERDTreeAutoDeleteBuffer = 1

"FZF
filetype plugin on
map <leader>ff :FZF<CR>

"cscope
set cscopequickfix=s-,c-,d-,i-,t-,e-
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>i :cs find i <C-R>=expand("<cword>")<CR><CR>
"nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
