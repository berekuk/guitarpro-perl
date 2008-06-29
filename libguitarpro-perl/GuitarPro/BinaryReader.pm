package GuitarPro::BinaryReader;

use strict;
use warnings;

sub new($$)
{
    my ($class, $bytes) = @_;
    my $self = {
        position => 0,
        bytes => $bytes,
    };
    $self = bless $self => $class;
    $self->{version} = $self->readStringByte(30);
    return $self;
}

sub readUnsignedByte($)
{
    my ($self) = @_;
    my $byte = unpack "x$self->{position}C1", $self->{bytes};
    $self->{position}++;
    return $byte;
}

sub readShort($)
{
    my ($self) = @_;
    my $short = unpack "x$self->{position}S", $self->{bytes};
    $self->{position} += 2;
    return $short;
}

sub readInt($)
{
    my ($self) = @_;
    my $int = unpack "x$self->{position}i", $self->{bytes};
    $self->{position} += 4;
    return $int;
}

sub readByte($)
{
    my ($self) = @_;
    my $byte = unpack "x$self->{position}c1", $self->{bytes};
    $self->{position}++;
    return $byte;
}

sub readBytes($$)
{
    my ($self, $count) = @_;
    return '' unless $count;
    my $bytes = unpack "x$self->{position}a$count", $self->{bytes};
    $self->{position} += $count;
    return $bytes;
}

sub readStringByte($;$)
{
    my ($self, $expected_length) = @_;
    my $real_length = $self->readUnsignedByte();
    $expected_length ||= $real_length;
    my $string = $self->readBytes($expected_length);
    $string = substr($string, 0, $real_length);
    return $string;
}

sub readStringInteger($)
{
    my ($self) = @_;
    my $length = $self->readInt();
    my $string = $self->readBytes($length);
    return $string;
}

sub position($)
{
    my ($self) = @_;
    return $self->{position};
}

sub version($)
{
    my ($self) = @_;
    return $self->{version};
}

1;
