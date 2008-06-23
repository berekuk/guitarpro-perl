package GuitarPro::MixTableChange;

use strict;
use warnings;

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $change = {};

    my @byte_fields = qw(instrument volume pan chorus reverb phaser tremolo);
    for (@byte_fields) {
        $change->{$_} = $binary_reader->readByte();
    }
    $change->{tempo} = $binary_reader->readInt();

    for (@byte_fields) {
        $change->{$_."_duration"} = $binary_reader->readByte();
    }
    $change->{tempo_duration} = $binary_reader->readByte();

    $change->{apply_byte} = $binary_reader->readByte(); # TODO - parse specific bits

    return bless $change => $class;
}

1;

