package GuitarPro::Piece;

use strict;
use warnings;

use GuitarPro::BinaryReader;

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
    $self->{measures_number} = $binary_reader->readInt();
    $self->{tracks_number} = $binary_reader->readInt();

    return bless $self => $class;
}

sub version($)
{
    my ($self) = @_;
    return $self->{version};
}

1;

