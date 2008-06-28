package GuitarPro::MeasureTrackPair;

use strict;
use warnings;

use GuitarPro::Beat;

sub load($$$$)
{
    my ($class, $binary_reader, $track_id, $measure_id) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $pair = {track_id => $track_id, measure_id => $measure_id};
    $pair->{number_of_beats} = $binary_reader->readInt();
    $pair->{beats} = [];
    for my $i (1..$pair->{number_of_beats}) {
        push @{$pair->{beats}}, GuitarPro::Beat->load($binary_reader);
    }

    return bless $pair => $class;
}

sub xml($)
{
    my ($self) = @_;
    my $xml = qq{<mtp track-id="}.($self->{track_id}+1).q{" measure-id="}.($self->{measure_id}+1).q{">};
    for my $beat (@{$self->{beats}}) {
        $xml .= $beat->xml();
    }
    $xml .= "</mtp>";
    return $xml;
}

1;

