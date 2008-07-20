#!/usr/bin/perl

use Test::More  tests => 2;

use strict;
use warnings;

use lib '.';

BEGIN {
    use_ok('GuitarPro::Piece');
}

my $piece = eval {new GuitarPro::Piece({file => 't/data/version1.gtp'})};
is($piece->version, 'FICHIER GUITARE PRO v1', 'parsing version1');

