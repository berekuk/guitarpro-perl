package GuitarPro::MidiChannel;

use strict;
use warnings;

sub load($$$)
{
    my ($class, $binary_reader, $id) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $channel = {id => $id};
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

sub is_empty($)
{
    my ($self) = @_;
    for my $prop (qw(instrument volume balance chorus reverb phaser tremolo)) {
        return 0 if $self->{$prop};
    }
    return 1;
}

sub xml($)
{
    my ($self) = @_;
    my $xml = qq{<midi-channel id="$self->{id}">};

    for my $prop (qw(instrument volume balance chorus reverb phaser tremolo)) {
        $xml .= "<$prop>$self->{$prop}</$prop>" if $self->{$prop};
    }

    $xml .= "</midi-channel>";
    return $xml;
}

1;

