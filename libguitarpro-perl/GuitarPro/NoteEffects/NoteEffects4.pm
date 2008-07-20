package GuitarPro::NoteEffects::NoteEffects4;

use strict;
use warnings;

use GuitarPro::Header;
use GuitarPro::Bend;

my $HEADER_NAMES = {
    BEND        => 0,
    HAMMER      => 1,
    SLIDE_3     => 2,
    LET_RING    => 3,
    GRACE       => 4,
    STACCATO    => 8,
    PALM_MUTE   => 9,
    TREMOLO     => 10,
    SLIDE       => 11,
    HARMONIC    => 12,
    TRILL       => 13,
    LEFT_VIBRATO => 14,

};

our %SLIDE_TYPES = (
    '-2'    =>  'in-from-above',
    '-1'    =>  'in-from-below',
    '0'     =>  'no-slide',
    '1'     =>  'shift-slide',
    '2'     =>  'legato-slide',
    '3'     =>  'out-downwards',
    '4'     =>  'out-upwards',
);

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $effects = bless {} => $class;

    my $header = new GuitarPro::Header($binary_reader->readByte(), $binary_reader->readByte());
    $header->set_names($HEADER_NAMES);

    if ($header->has('BEND')) {
        $effects->{bend} = GuitarPro::Bend->load($binary_reader);
    }

    if ($header->has('GRACE')) {
        $effects->{grace_fret} = $binary_reader->readByte();
        $effects->{grace_dynamic} = $binary_reader->readByte();
        $effects->{grace_transition} = $binary_reader->readByte();
        $effects->{grace_duration} = $binary_reader->readByte();
    }

    if ($header->has('TREMOLO')) {
        $effects->{tremolo} = $binary_reader->readByte();
    }
    if ($header->has('SLIDE')) {
        $effects->{slide} = $SLIDE_TYPES{$binary_reader->readByte()};
    }
    if ($header->has('HARMONIC')) {
        $effects->{harmonic} = $binary_reader->readByte();
    }
    if ($header->has('TRILL')) {
        $effects->{trill_fret} = $binary_reader->readByte();
        $effects->{trill_period} = $binary_reader->readByte();
    }

    return $effects;
}

1;

