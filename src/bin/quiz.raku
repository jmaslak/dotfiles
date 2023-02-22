#!/usr/bin/env raku
use v6.d;

#
# Copyright © 2023 Joelle Maslak
# All Rights Reserved - See License
#

sub MAIN(Str:D $dir = "/home/jmaslak/git/antelope/joelles-notes") {
    my ($file, $line_number, $word_number, $word);
    while ! $word.defined {
        $file = get_random_file($dir);
        my @lines = $file.slurp.lines();
        next unless @lines.elems;

        $line_number = @lines.elems.rand.Int;
        my @words = @lines[$line_number].words;
        next unless @words.elems;

        $word_number = @words.elems.rand.Int;
        $word = @words[$word_number];
        $word = Str unless $word ~~ m/^ <[a..z A..Z]>+ $/;
    }

    my $get_word = "";
    while $get_word ne $word {
        say "FIND: { $file.Str }, line { $line_number+1 }, word { $word_number + 1 }";
        print "Please enter the word: ";
        my $line = $*IN.get;
        $get_word = $line.trim;
        if $get_word ne $word {
            say "Wrong word.";
        }
    }
}

sub get_random_word(IO:D $file --> Str) {
    my @contents = $file.slurp.words;
    say @contents;
    return @contents.pick;
}

sub get_random_file(Str:D $dir --> IO) {
    my @tree = get_dir_tree($dir);

    return @tree.pick;
}

multi sub get_dir_tree(Str:D $dir) {
    return get_dir_tree($dir.IO);
}

multi sub get_dir_tree(IO:D $dir) {
    my @all = $dir.dir;
    @all = @all.grep( { not m/ ^ \. / and not  m/ \/ \. / } );

    my @files = @all.grep( { $^a.f } );
    my @dirs  = @all.grep( { $^a.d } );

    for @dirs -> $ele {
        @files.append(get_dir_tree($ele));
    }

    return @files;
}

