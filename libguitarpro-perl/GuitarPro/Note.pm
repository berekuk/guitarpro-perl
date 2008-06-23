package GuitarPro::Note;

use strict;
use warnings;

use GuitarPro::NoteEffects;

use constant {
    NOTE_DURATION => 0,
    NOTE_DOTTED         => 1,
    NOTE_GHOST          => 2,
    NOTE_EFFECTS        => 3,
    NOTE_DYNAMIC        => 4,
    NOTE_TYPE           => 5,
    NOTE_ACCENT         => 6,
    NOTE_HAND           => 7,
};

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $note = {};

    my $header = $binary_reader->readByte();
    my @bits = split "", unpack "b8", chr($header);
    $note->{header} = [@bits];

    if ($bits[NOTE_TYPE]) {
        $note->{type} = $binary_reader->readByte(); # another lie from documentation, this is NOT short
    }

    if ($bits[NOTE_DURATION]) {
        $note->{duration} = $binary_reader->readByte();
        $note->{duration_tuplet} = $binary_reader->readByte();
    }

    if ($bits[NOTE_DYNAMIC]) {
        $note->{dynamic} = $binary_reader->readByte();
    } else {
        $note->{dynamic} = 6; # forte
    }

    if ($bits[NOTE_TYPE]) {
        $note->{fret} = $binary_reader->readByte();
    }

    if ($bits[NOTE_HAND]) {
        $note->{left_land_finger} = $binary_reader->readByte();
        $note->{right_land_finger} = $binary_reader->readByte();
    }

    if ($bits[NOTE_EFFECTS]) {
        GuitarPro::NoteEffects->load($binary_reader);
    }

    return bless $note => $class;
}

1;
