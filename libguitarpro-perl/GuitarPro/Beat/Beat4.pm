package GuitarPro::Beat::Beat4;

use strict;
use warnings;

our @ISA = qw(GuitarPro::Beat);

use GuitarPro::ChordDiagram;
use GuitarPro::BeatEffects;
use GuitarPro::MixTableChange;
use GuitarPro::Note;

use GuitarPro::Utils;

my $HEADER_NAMES = {
    DOTTED => 0,
    CHORD_DIAGRAM => 1,
    TEXT => 2,
    EFFECTS => 3,
    MIX_TABLE => 4,
    TUPLET => 5,
    STATUS => 6,
};

our %STATUSES = (
    0   => 'empty',
    2   => 'rest',
);

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $beat = bless {} => $class;

    my $header = new GuitarPro::Header($binary_reader->readByte());
    $header->set_names($HEADER_NAMES);
    $beat->{header} = $header;

    if ($header->has('STATUS')) {
        my $status = $binary_reader->readUnsignedByte();
        $beat->{status} = $STATUSES{$status} or die "Unknown beat status $beat->{status}";
    }
    $beat->{duration} = $binary_reader->readByte();
    if ($header->has('TUPLET')) {
        $beat->{tuplet} = $binary_reader->readInt();
    }

    if ($header->has('CHORD_DIAGRAM')) {
        $beat->{chord_diagram} = GuitarPro::ChordDiagram->load($binary_reader);
    }

    if ($header->has('TEXT')) {
        my $text_length = $binary_reader->readInt();
        $beat->{text} = $binary_reader->readStringByte();
    }

    if ($header->has('EFFECTS')) {
        $beat->{effects} = GuitarPro::BeatEffects->load($binary_reader);
    }

    if ($header->has('MIX_TABLE')) {
        $beat->{mix_table_change} = GuitarPro::MixTableChange->load($binary_reader);
    }

    # from source of dguitar, again (specification is wrong here, it talks about one note)
    my $strings_header = new GuitarPro::Header($binary_reader->readByte());

    $beat->{notes} = [];
    for my $string (6,5,4,3,2,1,0) {
        next unless $strings_header->bit($string);
        push @{$beat->{notes}}, GuitarPro::Note->load($binary_reader, {string => $string});
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


