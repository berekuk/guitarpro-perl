package GuitarPro::Info;

use strict;
use warnings;

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

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $info = {};

    for (@INFO_FIELDS) {
        $binary_reader->readInt(); # just skip it
        $info->{$_} = $binary_reader->readStringByte();
    }
    return bless $info => $class;
}

1;

