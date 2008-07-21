#!/usr/bin/perl

use Test::More  tests => 3;

use strict;
use warnings;

use lib '.';

BEGIN {
    use_ok('GuitarPro::Piece');
}

my $piece = new GuitarPro::Piece({file => 't/data/test.gp4'});
is($piece->version, 'FICHIER GUITAR PRO v4.06');

my $xml = $piece->xml();
ok('xml() method works');

