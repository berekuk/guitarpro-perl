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
    ($self->{subversion}) = $self->{version} =~ m{\.0(\d)}; # nothing to do with SVN :)
    $self->{subversion} ||= 0;
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

sub readStringByteSized($)
{
    my ($self) = @_;
    my $expected_length = $self->readUnsignedByte() - 1;
    return $self->readStringByte($expected_length);
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

sub skip($$)
{
    my ($self, $count) = @_;
    for (0..($count - 1)) {
        $self->readByte();
    }
}

sub position($)
{
    my ($self) = @_;
    return $self->{position};
}

sub length($)
{
    my ($self) = @_;
    return length($self->{bytes});
}

sub version($)
{
    my ($self) = @_;
    return $self->{version};
}

sub subversion($)
{
    my ($self) = @_;
    return $self->{subversion};
}

1;
