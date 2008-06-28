package GuitarPro::Track;

use strict;
use warnings;

use constant {
    TRACK_DRUMS => 0,
    TRACK_12_STRINGS => 1,
    TRACK_BANJO => 2,
};

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $track = {};
    my $header = $binary_reader->readByte();
    my @bits = split "", unpack "b8", chr($header);
    $track->{header} = [@bits]; # TODO - define constants naming each flag

    $track->{name} = $binary_reader->readStringByte(40);
    $track->{strings_count} = $binary_reader->readInt();

    $track->{strings_tuning} = [];
    for my $i (1..7) {
        my $tuning = $binary_reader->readInt();
        next if $i > $track->{strings_count};
        push @{$track->{strings_tuning}}, $tuning;
    }
    $track->{port} = $binary_reader->readInt();
    $track->{channel} = $binary_reader->readInt();
    $track->{channel_effects} = $binary_reader->readInt();
    $track->{frets} = $binary_reader->readInt();
    $track->{capo} = $binary_reader->readInt();
    $track->{color} = $binary_reader->readInt(); # FIXME - create color object
    return bless $track => $class;
}

sub xml($)
{
    my ($self) = @_;
    return "<track>not implemented</track>";
}

1;

