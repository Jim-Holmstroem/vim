" Don't care about vi support
set nocompatible

call pathogen#infect()
call pathogen#helptags()
filetype off

" BEGIN INDENTATION
filetype plugin indent on " Use different indentation based on filetype
filetype plugin on
set expandtab " Turn <TAB> into spaces.
set smarttab " replace tabs at beginning of line with spaces
set softtabstop=4 " Number of spaces <TAB> expands to 
set shiftwidth=4 " The width when pressing >>,<< or == and ai 
set autoindent " Indent a new line equal to the one above.
set smartindent " indent a new line after e.g. {

" BEGIN LOOK
set t_Co=256 " Enable 256 colors in terminals that support it
let g:solarized_termcolors=16
syntax enable " Use syntax highlightning
set background=dark " Optimize for dark background
colorscheme desert " Default colorsceheme
set number " Show line numbers to the left
set showcmd " Show linecount in visual mode
set showmatch " show matching parenthesis
set matchtime=1 " the time for showmatch
set laststatus=2 " always show the statusbar

" BEGIN STATUSLINE
" %F = full path (use %f for folder/file)
" %m = modified flag
" %r = read-only flag
" %h = help file flag
" %{fugitive#statusline()} = the current git branch
" %l = the current line
" %L = total number of lines
" %c = the current column
set statusline=%F%m%r%h\ %{fugitive#statusline()}\ %=%-15(%l/%L,%c%)\ %P

" BEGIN HIGHLIGHTNING
" Turns on highlightning of characters which are after column 80
function EnableOverLength()
    highlight overlength ctermbg=red ctermfg=white guibg=#b0041b
    match OverLength /\%81v.\+/ 
    if v:version >= 703
        set colorcolumn=80
        if has("gui_running")
            hi ColorColumn guibg=#2d2d2d
        else
            hi ColorColumn ctermbg=Black
        endif
    endif
    let g:overlength_on = 1
endfunction

" Turns off highlightning of characters which are after column 80
function DisableOverLength()
        highlight clear OverLength
        if v:version >= 703
            highlight clear ColorColumn
        endif
        let g:overlength_on = 0
endfunction

" Toggles highlightning of characters which are after column 80
function ToggleOverLength()
    if exists("g:overlength_on") && g:overlength_on == 1
        call DisableOverLength()
    else
        call EnableOverLength()
    endif
endfunction

" Enable the highlightning for all new buffers
function MaybeEnableOverLength()
    if !exists("g:overlength_on") || g:overlength_on == 1
        call EnableOverLength()
    endif
endfunction
autocmd BufEnter * call MaybeEnableOverLength() 

highlight SpellBad ctermbg=none ctermfg=red

" BEGIN SYNTAX FILES
au BufRead,BufNewFile *.json set filetype=json
au BufRead,BufNewFile wscript set filetype=python

" BEGIN SEARCH
set hlsearch  " Highlight search
set incsearch  " Incremental search, search as you type
set smartcase " Ignore case when searching lowercase
set gdefault " use /g by default when doing replace

" BEGIN COMPATABILITY
set backspace=2 " Fix backspace for strange terminals
" Saves additional stuff when saving a session
set sessionoptions=blank,buffers,curdir,folds,help,resize,tabpages,winsize
let g:yankring_history_file = '.yankring_history'

" BEGIN SPELLING
set spellfile=.spell.utf-8.add

" BEGIN NERDTree
au VimEnter * call MaybeShowNERDTree()
au BufEnter * :silent call MaybeMirrorNERDTree()
au WinEnter * call s:CloseIfOnlyNerdTreeLeft()

function ToggleNERDTree()
    if !exists("g:DoShowNERDTree") || g:DoShowNERDTree == 0
        let g:DoShowNERDTree = 1
        NERDTree
    else
        let g:DoShowNERDTree = 0
        NERDTreeClose
    endif
endfunction

function MaybeShowNERDTree()
    if exists("g:DoShowNERDTree") && g:DoShowNERDTree == 1
        NERDTree
    endif
endfunction

function MaybeMirrorNERDTree()
    if exists("g:DoShowNERDTree") && g:DoShowNERDTree == 1
        NERDTreeMirror
    endif
endfunction

" Close all open buffers on entering a window if the only
" buffer that's left is the NERDTree buffer
function s:CloseIfOnlyNerdTreeLeft()
  if exists("t:NERDTreeBufName")
    if bufwinnr(t:NERDTreeBufName) != -1
      if winnr("$") == 1
        q
      endif
    endif
  endif
endfunction

function ToggleBackground()
    if(&background == 'light')
        set background=dark
    else
        set background=light
    endif
endfunction

function SetBackgroundBasedOnGnomeTerminalProfile()
    if has('unix')
        if filereadable(expand("~/bin/current-gnome-terminal-profile"))
            let profileName = system('current-gnome-terminal-profile')
            " Profile1 is Solarized light
            " Profile0 is Solarized dark
            if profileName == "Profile1"
                set background=light
            elseif profileName == "Profile0"
                set background=dark
            endif
        endif
    endif
endfunction
call SetBackgroundBasedOnGnomeTerminalProfile()

" BEGIN KEYBOARD MAPPINGS

" Table for remembering different mapping modes:
"    map type     | normal | visual+select | operator-pending
" noremap (map)   |   y    |       y       |         y
" nnoremap (nmap) |   y    |       -       |         -
" vnoremap (vmap) |   -    |       y       |         -
" onoremap (omap) |   -    |       -       |         y

" Change leader
let mapleader=","

" Open and close NERDTree
nmap <leader>f :call ToggleNERDTree()<CR>

" ,t to create a new tab in normal mode
map <leader>t :tabnew<CR>

" Map <C-h> and <C-l> to switch tabs
map <C-h> :tabprevious<CR>
map <C-l> :tabnext<CR>
imap <C-h> <Esc>:tabprevious<CR>i
imap <C-l> <Esc>:tabnext<CR>i

" Map <C-j> to break the line at cursor
nmap <NL> i<CR><RIGHT><ESC>

" <SPACE> to switch windows (in normal mode)
map <Space> <c-w>w

" ,= to even out all splits
nmap <leader>= <C-w>=

" ,w to open new vertical split and move to it
nmap <leader>w <C-w>v<C-w>l

" <DASH> to turn on/off highlighted search
nnoremap <silent><leader><space> :noh<cr>

" Easy copy/paste to clipboard
map <leader>y "+y
nmap <leader>p "+p

" Remap ESC to jj
imap jj <Esc>

" Toogle highlight with ,h
map <silent><leader>h :call ToggleOverLength()<cr>

" Toggle light/dark background with ,d
map <silent><leader>d :call ToggleBackground()<cr>

" Show all functions and classes in this file
map <silent><leader>f <Esc>:Tlist<CR>

if has("autocmd") "Apply changes when saving .vimrc file
    autocmd bufwritepost .vimrc source $MYVIMRC
endif

" Highlight trailing whitespace
" Taken from https://github.com/bronson/vim-trailing-whitespace but changed the
" color to match solarized
highlight ExtraWhitespace ctermbg=darkred guibg=#CC4B43
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/

let g:pydiction_location = '~/.vim/bundle/pydiction/complete-dict'
let g:pydiction_menu_height = 20

" Jim's stuff
"
"
nmap <F8> :TagbarToggle<CR>
nmap <F11> :!pylint %<CR>
nmap <F12> :!pep8 %<CR>

set cmdwinheight=32
set relativenumber

hi Search cterm=None ctermfg=black ctermbg=white
