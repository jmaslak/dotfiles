" Copyright (C) 2025 Joelle Maslak
" Everything pretty much should be UTF-8 by now
set encoding=utf-8

" Some environments don't set the shell right, which causes
" issues with gitgutter and probably other things that assume
" the shell is actually bash and not sh.
if $SHELL != "/bin/sh"
    " do nothing
elseif !empty(glob("/bin/bash"))
    set shell=/bin/bash
elseif !empty(glob("/usr/bin/bash"))
    set shell=/usr/bin/bash
endif

execute pathogen#infect()

" Set digraphs - for instance, type » by using > <BS> > instead of
" just <ctrl-k> > >
" set digraph  " This became quite annoying
if v:version >= 701
    digraphs ca 128042 " 🐪  - We need this for Perl.  :)
    digraphs po 128169 " 💩 - Pile of Poo
    digraphs ee 8715   " ∋  - Contains
    digraphs e/ 8716   " ∌  - Does not contain
    digraphs (- 8712   " ∈  - Element of
    digraphs (/ 8713   " ∉  - Not element of
    digraphs 4^ 8308   " Superscript 4
    digraphs 5^ 8309   " Superscript 5
    digraphs 6^ 8310   " Superscript 6
    digraphs 7^ 8311   " Superscript 7
    digraphs 8^ 8312   " Superscript 8
    digraphs 9^ 8313   " Superscript 9
    digraphs 0^ 8304   " Superscript 0
endif
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
"   Co → copyright ©
"   ee -> contains as member ∋
"   e/ -> does not contain as member ∌
"   th -> thorn þ

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
    " let g:solarized_bold=0
    if has("gui_win32")
        set guifont=Consolas:h10:cANSI
    endif
endif

syntax enable                 " Set syntax highlighting

" If we are not on Windows *or* if we're running Windows gvim
if ( ! has("win32") ) || has("gui_running")
    " We use a light lucius theme
    " set background=light            " Light background
    " colorscheme lucius
    set background=dark
    colorscheme desert256
    highlight CursorLine cterm=NONE ctermbg=235
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
if v:version >= 703
    set matchpairs+=<:>,«:»             " Allow % to bounce between angles
else
    set matchpairs+=<:>                 " Can't do angles on old vim
endif
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

" Set spell check colors
highlight SpellBad ctermbg=yellow ctermfg=darkgray
highlight SpellLocal ctermbg=cyan ctermfg=darkgray

" Use templates to create new files
if has("win32")
    autocmd BufNewFile * silent! 0r $USERPROFILE\vimfiles\templates/%:e.template
else
    autocmd BufNewFile * silent! 0r ~/.vim/templates/%:e.template
endif

filetype plugin indent on

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

" Rust
au FileType rust setl smarttab autoindent et
au BufNewFile,BufRead *.rs set filetype=rust

" Haskel
au FileType haskell setl smarttab autoindent sw=4 sts=4 et

" Perl 5
" Set "K" to go to perldoc -f
au FileType perl setl keywordprg=perldoc\ -f

" But not .ep!
au FileType .ep setl nosmarttab noautoindent

" Go
au FileType go setl noet sts=8 sw=8 listchars=tab:\ \ 
au FileType go GoInstallBinaries
if v:version < 705 " Don't give go VIM version warnings on old VIMs
    let g:go_version_warning = 0
endif

" Spell checking in POD
let perl_include_pod = 1

" Highlight extended vars
let perl_extended_vars = 1

" Increase context distance
let perl_sync_dist = 250

" Perl tidy, use :Tidy
command! -range=% -nargs=* Tidy <line1>,<line2>!
  \perltidy <args>

" Uncrustify
command! -range=% -nargs=* Uncrustify <line1>,<line2>!
  \uncrustify -q <args>

" Perl critic, use :Critic
command! Critic
    \ execute 'silent !rm -f errors.err'
    \ | execute 'silent !perlcritic % --quiet --verbose "\%f:\%l:\%m (\%p)\\n" >errors.err'
    \ | redraw!
    \ | cf
" Use cf (first), cn (next), and cp (previous) to go through file

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
autocmd FileType perl setl errorformat+=%f:%l:%m

" Perl 6
au BufNewFile,BufRead *.p6,*.pl6,*.pm6,*.t6,*.xt6,*.raku,*.rakumod,*.rakutest set filetype=raku

" check for Raku code
" Modified from original David Færrel article at
"   http://perltricks.com/article/194/2015/9/22/Activating-Perl-6-syntax-highlighting-in-Vim/
"
" This allows us to check possibly-not-raku-files for raku hints
"
function! LooksLikeRaku()
  if getline(1) =~# '^#!.*perl6'
    set filetype=raku
  elseif getline(1) =~# '^#!.*raku'
    set filetype=raku
  else
    for i in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
      if getline(i) == 'use v6;'
        set filetype=raku
        break
      elseif getline(i) == 'use v6.c;'
        set filetype=raku
        break
      elseif getline(i) == 'use v6.d;'
        set filetype=raku
        break
      elseif getline(i) == 'use v6.e;'
        set filetype=raku
        break
      endif
    endfor
  endif
endfunction

" Enable automatic unicode abbreviations
let g:raku_unicode_abbrevs = 1

au BufNewFile,BufRead *.pl,*.pm,*.t,*.xt call LooksLikeRaku()
" Add keyword characters for Raku
autocmd FileType raku setl iskeyword+=$
autocmd FileType raku setl iskeyword+=%
autocmd FileType raku setl iskeyword+=@-@
autocmd FileType raku setl iskeyword+=:
autocmd FileType raku setl iskeyword+=,

" Turn off some substitutions
autocmd FileType raku iabbrev <buffer> / /
autocmd FileType raku iabbrev <buffer> * *
autocmd FileType raku iabbrev <buffer> e e
autocmd FileType raku iabbrev <buffer> / /

autocmd FileType raku iabbrev <buffer> div ÷
autocmd FileType raku iabbrev <buffer> mul ×

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
au FileType tex setl tw=72 formatoptions+=t noexpandtab shiftwidth=8 softtabstop=8 spell

" Cool
au BufNewFile,BufRead *.cl set filetype=cool
au FileType cool setl nospell

" C++
au FileType cpp setl cinoptions+=g2
au FileType cpp setl softtabstop=2 shiftwidth=2 expandtab

" C
au BufNewFile,BufRead *.h set filetype=c
au filetype c setl expandtab        " Expand Tabs to Spaces
au filetype c setl sts=4            " Soft Tabs = 4 spaces
au filetype c setl sw=4             " Shift Width = 4 spaces on indenting

" JSON
au filetype json setl sts=2 sw=2 expandtab

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
" work on 703
if v:version >= 703
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
    highlight ColorColumn ctermbg=52
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
" noremap <leader>+ :set cursorline cursorcolumn<cr>
" noremap <leader>- :set nocursorline nocursorcolumn<cr>
" Change this to just do the line:
noremap <leader>+ :set cursorline<cr>
noremap <leader>- :set nocursorline<cr>

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

" vim-go doesn't like neovim < 0.3.2
let g:go_version_warning = 0

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

" Set by default the cursor line
set cursorline

" Set up printing
set printfont=Courier:h8
set printoptions=number:y,paper:letter,duplex:off

if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

" Set up cursor
if has('nvim')
    set guicursor=n-v-c:blinkon1,i-ci-ve:ver25-Cursor2/lCursor2,r-cr:hor20,o:hor50
    au VimLeave * set guicursor=a:ver25-blinkon0
endif

" Disable virtualenvs
let g:pymode_virtualenv = 0

" Disable pylint
let g:pymode_lint = 0

" Set wrapping in Python mode, which means we need to turn off default
" options)
let g:pymode_options = 0
