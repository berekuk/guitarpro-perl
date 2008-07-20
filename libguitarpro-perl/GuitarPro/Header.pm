package GuitarPro::Header;

use strict;
use warnings;

sub new($$@)
{
    my ($class, @bytes) = @_;
    my @bits;
    for my $byte (@bytes) {
        push @bits, split "", unpack "b8", chr($byte);
    }
    my $self = bless {bits => [@bits]} => $class;
    return $self;
}

# set names for each field
sub set_names($$)
{
    my ($self, $names) = @_;
    $self->{names} = $names; # hashref expected
}

# get bit by name
sub has($$)
{
    my ($self, $name) = @_;
    die "No names" unless exists $self->{names};
    return $self->{bits}[$self->{names}{$name}];
}

# get bit by id
sub bit($$)
{
    my ($self, $id) = @_;
    return $self->{bits}[$id];
}

1;

