package GuitarPro::Track;

use strict;
use warnings;

use GuitarPro::Track::Track1;
use GuitarPro::Track::Track4;

my %CLASSES = (
    'FICHIER GUITAR PRO v1'    => 'GuitarPro::Track::Track1',
    'FICHIER GUITAR PRO v1.01' => 'GuitarPro::Track::Track1',
    'FICHIER GUITAR PRO v1.02' => 'GuitarPro::Track::Track1',
    'FICHIER GUITAR PRO v1.03' => 'GuitarPro::Track::Track1',
    'FICHIER GUITAR PRO v1.04' => 'GuitarPro::Track::Track1',
    'FICHIER GUITAR PRO v3.00' => 'GuitarPro::Track::Track4',
    'FICHIER GUITAR PRO v4.00' => 'GuitarPro::Track::Track4',
    'FICHIER GUITAR PRO v4.06' => 'GuitarPro::Track::Track4',
    'FICHIER GUITAR PRO L4.06' => 'GuitarPro::Track::Track4',
);

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $subclass = $CLASSES{$binary_reader->version()} or die "Reading track unimplemented for this version";
    return $subclass->load($binary_reader);

}

1;

