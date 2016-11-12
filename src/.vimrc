" Everything pretty much should be UTF-8 by now
set encoding=utf-8

" Set proper plugin directories
if has("win32")
    set runtimepath^=$USERPROFILE\vimfiles\bundle\vim-ps1
else
    set runtimepath^=~/.vim/bundle/vim-ps1
endif

" Some environments don't set the shell right, which causes
" issues with gitgutter and probably other things that assume
" the shell is actually bash and not sh.
if !empty(glob("/bin/bash"))
    set shell=/bin/bash
elseif !empty(glob("/usr/bin/bash"))
    set shell=/usr/bin/bash
endif

" If we are not on Windows *or* if we're running Windows gvim
if ( ! has("win32") ) || has("gui_running")
    " We use a light solarized theme
    set background=light            " Light background
    colorscheme solarized
else
    " We need a dark background because this is being run from
    " a Windows command prompt
    set background=dark
    colorscheme industry  " Always present & readable, albeit ugly
endif

" Set digraphs - for instance, type » by using > <BS> > instead of
" just <ctrl-k> > >
" set digraph  " This became quite annoying
digraphs ca 128042 " 🐪  - We need this for Perl.  :)
digraphs ee 8715   " ∋  - Contains
digraphs e/ 8716   " ∌  - Does not contain
"
" Useful digraphs:
"   ca → camel 🐪
"   -> → right arrow →
"   << → double left arrow «
"   >> → double right arrow »
"   12 → one half ½
"   2S → superscript two ²   (also 22)
"   3S → superscript three ³ (also 33)
"   00 → infinity ∞
"   -: → divsiion ÷
"   p* → pi π
"   c0 → copyright ©
"   ee -> contains as member ∋
"   e/ -> does not contain as member ∌

" Modelines can be a security risk - know you did this...
set modeline
set modelines=5

" This means there will be 5 lines above/below the cursor on the
" screen at all times.  This is an alternative to zz (which centers)
set scrolloff=5

set ruler                           " Ruler at bottom
set number                          " Line Numbering
set t_Co=256                        " We do 256 colors

" Set GUI font & turn off bold
if has("gui_running")
    let g:solarized_bold=0
    if has("gui_win32")
        set guifont=Consolas:h10:cANSI
    endif
endif

" If we are not on Windows *or* if we're running Windows gvim
if ( ! has("win32") ) || has("gui_running")
    " We use a light solarized theme
    set background=light            " Light background
    colorscheme solarized
else
    " We need a dark background because this is being run from
    " a Windows command prompt
    set background=dark
    colorscheme industry  " Always present & readable, albeit ugly
endif

" Swapfile configuration
set swapfile
if !has("win32")
    set dir=~/tmp
else
    set dir=$TMP
endif

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

" \c will add comments to lines
nnoremap <leader>c :s/^/#--/<cr>:noh<cr>
vnoremap <leader>c :s/^/#--/<cr>:noh<cr>
" \C will remove tabs
nnoremap <leader>C :s/^#--//<cr>:noh<cr>
vnoremap <leader>C :s/^#--//<cr>:noh<cr>

" vaa selects whole file
vmap aa Vgo1G

" backspace, %, C++ options
set backspace=indent,eol,start      " Let me do anything with backspace!
set matchpairs+=<:>,«:»             " Allow % to bounce between angles
let loaded_delimitMate=1            " Disable delimitMate
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
if has("win32")
    autocmd BufNewFile * silent! 0r $USERPROFILE\vimfiles\templates/%:e.template
else
    autocmd BufNewFile * silent! 0r ~/.vim/templates/%:e.template
endif

filetype plugin indent on
syntax enable                 " Set syntax highlighting

"
" Filetype setup
"

" Git commit
au FileType gitcommit setl spell

" Markdown
au FileType markdown setl spell textwidth=72 fo+=t autoindent smarttab

" Text
au FileType text setl spell textwidth=72 fo+=t

" Ruby
au FileType ruby setl sw=2 sts=2 et

" ASM
au FileType asm setl smarttab autoindent

" CSS
au BufNewFile,BufRead *.less set filetype=css
au FileType css set sts=2          " Soft Tabs = 2 spaces
au FileType css set sw=2           " Shift Width = 2 spaces on indenting

" Haskel
au FileType haskell setl smarttab autoindent sw=4 sts=4 et

" Perl 5
" Set "K" to go to perldoc -f
au FileType perl setl keywordprg=perldoc\ -f

" Spell checking in POD
let perl_include_pod = 1

" Highlight extended vars
let perl_extended_vars = 1

" Increase context distance
let perl_sync_dist = 250

" Perl tidy, use :Tidy
command! -range=% -nargs=* Tidy <line1>,<line2>!
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
" Add keyword characters for Perl
autocmd FileType perl setl iskeyword+=$
autocmd FileType perl setl iskeyword+=%
autocmd FileType perl setl iskeyword+=@-@
autocmd FileType perl setl iskeyword+=:
autocmd FileType perl setl iskeyword+=,

" Perl 6
au BufNewFile,BufRead *.p6,*.pl6,*.pm6,*.t6,*.xt6 set filetype=perl6

" check for Perl 6 code
" Modified from original David Færrel article at
"   http://perltricks.com/article/194/2015/9/22/Activating-Perl-6-syntax-highlighting-in-Vim/
"
" This allows us to check possibly-not-perl6-files for perl6 hints
"
function! LooksLikePerl6 ()
  if getline(1) =~# '^#!.*perl6'
    set filetype=perl6
  else
    for i in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
      if getline(i) == 'use v6;'
        set filetype=perl6
        break
      endif
    endfor
  endif
endfunction

au BufNewFile,BufRead *.pl,*.pm,*.t,*.xt call LooksLikePerl6()
" Add keyword characters for Perl6
autocmd FileType perl6 setl iskeyword+=$
autocmd FileType perl6 setl iskeyword+=%
autocmd FileType perl6 setl iskeyword+=@-@
autocmd FileType perl6 setl iskeyword+=:
autocmd FileType perl6 setl iskeyword+=,

" Apache
" Preserve indent levels
au FileType apache setlocal indentexpr= autoindent

au FileType html set sts=2          " Soft Tabs = 2 spaces
au FileType html set sw=2           " Shift Width = 2 spaces on indenting

" XML
au FileType xml  set sts=2          " Soft Tabs = 2 spaces
au FileType xml  set sw=2           " Shift Width = 2 spaces on indenting
au Filetype xml  set autoindent

" PowerShell
au BufNewFile,BufRead *.ps1 set filetype=ps1
au FileType ps1  set sts=4          " Soft Tabs = 4 spaces
au FileType ps1  set sw=4           " Shift Width = 4 spaces on indenting
au Filetype ps1  set autoindent

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
" Note that the version was 703 for some reason, but I think this should
" work on 702
if v:version >= 702
    " The next line has a trailing space.
    set listchars=tab:\→\ 
else
    set listchars=
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
" It will default off
" I'm guessing this is the version that started with mouse support
if v:version > 702
    set mouse=""
    nnoremap <leader>M :set mouse=a<cr>
    nnoremap <leader>m :set mouse=""<cr>
endif

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

" Just rows
noremap <leader>L :set cursorline<cr>
noremap <leader>l :set nocursorline<cr>

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

" set persistent undo
if has('persistent_undo')
    if !has("win32")
        set undodir=~/tmp
    else
        set undodir=$TMP
    endif

    set undolevels=5000             " Allow a lot of undo
    set undofile
endif

" From Damian Conway's .VIMRC
" Reload config file/plugins
augroup VimReload
autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END

" From Damian Conway's .VIMRC
" Build interim directoreis
function! AskQuit (msg, options, quit_option)
    if confirm(a:msg, a:options) == a:quit_option
        quit!  " Damian had exit, but that doesn't work with templates
    endif
endfunction

function! EnsureDirExists ()
    let required_dir = expand("%:h")
    if !isdirectory(required_dir)
        call AskQuit("Parent directory '" . required_dir . "' doesn't exist.",
            \        "&Create it\nor &Quit", 2)
        try
            call mkdir( required_dir, 'p' )
        catch
            call AskQuit("Can't create '" . required_dir . "'"
                \        "&Quit\nor &Continue anyway?", 1)
        endtry
    endif
endfunction

augroup AutoMkdir
    autocmd!
    autocmd  BufNewFile * :call EnsureDirExists()
augroup END

" Converts a filename with lib in it to a Perl module name
function! FilenameToPerlMod (pathname)
    let modulename = substitute( a:pathname, '/', '::', "g" )  " Linux
    let modulename = substitute( modulename, '\\', '::', "g" ) " Windows 32

    if match(modulename, '^\(.*::\)\=lib::.*\.pm$') == -1
        return '<INSERT_NAME_HERE>'
    endif

    let modulename = substitute( modulename, '^\(.*::\)\=lib::', '', "" )
    let modulename = substitute( modulename, '\.pm$', '', "" )
    return modulename
endfunction
autocmd BufNewFile *.pm exec "1,10s/<INSERT_NAME_HERE>/" . FilenameToPerlMod(expand("%:f")) . "/g"

