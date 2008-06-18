package GuitarPro::BinaryReader;

sub new($$)
{
    my ($class, $bytes) = @_;
    my $self = {
        position => 0,
        bytes => $bytes,
    };
    return bless $self => $class;
}

sub readUnsignedByte($)
{
    my ($self) = @_;
    my $byte = unpack "x$self->{position}c1", $self->{bytes};
    $self->{position}++;
    return $byte;
}

sub readBytes($$)
{
    my ($self, $count) = @_;
    my $bytes = unpack "x$self->{position}a$count", $self->{bytes};
    $self->{position} += $count;
    return $bytes;
}

sub readStringByte($;$)
{
    my ($self, $expected_length) = @_;
    my $real_length = $self->readUnsignedByte();
    my $string = $self->readBytes($expected_length);
    $string = substr($string, 0, $real_length);
    return $string;
}

1;
