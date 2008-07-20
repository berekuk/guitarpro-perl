package GuitarPro::Info;

use strict;
use warnings;

use GuitarPro::Info::Info1;
use GuitarPro::Info::Info4;
use GuitarPro::Info::Info5;

my %CLASSES = (
    'FICHIER GUITARE PRO v1'    => 'GuitarPro::Info::Info1',
    'FICHIER GUITARE PRO v1.01' => 'GuitarPro::Info::Info1',
    'FICHIER GUITARE PRO v1.02' => 'GuitarPro::Info::Info1',
    'FICHIER GUITARE PRO v1.03' => 'GuitarPro::Info::Info1',
    'FICHIER GUITARE PRO v1.04' => 'GuitarPro::Info::Info1',
    'FICHIER GUITAR PRO v3.00' => 'GuitarPro::Info::Info4',
    'FICHIER GUITAR PRO v4.00' => 'GuitarPro::Info::Info4',
    'FICHIER GUITAR PRO v4.06' => 'GuitarPro::Info::Info4',
    'FICHIER GUITAR PRO L4.06' => 'GuitarPro::Info::Info4',
    'FICHIER GUITAR PRO v5.10' => 'GuitarPro::Info::Info5',
);

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $subclass = $CLASSES{$binary_reader->version()} or die "Reading info unimplemented for this version";
    return $subclass->load($binary_reader);

}

1;

