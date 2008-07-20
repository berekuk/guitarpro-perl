package GuitarPro::Bend;

use strict;
use warnings;

use GuitarPro::Bend::Bend1;
use GuitarPro::Bend::Bend4;

my %CLASSES = (
    'FICHIER GUITARE PRO v1'    => 'GuitarPro::Bend::Bend1',
    'FICHIER GUITARE PRO v1.01' => 'GuitarPro::Bend::Bend1',
    'FICHIER GUITARE PRO v1.02' => 'GuitarPro::Bend::Bend1',
    'FICHIER GUITARE PRO v1.03' => 'GuitarPro::Bend::Bend1',
    'FICHIER GUITARE PRO v1.04' => 'GuitarPro::Bend::Bend1',
    'FICHIER GUITAR PRO v4.06' => 'GuitarPro::Bend::Bend4',
);

sub load($$;$)
{
    my ($class, $binary_reader, $context) = @_; # context is some hash with version-specific data which is needed for loading
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $subclass = $CLASSES{$binary_reader->version()} or die "Reading bend unimplemented for this version";
    return $subclass->load($binary_reader, $context);
}

1;

