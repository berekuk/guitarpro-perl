package GuitarPro::Note;

use strict;
use warnings;

use GuitarPro::Note::Note1;
use GuitarPro::Note::Note4;

my %CLASSES = (
    'FICHIER GUITARE PRO v1'    => 'GuitarPro::Note::Note1',
    'FICHIER GUITARE PRO v1.01' => 'GuitarPro::Note::Note1',
    'FICHIER GUITARE PRO v1.02' => 'GuitarPro::Note::Note1',
    'FICHIER GUITARE PRO v1.03' => 'GuitarPro::Note::Note1',
    'FICHIER GUITARE PRO v1.04' => 'GuitarPro::Note::Note1',
    'FICHIER GUITAR PRO v4.06' => 'GuitarPro::Note::Note4',
);

sub load($$;$)
{
    my ($class, $binary_reader, $context) = @_; # context is some hash with version-specific data which is needed for loading
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $subclass = $CLASSES{$binary_reader->version()} or die "Reading note unimplemented for this version";
    return $subclass->load($binary_reader, $context);
}


# TODO - lvalue?
sub effects($;$)
{
    my ($self, $effects) = @_;
    $self->{effects} = $effects if $effects;
    return $self->{effects};
}

sub xml($)
{
    my ($self) = @_;
    my $xml = qq{<note string="$self->{string}">};
    $xml .= "<fret>$self->{fret}</fret>" if exists $self->{fret};
    if ($self->{effects}) {
        $xml .= $self->{effects}->xml();
    }
    $xml .= "</note>";
    return $xml;
}

1;
