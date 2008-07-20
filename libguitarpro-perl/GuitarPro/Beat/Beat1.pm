package GuitarPro::Beat::Beat1;

use strict;
use warnings;

use base qw(GuitarPro::Beat);

use GuitarPro::Note;
use GuitarPro::ChordDiagram;

my $HEADER_NAMES = {
    TEXT => 0,
    CHORD_DIAGRAM => 1,
    EFFECTS => 2,
    REST    => 3,
    DOTTED  => 4,
    TUPLET  => 5,
    LINKED  => 6,
};

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $beat = bless {} => $class;

    $beat->{duration} = $binary_reader->readByte();

    my $header = new GuitarPro::Header($binary_reader->readByte());
    $header->set_names($HEADER_NAMES);
    $beat->{header} = $header;

    if ($header->has('LINKED')) {
        $beat->{linked} = 1; # FIXME - should link with previous note, actually
    }
    if ($header->has('TUPLET')) {
        $binary_reader->readUnsignedByte();
    }

    if ($header->has('EFFECTS')) {
        $beat->{effects} = GuitarPro::BeatEffects->load($binary_reader);
    }
    if ($header->has('CHORD_DIAGRAM')) {
        $beat->{chord_diagram} = GuitarPro::ChordDiagram->load($binary_reader);
    }

    if ($header->has('TEXT')) {
        $beat->{text} = $binary_reader->readStringByte();
    }

    if ($header->has('LINKED') || $header->has('REST')) {
        return $beat;
    }

    my $strings_header = new GuitarPro::Header($binary_reader->readByte());
    my $string_effects_header = new GuitarPro::Header($binary_reader->readByte());

    $beat->{notes} = [];
    for my $string (5,4,3,2,1,0) {
        next unless $strings_header->bit($string);
        my $note = GuitarPro::Note->load($binary_reader, {string => $string});
        if ($string_effects_header->bit($string)) {
            $note->effects(GuitarPro::NoteEffects->load($binary_reader));
        }
        push @{$beat->{notes}}, $note;
    }

    return $beat;
}

sub duration($)
{
    my ($self) = @_;
    return $self->{duration};
}

sub set_length($$)
{
    my ($self, $length) = @_;
    $self->{length} = $length;
}

1;

