package GuitarPro::Info::Info1;

use strict;
use warnings;

use GuitarPro::Utils;

# TODO: base class

my @INFO_FIELDS = qw(title author instructional);

{
    no strict 'refs';
    for my $field (@INFO_FIELDS) {
        *{$field} = sub($) {
            my ($self) = @_;
            return $self->{$field};
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
        $info->{$_} = $binary_reader->readStringByteSized();
    }

    return bless $info => $class;
}

# get/set method
sub triplet_feel($;$)
{
    my ($self, $value) = @_;
    if (defined $value) {
        $self->{triplet_feel} = $value;
    }
    return $self->{triplet_feel};
}

sub xml($)
{
    my ($self) = @_;
    return "<info>"
        .join('', map {"<$_>".quote($self->{$_})."</$_>"} grep { $self->{$_} } @INFO_FIELDS)
        ."</info>";
}

1;

