package GuitarPro::Piece;

use strict;
use warnings;

use GuitarPro::BinaryReader;
use GuitarPro::Piece::Piece4;

our %KNOWN_VERSIONS = (
    'FICHIER GUITAR PRO v1'    => 'GuitarPro::Piece::Piece1',
    'FICHIER GUITAR PRO v1.01' => 'GuitarPro::Piece::Piece1',
    'FICHIER GUITAR PRO v1.02' => 'GuitarPro::Piece::Piece1',
    'FICHIER GUITAR PRO v1.03' => 'GuitarPro::Piece::Piece1',
    'FICHIER GUITAR PRO v1.04' => 'GuitarPro::Piece::Piece1',
    'FICHIER GUITAR PRO v3.00' => 'GuitarPro::Piece::Piece3',
    'FICHIER GUITAR PRO v4.06' => 'GuitarPro::Piece::Piece4',
    'FICHIER GUITAR PRO v4.00' => 'GuitarPro::Piece::Piece4',
    'FICHIER GUITAR PRO L4.06' => 'GuitarPro::Piece::Piece4',
);

sub new($$)
{
    my ($class, $props) = @_;
    die "Expected hashref" unless ref $props eq 'HASH';
    die "file not specified" unless $props->{file};
    my $bytes;

    if (ref($props->{file})  eq 'GLOB') {
        my $fh = $props->{file};
        $bytes = join '', <$fh>;
    } elsif (ref($props->{file}) eq 'SCALAR') {
        # ref to string with data
        $bytes = ${$props->{file}};
    } else {
        # probably filename
        open my $fh, $props->{file} or die "Can't read $props->{file}: $!"; 
        $bytes = join '', <$fh>;
    }

    my $binary_reader = new GuitarPro::BinaryReader($bytes);
    my $subclass = $KNOWN_VERSIONS{$binary_reader->version()} or
        die "Unknown version ".$binary_reader->version;
    my $piece = $subclass->load($binary_reader);
    if ($binary_reader->position() != length($bytes)) {
        warn "Position ".$binary_reader->position().", file size: ", length($bytes);
    }
    return $piece;
}
1;
