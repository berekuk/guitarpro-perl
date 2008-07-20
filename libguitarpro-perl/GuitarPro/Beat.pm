package GuitarPro::Beat;

use strict;
use warnings;

use GuitarPro::Beat::Beat1;
use GuitarPro::Beat::Beat4;

my %CLASSES = (
    'FICHIER GUITARE PRO v1'    => 'GuitarPro::Beat::Beat1',
    'FICHIER GUITARE PRO v1.01' => 'GuitarPro::Beat::Beat1',
    'FICHIER GUITARE PRO v1.02' => 'GuitarPro::Beat::Beat1',
    'FICHIER GUITARE PRO v1.03' => 'GuitarPro::Beat::Beat1',
    'FICHIER GUITARE PRO v1.04' => 'GuitarPro::Beat::Beat1',
    'FICHIER GUITAR PRO v4.06' => 'GuitarPro::Beat::Beat4',
);

sub load($$;$)
{
    my ($class, $binary_reader, $context) = @_; # context is some hash with version-specific data which is needed for loading
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $subclass = $CLASSES{$binary_reader->version()} or die "Reading beat unimplemented for this version";
    return $subclass->load($binary_reader, $context);
}

sub xml($)
{
    my ($self) = @_;
    my $xml = "<beat>";

    if (exists $self->{status}) {
        $xml .= "<status>$self->{status}</status>";
    }
    $xml .= "<duration>$self->{duration}</duration>";
    $xml .= "<length>$self->{length}</length>" if $self->{length};

    for my $note (@{$self->{notes}}) {
        $xml .= $note->xml();
    }

    if ($self->{text}) {
        $xml .= "<text>".quote($self->{text})."</text>";
    }
    if ($self->{chord_diagram}) {
        $xml .= $self->{chord_diagram}->xml()
    }
    $xml .= "</beat>";
    return $xml;
}

1;
