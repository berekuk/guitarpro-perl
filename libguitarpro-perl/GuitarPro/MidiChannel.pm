package GuitarPro::MidiChannel;

use strict;
use warnings;

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $channel = {};
    $channel->{instrument} = $binary_reader->readInt();
    $channel->{volume} = $binary_reader->readByte();
    $channel->{balance} = $binary_reader->readByte();
    $channel->{chorus} = $binary_reader->readByte();
    $channel->{reverb} = $binary_reader->readByte();
    $channel->{phaser} = $binary_reader->readByte();
    $channel->{tremolo} = $binary_reader->readByte();
    $binary_reader->readByte(); # backward compatibility with 3.0
    $binary_reader->readByte();
    return bless $channel => $class;
}

1;

