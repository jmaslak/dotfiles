" We use a dark solarized theme

set background=dark                 " Dark background
set ruler                           " Ruler at bottom
set number                          " Line Numbering
set t_Co=256                        " We do 256 colors
colorscheme solarized

set et                              " Expand Tabs to Spaces
set sts=4                           " Soft Tabs = 4 spaces
set sw=4                            " Shift Width = 4 spaces on indenting
set backspace=indent,eol,start      " Let me do anything with backspace!
set matchpairs+=<:>                 " Allow % to bounce between angles
set cinoptions=g-1                  " For C++

" Spelling:
"   "zg" adds a word to the spelling list
"   "zw" sets a word as a "bad" word
"   "zug" / "zuw" - undoes a "zg/zw
"
"   ]s -> Finds next misspelling
"   [s -> Finds previous misspelling
"
"   z= -> Suggest options
"   :spellr[epll] Replace all using previous z=

set spelllang=en_us           " Set spelling Language
" To turn on spelling, use "set spell"

" Use templates to create new files
autocmd BufNewFile * silent! 0r ~/.vim/templates/%:e.template

filetype plugin indent on
syntax enable                 " Set syntax highlighting
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

au FileType ruby setl sw=2 sts=2 et
au FileType asm setl smarttab autoindent
au FileType haskell setl smarttab autoindent sw=4 sts=4 et

" Set "K" to go to perldoc -f
au FileType perl setl keywordprg=perldoc\ -f

let g:tex_flavor='latex'
au FileType tex setl tw=72 formatoptions+=t

au BufNewFile,BufRead *.cl set filetype=cool
au FileType cool setl nospell

" Support syntax highlighting for .bash_aliases & .bash_private
au BufNewFile,BufRead .bash_aliases set filetype=sh
au BufNewFile,BufRead .bash_private set filetype=sh

au FileType yaml setlocal indentexpr=

" Show hidden characters
set list
set listchars=tab:\|\ 
highlight SpecialKey guifg=red ctermfg=red

" Completion hints:
"
" CTRL-N (insert) -> Search forward for completion
" CTRL-P (insert) -> Search backwards for completion
" Exuberant Ctags
"   generates tag file
"   CTRL-] - attempts to jump to tag definition
"   CTRL-T - Jumps back one on the stack

" Search parameters
set ignorecase
set smartcase
set incsearch
set hlsearch

" Folding options
" zC -> Fold all levels
" zO -> Open at position (all levels)
set foldmethod=indent
set nofoldenable

" Spell checking in POD
let perl_include_pod = 1

" Perl tidy, use :Tidy
command -range=% -nargs=* Tidy <line1>,<line2>!
  \perltidy <args>

" This lets us globally do something like set background dark
if filereadable(expand("~/.vim/vimrc.local"))
    source ~/.vim/vimrc.local
endif

" Allow toggling between light and dark background using F5
call togglebg#map("<F5>")
call togglebg#map("<C-b>")

