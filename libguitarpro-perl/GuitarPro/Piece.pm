package GuitarPro::Piece;

use strict;
use warnings;

use GuitarPro::BinaryReader;

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

sub new($$)
{
    my ($class, $props) = @_;
    die "Expected hashref" unless ref $props eq 'HASH';
    die "file not specified" unless $props->{file};
    open my $fh, $props->{file} or die "Can't read $props->{file}: $!";
    my $bytes = join '', <$fh>;

    my $binary_reader = new GuitarPro::BinaryReader($bytes);

    my $self = {
        bytes => $bytes,
    };

    # version
    my $version_string = $binary_reader->readStringByte(30);
    $self->{version} = $version_string;

    # information about piece
    for (@INFO_FIELDS) {
        $binary_reader->readInt(); # just skip it
        $self->{$_} = $binary_reader->readStringByte();
    }

    # lyrics
    my $lyrics_track = $binary_reader->readInt();
    $self->{lyrics_track} = $lyrics_track;

    $self->{lyrics} = [];
    for my $i (0..4) {
        my $measure_number = $binary_reader->readInt(); # not mentioned in doc, copied from dguitar source
        my $line_length = $binary_reader->readInt();
        $self->{lyrics}[$i] = $binary_reader->readStringByte();
    }

    # other information about piece
    $self->{tempo} = $binary_reader->readInt();
    $self->{key} = $binary_reader->readByte(); # TODO - translate into key names
    $self->{octave} = $binary_reader->readInt();

    $self->{midi_channels} = [];
    for my $i (0..63) {
        my $channel = {};
        $channel->{instrument} = $binary_reader->readInt();
        $channel->{volume} = $binary_reader->readByte();
        $channel->{balance} = $binary_reader->readByte();
        $channel->{chorus} = $binary_reader->readByte();
        $channel->{reverb} = $binary_reader->readByte();
        $channel->{phaser} = $binary_reader->readByte();
        $channel->{tremolo} = $binary_reader->readByte();
        $binary_reader->readByte(); # backward compatibility with 3.0
        $binary_reader->readByte();
        push @{$self->{midi_channels}}, $channel;
    }
    $self->{measures_count} = $binary_reader->readInt();
    $self->{tracks_count} = $binary_reader->readInt();

    ### BODY ###
    # measures
    $self->{measures} = [];
    for my $i (0..$self->{measures_count}) {
        my $measure = {};
        my $header = $binary_reader->readByte();
        my @bits = unpack "b8", $header;
        $measure->{header} = [@bits]; # TODO - define constants naming each flag
        if ($bits[MEASURE_NUMERATOR]) {
            $measure->{numerator} = $binary_reader->readByte();
        }
        if ($bits[MEASURE_DENOMINATOR]) {
            $measure->{denominator} = $binary_reader->readByte();
        }
        if ($bits[MEASURE_END_REPEAT]) {
            $measure->{repeats_count} = $binary_reader->readByte();
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
            $measure->{tonality} = $binary_reader->readByte();
        }
        push @{$self->{measures}}, $measure;
    }

    return bless $self => $class;
}

sub version($)
{
    my ($self) = @_;
    return $self->{version};
}

1;

