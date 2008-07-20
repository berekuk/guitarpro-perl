package GuitarPro::MeasureTrackPair;

use strict;
use warnings;

use GuitarPro::Beat;

sub load($$$)
{
    my ($class, $binary_reader, $context) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $pair = {%$context}; # at least track_id + measure_id, optional number_of_beats
    unless (exists $pair->{number_of_beats}) {
        $pair->{number_of_beats} = $binary_reader->readInt();
    }
    $pair->{beats} = [];
    for my $i (1..$pair->{number_of_beats}) {
        push @{$pair->{beats}}, GuitarPro::Beat->load($binary_reader);
    }

    return bless $pair => $class;
}

sub beats($)
{
    my ($self) = @_;
    return @{$self->{beats}};
}

sub measure_id($)
{
    my ($self) = @_;
    return $self->{measure_id};
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

