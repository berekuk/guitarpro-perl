package GuitarPro::NoteEffects;

use strict;
use warnings;

use GuitarPro::Bend;

use constant {
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
    my $effects = {};

    my $header = $binary_reader->readByte();
    my @bits = split "", unpack "b8", chr($header);
    $header = $binary_reader->readByte();
    push @bits, split "", unpack "b8", chr($header);
    $effects->{bits} = [@bits];

    if ($bits[BEND]) {
        $effects->{bend} = GuitarPro::Bend->load($binary_reader);
    }

    if ($bits[GRACE]) {
        $effects->{grace_fret} = $binary_reader->readByte();
        $effects->{grace_dynamic} = $binary_reader->readByte();
        $effects->{grace_transition} = $binary_reader->readByte();
        $effects->{grace_duration} = $binary_reader->readByte();
    }

    if ($bits[TREMOLO]) {
        $effects->{tremolo} = $binary_reader->readByte();
    }
    if ($bits[SLIDE]) {
        $effects->{slide} = $binary_reader->readByte();
    }
    if ($bits[HARMONIC]) {
        $effects->{harmonic} = $binary_reader->readByte();
    }
    if ($bits[TRILL]) {
        $effects->{trill_fret} = $binary_reader->readByte();
        $effects->{trill_period} = $binary_reader->readByte();
    }

    return bless $effects => $class;
}

sub xml($)
{
    my ($self) = @_;
    my $xml = "<effects>";
    if (exists $self->{slide}) {
        $xml .= "<slide>".$SLIDE_TYPES{$self->{slide}}."</slide>";
    }
    $xml .= "</effects>";
    return $xml;
}

1;

