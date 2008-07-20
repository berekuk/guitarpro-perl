package GuitarPro::Measure::Measure4;

use strict;
use warnings;

use GuitarPro::Header;

my $HEADER_NAMES = {
    NUMERATOR => 0,
    DENOMINATOR => 1,
    BEGIN_REPEAT => 2,
    END_REPEAT => 3,
    ALT_ENDING_NUMBER => 4,
    MARKER => 5,
    TONALITY => 6,
    DOUBLE_BAR => 7,
};

use base qw(GuitarPro::Measure);

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $measure = {};
    my $header = new GuitarPro::Header($binary_reader->readByte());
    $header->set_names($HEADER_NAMES);
    $measure->{header} = $header;
    if ($header->has('NUMERATOR')) {
        $measure->{numerator} = $binary_reader->readUnsignedByte();
        if ($measure->{numerator} > 20) {
            die "Broken numerator $measure->{numerator}";
        }
    }
    if ($header->has('DENOMINATOR')) {
        $measure->{denominator} = $binary_reader->readUnsignedByte();
        if ($measure->{denominator} > 20) {
            die "Broken denominator $measure->{denominator}";
        }
    }
    if ($header->has('END_REPEAT')) {
        $measure->{repeats_count} = $binary_reader->readUnsignedByte();
        if ($measure->{repeats_count} > 50) {
            die "Broken repeats count $measure->{repeats_count}"; # TODO - can this happen sometimes?
        }
    }
    if ($header->has('ALT_ENDING_NUMBER')) {
        $measure->{alt_ending_number} = $binary_reader->readByte();
    }
    if ($header->has('MARKER')) {
        $binary_reader->readInt(); # marker name length
        $measure->{marker} = $binary_reader->readStringByte();
        $measure->{marker_color} = $binary_reader->readInt(); # TODO - write readColor() method
    }
    if ($header->has('TONALITY')) {
        $measure->{tonality_type} = $binary_reader->readByte(); # TODO: need some enum representation
        $measure->{tonality} = $binary_reader->readByte();
    }
    return bless $measure => $class;
}

sub prop_list($)
{
    return qw(numerator denominator repeats_count alt_ending_number marker marker_color tonality_type tonality);
}

1;

