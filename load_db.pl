#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use DBI;

my $dbh = DBI->connect('DBI:SQLite:mprof', undef, undef, { AutoCommit => 0} );
$dbh->do('CREATE TABLE f(id INTEGER PRIMARY KEY, function TEXT, before INT, after INT)');
$dbh->do('CREATE INDEX functions on f(function)');

my $sth = $dbh->prepare('INSERT INTO f VALUES(NULL,?,?,?)');

while (<>) {
    my ($func, $before, $after) = /^(.+):(\d+):(\d+)$/;
    $sth->execute($func, $before, $after);
}

$dbh->commit;
