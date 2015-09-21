" Everything pretty much should be UTF-8 by now
set encoding=utf-8

" Modelines can be a security risk - know you did this...
set modeline
set modelines=5

" This means there will be 5 lines above/below the cursor on the
" screen at all times.  I don't yet know if I like this.  It's not
" hard to do "zz"...
set scrolloff=5

" We use a light solarized theme
set background=light                " Light background
set ruler                           " Ruler at bottom
set number                          " Line Numbering
set t_Co=256                        " We do 256 colors
colorscheme solarized

" Tab settings
set et                              " Expand Tabs to Spaces
set sts=4                           " Soft Tabs = 4 spaces
set sw=4                            " Shift Width = 4 spaces on indenting
" Retab the entire document (replace tabs with the right amount of space)
nnoremap <leader><tab> :retab<cr>
" In visual mode, tab indents block, shift-tab un-indent
vmap <tab> >gv
vmap <s-tab> <gv
" In normal mode, tab indents, shift-tab un-indents
nmap <tab> I<tab><esc>
nmap <s-tab> ^i<bs><esc>
set shiftround                      " This mode makes more sense
                                    " (<< and >> use tab stops)

" backspace, %, C++ options
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
" To turn on spelling, <leader>S
" To turn off spelling, <leader>s
nnoremap <leader>S :set spell<cr>
nnoremap <leader>s :set nospell<cr>

" Use templates to create new files
autocmd BufNewFile * silent! 0r ~/.vim/templates/%:e.template

filetype plugin indent on
syntax enable                 " Set syntax highlighting

"
" Filetype setup
"

" Git commit
au FileType gitcommit setl spell

" Text
au FileType text setl spell textwidth=72 fo+=t

" Ruby
au FileType ruby setl sw=2 sts=2 et

" ASM
au FileType asm setl smarttab autoindent

" Haskel
au FileType haskell setl smarttab autoindent sw=4 sts=4 et

" Perl
" Set "K" to go to perldoc -f
au FileType perl setl keywordprg=perldoc\ -f

" Spell checking in POD
let perl_include_pod = 1

" Perl tidy, use :Tidy
command -range=% -nargs=* Tidy <line1>,<line2>!
  \perltidy <args>

" Make command and errors
" You can use:
"    :make  (compile)
"    cc     (display current error)
"    cn     (display next error)
"    cp     (display previous error)
"    cfirst (display first error)
"
autocmd FileType perl compiler perl
" The perl compiler will actually use -W, which makes include files ugly
" We don't do that.
autocmd FileType perl setl makeprg=perl\ -c\ %\ $*

" Apache
" Preserve indent levels
au FileType apache setlocal indentexpr= autoindent

" Tex
let g:tex_flavor='latex'
au FileType tex setl tw=72 formatoptions+=t

" Cool
au BufNewFile,BufRead *.cl set filetype=cool
au FileType cool setl nospell

" Shell
" Support syntax highlighting for .bash_aliases & .bash_private
au BufNewFile,BufRead .bash_aliases set filetype=sh
au BufNewFile,BufRead .bash_private set filetype=sh

" YAML
" I don't know what VIM is trying to do with YAML indenting, but
" I need to turn it all off and just copy indent (autoindent)
" from previous line.
au FileType yaml setlocal indentexpr= autoindent

" Makefile
" Use real tabs!
autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=8

" Asterisk
" We want to make sure "same =>" gets syntax-colored properly
au FileType asterisk syn match asteriskExten "^\s*same\s*=>\?\s*[^,]\+" contains=asteriskPriority

" Show hidden characters
set list
" The next line has a trailing space.
" Note that the version was 703 for some reason, but I think this should
" work on 702
if v:version >= 702
    set listchars=tab:\⇥\ 
endif
" This next line doesn't seem to work for me.
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
set ignorecase  " A lowercase string is case-insensitive searching
set smartcase   " If uppercase letters appear, they are case sensitive
set incsearch   " Incremental searching
set hlsearch    " Highlight matches

" Remap leader+space to turn off highlighting of matches (search)
" Leader is normally "\"
nnoremap <leader><space> :noh<cr>

" Mouse support
" Leader ("\") + M will turn on mouse support
" Leader ("\") + m will turn off mouse support
" It will default on
set mouse=a
nnoremap <leader>M :set mouse=a<cr>
nnoremap <leader>m :set mouse=""<cr>

" Wrapping
if v:version >= 703
    set colorcolumn=80  " Set 80th column as a colored column
endif
set textwidth=72    " Wrap at 72 columns

" Toggle wrapping on/off
noremap <leader>w :set textwidth=0<cr>:set fo-=ct<cr>
noremap <leader>W :set textwidth=72<cr>:set fo+=ct<cr>

" c -> Wrap comments
" r -> Continue comments at <enter>
" q -> Allow reformatting of comments with <block>gq
" n -> Recognize numbered lists
" j -> Join removes comment leaders 
if v:version > 703
    set formatoptions+=crqnj
else
    set formatoptions+=crqn
endif

" Note that <leader>W turns this on (even though we turn it off
" by default here - \W after \w doesn't go back to default)...
set formatoptions-=t " Turn off text wrapping by default

" Folding options
" zC -> Fold all levels
" zO -> Open at position (all levels)
if v:version > 702
    set foldmethod=indent
    set nofoldenable
endif

" Highlight columns and rows
noremap <leader>+ :set cursorline cursorcolumn<cr>
noremap <leader>- :set nocursorline nocursorcolumn<cr>

" This lets us globally do something like set background dark
if filereadable(expand("~/.vim/vimrc.local"))
    source ~/.vim/vimrc.local
endif

" Allow toggling between light and dark background using F5 or C-b
call togglebg#map("<F5>")
call togglebg#map("<C-b>")

" gitgutter configuration
let g:gitgutter_sign_columns_always=1 " Always provide space for the signs,
                                      "  so that windows line up better
let g:gitgutter_max_signs=50000       " We can edit a big file, allow up to
                                      "  50,000 lines to change.
