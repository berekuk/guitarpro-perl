package GuitarPro::NoteEffects::NoteEffects1;

use strict;
use warnings;

our @ISA = qw(GuitarPro::NoteEffects);

use GuitarPro::Bend;

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $effects = bless {} => $class;

    my $type = $binary_reader->readUnsignedByte();
    if ($type == 1) {
        $effects->{hammer} = 1;
    } elsif ($type == 2) {
        $effects->{hammer} = 1;
    } elsif ($type == 3) {
        $effects->{slide} = 'shift-slide'; # this is not good, names should go to basic class
    } elsif ($type == 4) {
        $effects->{slide} = 'out-downwards';
    } elsif ($type == 5) {
        $effects->{bend} = GuitarPro::Bend->load($binary_reader, {type => 'bend'}); # FIXME
    } elsif ($type == 6) {
        $effects->{bend} = GuitarPro::Bend->load($binary_reader, {type => 'bend-and-release'}); # FIXME
    } elsif ($type == 7) {
        $effects->{let_ring} = 1;
    } else {
    }
    return $effects;
}

1;


