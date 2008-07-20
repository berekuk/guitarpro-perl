package GuitarPro::Utils;

use strict;
use warnings;

use Exporter 'import';

use Encode;

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
    # expect latin1 (GuitarPro breaks charsets anyway)
    Encode::from_to($_, 'latin1', 'utf-8');
    s{[\x{000}-\x{008}\x{00B}\x{00C}\x{00E}-\x{01E}]}{}g;
    return $_;
}

1;

