package GuitarPro::Utils;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT = qw(
    quote
);

sub quote($)
{
    local ($_) = @_;
    s{"}{&quot;}g;
    s{'}{&apos;}g;
    s{<}{&lt;}g;
    s{>}{&gt;}g;
    s{&}{&amp;}g;
    return $_;
}

1;

