function! SetupCtags()
  " Run ctags -R in the background
  call jobstart('ctags -R --exclude=.git --exclude=jquery.js --exclude=jquery.min.js --exclude=lunr.min.js', {
        \ 'on_stdout': function('s:OnCtagsComplete'),
        \ 'on_stderr': function('s:OnCtagsError'),
        \ 'on_exit': function('s:OnCtagsExit')
        \ })
endfunction

function! s:OnCtagsComplete(job_id, data, event)
  if empty(a:data)
    return
  endif
  call luaeval('vim.notify("ctags -R completed successfully.", vim.log.levels.INFO)')
endfunction

function! s:OnCtagsError(job_id, data, event)
  " Check if the data is not empty
  if !empty(a:data) && a:data[0] != ''
    " Construct a detailed error message
    let l:error_message = 'Error running ctags: ' . join(a:data, "\n")
    let l:details = 'Job ID: ' . a:job_id . ', Event: ' . a:event
    call luaeval('vim.notify(_A[1] .. "\n" .. _A[2], vim.log.levels.ERROR)', [l:error_message, l:details])
  endif
endfunction

function! s:OnCtagsExit(job_id, data, event)
  " Check if ./vim.build directory exists, if not, create it
  call jobstart('mkdir -p ./vim.build', {
        \ 'on_exit': function('s:OnMkdirComplete')
        \ })
endfunction

function! s:OnMkdirComplete(job_id, data, event)
  if a:data[0] == 0
    call luaeval('vim.notify("Directory ./vim.build created or already exists.", vim.log.levels.INFO)')
  else
    call luaeval('vim.notify("Failed to create directory ./vim.build.", vim.log.levels.ERROR)')
  endif

  " Move tags file to ./vim.build directory in the background
  call jobstart('mv tags ./vim.build', {
        \ 'on_exit': function('s:OnMoveComplete')
        \ })
endfunction

function! s:OnMoveComplete(job_id, data, event)
  if a:data[0] == 0
    call luaeval('vim.notify("Tags moved to ./vim.build successfully.", vim.log.levels.INFO)')
    if filereadable("vim.build/tags")
      set tags=vim.build/tags
    endif
  else
    call luaeval('vim.notify("Failed to move tags.", vim.log.levels.ERROR)')
  endif
endfunction

" Check if the current directory name contains "planet-"
autocmd VimEnter * if stridx(getcwd(), 'planet-') != -1 | call SetupCtags() | endif

if filereadable("vim.build/tags")
    set tags=vim.build/tags
endif

" Enable list mode to show whitespace characters
set list

" Configure listchars to show LF and CRLF differently
set listchars=eol:↴,trail:·,extends:>,precedes:<,space:·

" Optionally, you can define a different symbol for CRLF
" This requires a bit of trickery since listchars does not directly support CRLF
" You can use a custom function to highlight CRLF lines
function! HighlightCRLF()
  " Highlight CRLF lines with a specific symbol
  match ErrorMsg '\r$'
endfunction

" Call the function on BufRead and BufWrite events
autocmd BufRead,BufWritePost * call HighlightCRLF()

"syntax hilight
syntax enable

"fold
set foldmethod=syntax
set nofoldenable

"vim-plug
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-surround'
Plug 'vim-scripts/taglist.vim'
Plug 'morhetz/gruvbox'
call plug#end()

colorscheme gruvbox
set nowrap
set ignorecase
set nohlsearch
set number

"Auto indent settings 
set expandtab
set shiftwidth=4
set softtabstop=4

"Copy to clipboard 'Y'
nnoremap Y "+y
vnoremap Y "+y
nnoremap yY ^"+y$

"hot key - function key
map <F2> :tabnew<CR>
map <F3> :tabprev<CR>
map <F4> :tabnext<CR>
nnoremap <silent> <F9> :NERDTreeFind <CR>
map <F10> :TlistToggle <CR>

filetype plugin indent on

"NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
let NERDTreeQuitOnOpen = 1
let NERDTreeAutoDeleteBuffer = 1

"FZF
filetype plugin on
if executable('fd')
  let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git --exclude .cache'
else
  autocmd VimEnter * echohl WarningMsg | echom "[FZF] 'fd' not found: fzf will fall back to slow 'find'" | echohl None
endif
map <leader>ff :FZF<CR>

"CoC
" May need for Vim (not Neovim) since coc.nvim calculates byte offset by count
" utf-8 byte sequence
set encoding=utf-8
" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <s-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
"nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
"xmap <leader>f  <Plug>(coc-format-selected)
"nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  "autocmd FileType c setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
"xmap <leader>a  <Plug>(coc-codeaction-selected)
"nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
"nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
"nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
"nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
"nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
"xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
"nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
"nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
"command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
"command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
"command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
"set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

