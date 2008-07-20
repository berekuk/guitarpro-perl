package GuitarPro::NoteEffects;

use strict;
use warnings;

use GuitarPro::Utils;

use GuitarPro::NoteEffects::NoteEffects1;
use GuitarPro::NoteEffects::NoteEffects4;

my %CLASSES = (
    'FICHIER GUITARE PRO v1'    => 'GuitarPro::NoteEffects::NoteEffects1',
    'FICHIER GUITARE PRO v1.01' => 'GuitarPro::NoteEffects::NoteEffects1',
    'FICHIER GUITARE PRO v1.02' => 'GuitarPro::NoteEffects::NoteEffects1',
    'FICHIER GUITARE PRO v1.03' => 'GuitarPro::NoteEffects::NoteEffects1',
    'FICHIER GUITARE PRO v1.04' => 'GuitarPro::NoteEffects::NoteEffects1',
    'FICHIER GUITAR PRO v4.06' => 'GuitarPro::NoteEffects::NoteEffects4',
);

# TODO - some base class GuitarPro::Object for all this copypasted code?
sub load($$;$)
{
    my ($class, $binary_reader, $context) = @_; # context is some hash with version-specific data which is needed for loading
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $subclass = $CLASSES{$binary_reader->version()} or die "Reading note effects unimplemented for this version";
    return $subclass->load($binary_reader, $context);
}

sub xml($)
{
    my ($self) = @_;
    my $xml = "<effects>";
    if (exists $self->{slide}) {
        $xml .= "<slide>".quote($self->{slide})."</slide>";
    }
    $xml .= "</effects>";
    return $xml;
}

1;
