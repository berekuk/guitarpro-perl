package GuitarPro::Info;

use strict;
use warnings;

use GuitarPro::Utils;

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
    my $notices_count = $binary_reader->readInt();
    $info->{notices} = [];
    for my $i (0..($notices_count - 1)) {
        $binary_reader->readInt(); # just skip it
        push @{$info->{notices}}, $binary_reader->readStringByte();

    }
    $info->{triplet_feel} = $binary_reader->readByte();

    return bless $info => $class;
}

sub xml($)
{
    my ($self) = @_;
    return "<info>"
        .join('', map {"<$_>".quote($self->{$_})."</$_>"} grep { $self->{$_} } @INFO_FIELDS)
        ."</info>";
}

1;

