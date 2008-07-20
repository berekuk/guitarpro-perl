package GuitarPro::Measure::Measure1;

use strict;
use warnings;

use GuitarPro::Header;

our @ISA = qw(GuitarPro::Measure);

my $HEADER_NAMES = {
    BEGIN_REPEAT => 0,
    END_REPEAT => 1,
    ALT_ENDING_NUMBER => 2,
};

sub load($$;$)
{
    my ($class, $binary_reader, $context) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    die "Expected context with tracks ref" unless ref $context eq 'HASH' and exists $context->{tracks};

    my $measure = bless {} => $class;

    $measure->{numerator} = $binary_reader->readUnsignedByte();
    $measure->{denominator} = $binary_reader->readUnsignedByte();

    $binary_reader->skip(6);

    $measure->{number_of_beats} = [];
    for (0..(scalar(@{$context->{tracks}}) - 1)) {
        $binary_reader->readUnsignedByte(); # n
        $binary_reader->readUnsignedByte(); # d
        push @{$measure->{number_of_beats}}, $binary_reader->readUnsignedByte();
        $binary_reader->skip(9);
    }

    $binary_reader->readUnsignedByte(); # n
    $binary_reader->readUnsignedByte(); # d

    $measure->{header} = new GuitarPro::Header($binary_reader->readByte());
    $measure->{header}->set_names($HEADER_NAMES);

    if ($measure->{header}->has('END_REPEAT')) {
        $measure->{repeats_count} = $binary_reader->readUnsignedByte();
        if ($measure->{repeats_count} > 50) {
            die "Broken repeats count $measure->{repeats_count}"; # TODO - can this happen sometimes?
        }
    }
    if ($measure->{header}->has('ALT_ENDING_NUMBER')) {
        $measure->{alt_ending_number} = $binary_reader->readByte();
    }

    return $measure;
}

sub prop_list($)
{
    return qw(numerator denominator repeats_count alt_ending_number);
}

# xml() method from basic class should work

1;
