package GuitarPro::Note::Note1;

use strict;
use warnings;

use base qw(GuitarPro::Note);

sub load($$$)
{
    my ($class, $binary_reader, $context) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $note = bless {%$context} => $class; # TODO - check presence of key 'string' key in context

    my $fret = $binary_reader->readUnsignedByte();
    if ($fret == 100) {
        $note->{type} = 3; # FIXME - decode this into string
    } else {
        $note->{fret} = $fret;
    }

    return $note;
}

1;

