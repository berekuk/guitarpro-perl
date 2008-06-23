package GuitarPro::MeasureTrackPair;

use strict;
use warnings;

use GuitarPro::Beat;

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $pair = {};
    $pair->{number_of_beats} = $binary_reader->readInt();
    $pair->{beats} = [];
    for my $i (1..$pair->{number_of_beats}) {
        push @{$pair->{beats}}, GuitarPro::Beat->load($binary_reader);
    }

    return bless $pair => $class;
}

1;

