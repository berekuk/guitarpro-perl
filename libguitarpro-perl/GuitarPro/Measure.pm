package GuitarPro::Measure;

use strict;
use warnings;

use GuitarPro::Measure::Measure1;
use GuitarPro::Measure::Measure4;
#use GuitarPro::Measure::Measure5;

my %CLASSES = (
    'FICHIER GUITARE PRO v1'    => 'GuitarPro::Measure::Measure1',
    'FICHIER GUITARE PRO v1.01' => 'GuitarPro::Measure::Measure1',
    'FICHIER GUITARE PRO v1.02' => 'GuitarPro::Measure::Measure1',
    'FICHIER GUITARE PRO v1.03' => 'GuitarPro::Measure::Measure1',
    'FICHIER GUITARE PRO v1.04' => 'GuitarPro::Measure::Measure1',
#    'FICHIER GUITAR PRO v3.00' => 'GuitarPro::Measure::Measure4',
#    'FICHIER GUITAR PRO v4.00' => 'GuitarPro::Measure::Measure4',
    'FICHIER GUITAR PRO v4.06' => 'GuitarPro::Measure::Measure4',
#    'FICHIER GUITAR PRO L4.06' => 'GuitarPro::Measure::Measure4',
#    'FICHIER GUITAR PRO v5.10' => 'GuitarPro::Measure::Measure5',
);

sub load($$;$)
{
    my ($class, $binary_reader, $context) = @_; # context is some hash with version-specific data which is needed for loading
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $subclass = $CLASSES{$binary_reader->version()} or die "Reading measure unimplemented for this version";
    return $subclass->load($binary_reader, $context);
}

sub numerator($)
{
    my ($self) = @_;
    return $self->{numerator};
}

sub denominator($)
{
    my ($self) = @_;
    return $self->{denominator};
}

sub xml($)
{
    my ($self) = @_;
    my $xml = "<measure>";
    for my $prop ($self->prop_list()) {
        $xml .= "<$prop>$self->{$prop}</$prop>" if $self->{$prop};
    }
    if ($self->{header}->has('BEGIN_REPEAT')) {
        $xml .= "<begin-repeat/>";
    }
    if ($self->{header}->has('END_REPEAT')) {
        if ($self->{repeats_count} == 2) {
            $xml .= "<end-repeat/>";
        } else {
            $xml .= qq{<end-repeat count="$self->{repeats_count}"/>};
        }
    }
    if ($self->{header}->has('ALT_ENDING_NUMBER')) {
        $xml .= "<alt-ending>$self->{alt_ending_number}</alt-ending>";
    }
    $xml .= "</measure>";
    return $xml;
}

1;
