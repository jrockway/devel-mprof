# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package Devel::MProf;
use strict;
use warnings;

our $VERSION = '0.00_00';

package DB;
my $sth;
BEGIN { open OUT, '>', 'mprof.out' or die "failed to open mprof.out: $!" };
END { close OUT }
our $deep = 0;

sub size {
    $deep = 1;

    open M, '<', "/proc/$$/statm" or die "failed to open statm: $!";
    my $line = join '', <M>;
    $line =~ /^(\d+)\s/; # <size> ...
    close M;
    
    $deep = 0;
    return $1;
};

sub record {
    $deep = 1;
    print OUT join ':',@_;
    print OUT "\n";
    $deep = 0;
}

my $DEEP = 100;
my @stack;

sub sub {
    no strict 'refs';
    push(@stack, $DB::single);
    $DB::single &= 1;
    $DB::single |= 4 if $#stack == $DEEP;

    my ($before,$after);
    if (!$deep) {
        $before = size();
    }

    my $void = $DB::sub eq 'DESTROY' || 
      substr($DB::sub, -9) eq '::DESTROY' ||
        not defined wantarray;

    if ($void){
        &$DB::sub;
    }
    elsif (wantarray) {
        @DB::ret = &$DB::sub;
    }
    else {
        $DB::ret = &$DB::sub;
    }
    $DB::single |= pop(@stack);

    if (!$deep) {
        $after = size();
        record($DB::sub, $before, $after);
    }
    
    if ($void) {
        $DB::ret = undef;
        return $DB::ret;
    }
    elsif (wantarray) {
        return @DB::ret;
    }
    else {
        return $DB::ret;
    }
}

sub DB {};

1;
