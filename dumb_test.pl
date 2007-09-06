#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;

sub test {
    if (!defined wantarray) {
        print "not defined\n";
    }
    elsif (wantarray) {
        print "array\n";
        return (1,2);
    }
    else {
        my @foo = (1..2000000);
        grep { /12343532/ } @foo;
        
        print "scalar\n";
        return 3;
    }
}

test();
my $s = test();
die unless $s == 3;

my @a = test();
die unless $a[0] == 1 && $a[1] == 2;

