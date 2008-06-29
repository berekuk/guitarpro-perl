package GuitarPro::Measure;

use strict;
use warnings;

use constant {
    MEASURE_NUMERATOR => 0,
    MEASURE_DENOMINATOR => 1,
    MEASURE_BEGIN_REPEAT => 2,
    MEASURE_END_REPEAT => 3,
    MEASURE_ALT_ENDING_NUMBER => 4,
    MEASURE_MARKER => 5,
    MEASURE_TONALITY => 6,
    MEASURE_DOUBLE_BAR => 7,
};

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $measure = {};
    my $header = $binary_reader->readByte();
    my @bits = split "", unpack "b8", chr($header);
    $measure->{header} = [@bits]; # TODO - define constants naming each flag
    if ($bits[MEASURE_NUMERATOR]) {
        $measure->{numerator} = $binary_reader->readUnsignedByte();
        if ($measure->{numerator} > 20) {
            die "Broken numerator $measure->{numerator}";
        }
    }
    if ($bits[MEASURE_DENOMINATOR]) {
        $measure->{denominator} = $binary_reader->readUnsignedByte();
        if ($measure->{denominator} > 20) {
            die "Broken denominator $measure->{denominator}";
        }
    }
    if ($bits[MEASURE_END_REPEAT]) {
        $measure->{repeats_count} = $binary_reader->readUnsignedByte();
        if ($measure->{repeats_count} > 50) {
            die "Broken repeats count $measure->{repeats_count}"; # TODO - can this happen sometimes?
        }
    }
    if ($bits[MEASURE_ALT_ENDING_NUMBER]) {
        $measure->{alt_ending_number} = $binary_reader->readByte();
    }
    if ($bits[MEASURE_MARKER]) {
        $binary_reader->readInt(); # marker name length
        $measure->{marker} = $binary_reader->readStringByte();
        $measure->{marker_color} = $binary_reader->readInt(); # TODO - write readColor() method
    }
    if ($bits[MEASURE_TONALITY]) {
        $measure->{tonality_type} = $binary_reader->readByte(); # TODO: need some enum representation
        $measure->{tonality} = $binary_reader->readByte();
    }
    return bless $measure => $class;
}

sub xml($)
{
    my ($self) = @_;
    my $xml = "<measure>";
    for my $prop (qw(numerator denominator repeats_count alt_ending_number marker marker_color tonality_type tonality)) {
        $xml .= "<$prop>$self->{$prop}</$prop>" if $self->{$prop};
    }
    if ($self->{header}[MEASURE_BEGIN_REPEAT]) {
        $xml .= "<begin-repeat/>";
    }
    if ($self->{header}[MEASURE_END_REPEAT]) {
        if ($self->{repeats_count} == 2) {
            $xml .= "<end-repeat/>";
        } else {
            $xml .= qq{<end-repeat count="$self->{repeats_count}"/>};
        }
    }
    if ($self->{header}[MEASURE_ALT_ENDING_NUMBER]) {
        $xml .= "<alt-ending>$self->{alt_ending_number}</alt-ending>";
    }
    $xml .= "</measure>";
    return $xml;
}

1;

