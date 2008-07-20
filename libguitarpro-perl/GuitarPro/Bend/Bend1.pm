package GuitarPro::Bend::Bend1;

use strict;
use warnings;

sub load($$;$)
{
    my ($class, $binary_reader, $context) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $bend = bless {%$context} => $class;
    unless (exists $bend->{type}) {
        die "In version1 type should be specified outside of bend reading";
    }
    $binary_reader->skip(8);
    # FIXME - read something
    # tux-guitar says we should read 7-th byte and build 3 points on that;
    # dguitar says we should read double

    return $bend;
}

1;



