package GuitarPro::BeatEffects;

use strict;
use warnings;

use constant {
    TPS         => 5,
    STROKE      => 6,
    RASGUEDO    => 8,
    PICKSTROKE  => 9,
    TREMOLO     => 10,
};

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $effects = {};

    my $header = $binary_reader->readByte();
    my @bits = split "", unpack "b8", chr($header);
    $header = $binary_reader->readByte();
    push @bits, split "", unpack "b8", chr($header);
    $effects->{bits} = [@bits];

    if ($bits[TPS]) {
        $effects->{tps} = $binary_reader->readByte();
    }
    if ($bits[TREMOLO]) {
        $effects->{bend} = GuitarPro::Bend->load($binary_reader);
    }
    if ($bits[STROKE]) {
        $effects->{upstroke} = $binary_reader->readByte();
        $effects->{downstroke} = $binary_reader->readByte();
    }
    if ($bits[PICKSTROKE]) {
        $effects->{pickstroke} = $binary_reader->readByte();
    }
    return bless $effects => $class;
}

1;

