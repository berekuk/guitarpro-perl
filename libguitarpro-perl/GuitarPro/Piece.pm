package GuitarPro::Piece;

use strict;
use warnings;

use GuitarPro::BinaryReader;

sub new($$)
{
    my ($class, $props) = @_;
    die "Expected hashref" unless ref $props eq 'HASH';
    die "file not specified" unless $props->{file};
    open my $fh, $props->{file} or die "Can't read $props->{file}: $!";
    my $bytes = join '', <$fh>;

    my $binary_reader = new GuitarPro::BinaryReader($bytes);

    my $version_string = $binary_reader->readStringByte(30);

    my $self = {
        bytes => $bytes,
        version => $version_string,
    };
    return bless $self => $class;
}

sub version($)
{
    my ($self) = @_;
    return $self->{version};
}

1;