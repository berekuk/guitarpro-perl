#!/usr/bin/perl

use Test::More  tests => 2;

use strict;
use warnings;

use lib '.';

BEGIN {
    use_ok('GuitarPro::Piece');
}

my $piece = new GuitarPro::Piece({file => 't/data/test.gp4'});
is($piece->version, 'FICHIER GUITAR PRO v4.06');

