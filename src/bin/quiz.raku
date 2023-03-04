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

    my $file_pretty = $file.Str;
    $file_pretty ~~ s/$dir/.../;

    my $get_word = "";
    while $get_word.fc ne $word.fc {
        say "FIND: { $file_pretty }, line { $line_number+1 }, word { $word_number+1 }";
        print "Please enter the word: ";
        my $line = $*IN.get;
        $get_word = $line.trim;
        if $get_word.fc ne $word.fc {
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

sub get_dir_tree(IO:D() $dir) {
    my @all = $dir.dir;
    @all = @all.grep( { not m/ ^ \. / and not  m/ \/ \. / and not m/^ "1-1" $/ } );

    my @files = @all.grep( { $^a.f } );
    my @dirs  = @all.grep( { $^a.d } );

    for @dirs -> $ele {
        @files.append(get_dir_tree($ele));
    }

    return @files;
}

