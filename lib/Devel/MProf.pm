# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package Devel::MProf;
use strict;
use warnings;
use Hook::LexWrap;

our $VERSION = '0.00_00';

my $deep = 0;
*CORE::GLOBAL::caller = sub {
    my ($height) = ($_[0]||0);
    my $i=1;
    my $name_cache;
    while (1) {
        my @caller = CORE::caller($i++) or return;
        $caller[3] = $name_cache if $name_cache;
        $name_cache = $caller[0] eq 'Hook::LexWrap' ? $caller[3] : '';
        next if $name_cache || $height-- != 0;
        return wantarray ? @_ ? @caller : @caller[0..2] : $caller[0];
    }
};

my $size = sub { 
    $deep = 1;
    open my $m, '<', "/proc/$$/statm" or die "failed to open statm $!";
    my $line = <$m>;
    $line =~ /^(\d+)\s/; # <size> ...
    $deep = 0;
    return $1;
};

sub DB::sub {
    my @args = @_;
    my $s = $DB::sub;

    my $skip = 1; #($s =~ /(?:Exporter|MProf|vars)/);

    if (!ref $s && !$deep && !$skip) {
        no strict 'refs';
        no warnings 'redefine';
        
        my $saved = *{$s}{CODE};
        *{$s} = sub { 
            my ($SR, @AR);
            
            print {*STDERR} "* my caller is ". join(':',caller). "\n";
            
            my $before = $size->();
            
            if (!defined wantarray) {
                $saved->(@args);
            }
            elsif (wantarray) {
                @AR = $saved->(@args);
            }
            else {
                $SR = $saved->(@args);
            }
            
            my $after = $size->();
            
            print {*STDERR} 
              "** $s used ". ($after-$before). " kbytes ($before->$after)\n";
            
            return @AR if @AR;
            return $SR if defined $SR;
            return;
        };
    }
    
    goto &$s;
}

sub DB::DB {};

1;
