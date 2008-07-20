package GuitarPro::Note::Note4;

use strict;
use warnings;

our @ISA = qw(GuitarPro::Note);

use GuitarPro::NoteEffects;
use GuitarPro::Header;

my $HEADER_NAMES = {
    DURATION => 0,
    DOTTED   => 1,
    GHOST    => 2,
    EFFECTS  => 3,
    DYNAMIC  => 4,
    TYPE     => 5,
    ACCENT   => 6,
    HAND     => 7,
};

sub load($$$)
{
    my ($class, $binary_reader, $context) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $note = bless {%$context} => $class;

    my $header = new GuitarPro::Header($binary_reader->readByte());
    $header->set_names($HEADER_NAMES);
    $note->{header} = $header;

    if ($header->has('TYPE')) {
        $note->{type} = $binary_reader->readByte(); # another lie from documentation, this is NOT short
    }

    if ($header->has('DURATION')) {
        $note->{duration} = $binary_reader->readByte();
        $note->{duration_tuplet} = $binary_reader->readByte();
    }

    if ($header->has('DYNAMIC')) {
        $note->{dynamic} = $binary_reader->readByte();
    } else {
        $note->{dynamic} = 6; # forte
    }

    if ($header->has('TYPE')) {
        $note->{fret} = $binary_reader->readByte();
    }

    if ($header->has('HAND')) {
        $note->{left_land_finger} = $binary_reader->readByte();
        $note->{right_land_finger} = $binary_reader->readByte();
    }

    if ($header->has('EFFECTS')) {
        $note->{effects} = GuitarPro::NoteEffects->load($binary_reader);
    }

    return $note;
}

1;
