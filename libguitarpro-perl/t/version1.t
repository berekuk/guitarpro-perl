#!/usr/bin/perl

use Test::More  tests => 2;

use strict;
use warnings;

use lib '.';

BEGIN {
    use_ok('GuitarPro::Piece');
}

TODO: {
    local $TODO = "unimplemented";

    my $piece = eval {new GuitarPro::Piece({file => 't/data/version1.gtp'})};
    if ($@) {
        fail("parsing version1: $@");
    } else {
        is($piece->version, 'FICHIER GUITARE PRO v1', 'parsing version1');
    }
}

