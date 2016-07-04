setlocal iskeyword+=:  " make tags with :: in them useful

if ! exists("s:defined_functions")

if !exists('g:PT_max_level')
    let g:PT_max_level = 4
endif

if !exists('g:PT_use_ppi')
    let g:PT_use_ppi = 0
endif

let s:BIN = fnamemodify(resolve(expand("<sfile>:p")), ":h")

function s:init_tags()
perl <<EOF
    use strict; use warnings;
    our $tagger;

    my $bin = VIM::Eval('s:BIN');
    require "$bin/../perllib/perl-tags/bin/require-perl-tags-packed" or die "Couldn't find Perl::Tags";

    my $max_level = VIM::Eval('g:PT_max_level') || 2;

    my $ppi = VIM::Eval('g:PT_use_ppi');
    my %args = ( max_level => $max_level );

    $tagger = Perl::Tags::Hybrid->new(
        %args,
        taggers => [
            Perl::Tags::Naive::Moose->new( %args ),
            $ppi ? Perl::Tags::PPI->new( %args ) : (),
        ],
    );
EOF
endfunction
 
" let vim do the tempfile cleanup and protection
let s:tagsfile = tempname()
 
function PT_do_tags(filename)
perl <<EOF
    my $filename = VIM::Eval('a:filename');

    if ( ! -r $filename ) { return; } # Unreadable file

    our $tagger;
    $tagger->process(files => $filename, refresh=>1 );

    my $tagsfile=VIM::Eval('s:tagsfile');
    VIM::SetOption("tags+=$tagsfile");

    # of course, it may not even output, for example, if there's nothing new to process
    $tagger->output( outfile => $tagsfile );
EOF
endfunction

function PT_show_tags()
perl <<EOF
    our $tagger;
    VIM::Msg($tagger);
EOF
endfunction
 
call s:init_tags() " only the first time
 
let s:defined_functions = 1
endif
 
call PT_do_tags(expand('%'))
 
" this should probably be added to ftplugin/perl to add the autocommand to
" that buffer?
augroup perltags
    au!
    autocmd BufRead,BufWritePost *.pm,*.pl,*.t call PT_do_tags(expand('%'))
augroup END
