package GuitarPro::ChordDiagram;

use strict;
use warnings;

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $chord = {};

    my $header = $binary_reader->readByte();
    die unless $header == 1;
    $chord->{header} = $header;
    $chord->{sharp} = $binary_reader->readByte();

    # blank
    $binary_reader->readByte();
    $binary_reader->readByte();
    $binary_reader->readByte();

    $chord->{root} = $binary_reader->readByte();
    $chord->{type} = $binary_reader->readByte(); # major/minor
    $chord->{NET} = $binary_reader->readByte(); # Nine, Eleven or Thirteen (???)
    $chord->{bass} = $binary_reader->readInt();
    $chord->{tonality} = $binary_reader->readInt(); # 0: perfect ("juste"); 1: augmented; 2: diminished
    $chord->{add} = $binary_reader->readByte();
    $chord->{name} = $binary_reader->readStringByte(20);

    # blank
    $binary_reader->readByte();
    $binary_reader->readByte();

    $chord->{fifth_tonality} = $binary_reader->readByte();
    $chord->{ninth_tonality} = $binary_reader->readByte(); # only if NET is 11 or 13
    $chord->{eleventh_tonality} = $binary_reader->readByte(); # only if NET is 13
    $chord->{base_fret} = $binary_reader->readInt();

    $chord->{frets} = [];
    for my $string (0..6) {
        push @{$chord->{frets}}, $binary_reader->readInt();
    }

    $chord->{barres_count} = $binary_reader->readByte();
    $chord->{barre_frets} = [];
    for my $barre (0..4) {
        push @{$chord->{barre_frets}}, $binary_reader->readByte();
    }
    $chord->{barre_starts} = [];
    for my $barre (0..4) {
        push @{$chord->{barre_starts}}, $binary_reader->readByte();
    }
    $chord->{barre_ends} = [];
    for my $barre (0..4) {
        push @{$chord->{barre_ends}}, $binary_reader->readByte();
    }

    # TODO - what is this? they all skipped in dguitar
    $chord->{omission1} = $binary_reader->readByte();
    $chord->{omission3} = $binary_reader->readByte();
    $chord->{omission5} = $binary_reader->readByte();
    $chord->{omission7} = $binary_reader->readByte();
    $chord->{omission9} = $binary_reader->readByte();
    $chord->{omission11} = $binary_reader->readByte();
    $chord->{omission13} = $binary_reader->readByte();
    $binary_reader->readByte();

    $chord->{fingering} = [];
    for my $string (0..6) {
        push @{$chord->{fingering}}, $binary_reader->readByte();
    }

    $chord->{show_diag_fingering} = $binary_reader->readByte();

    return bless $chord => $class;
}

sub xml($)
{
    my ($self) = @_;
    my $xml = "<chord>";
    $xml .= "<name>$self->{name}</name>";
    $xml .= "</chord>";
    return $xml;
}

1;

