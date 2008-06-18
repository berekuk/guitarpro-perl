package GuitarPro::Reader;

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
    print $version_string;

    my $self = {
        bytes => $bytes,
    };
    return bless $self => $class;
}

1;
