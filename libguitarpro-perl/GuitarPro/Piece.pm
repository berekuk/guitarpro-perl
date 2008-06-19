package GuitarPro::Piece;

use strict;
use warnings;

use GuitarPro::BinaryReader;

my @INFO_FIELDS = qw(title subtitle interpret album author copyright tab_author instructional);

{
    no strict 'refs';
    for (@INFO_FIELDS) {
        *{"$_"} = sub($) {
            my ($self) = @_;
            return $self->{$_};
        };
    }
    use strict;
}

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

    for (@INFO_FIELDS) {
        $binary_reader->readInt(); # just skip it
        $self->{$_} = $binary_reader->readStringByte();
    }
    return bless $self => $class;
}

sub version($)
{
    my ($self) = @_;
    return $self->{version};
}

1;

