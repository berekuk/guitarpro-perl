package GuitarPro::Piece;

use strict;
use warnings;

use GuitarPro::BinaryReader;

use GuitarPro::Info;
use GuitarPro::MidiChannel;
use GuitarPro::Measure;
use GuitarPro::Track;
use GuitarPro::MeasureTrackPair;

use GuitarPro::Utils;

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

    $self->{info} = GuitarPro::Info->load($binary_reader);

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
        my $channel = GuitarPro::MidiChannel->load($binary_reader);
        push @{$self->{midi_channels}}, $channel;
    }
    $self->{measures_count} = $binary_reader->readInt();
    $self->{tracks_count} = $binary_reader->readInt();

    ### BODY ###

    # measures
    $self->{measures} = [];
    for my $i (0..($self->{measures_count} - 1)) {
        my $measure = GuitarPro::Measure->load($binary_reader);
        push @{$self->{measures}}, $measure;
    }

    # tracks
    $self->{tracks} = [];
    for my $i (0..($self->{tracks_count} - 1)) {
        my $track = GuitarPro::Track->load($binary_reader);
        push @{$self->{tracks}}, $track;
    }

    # measure-track pairs, beats
    $self->{mtp} = [];
    my $mtp_count = $self->{measures_count} * $self->{tracks_count};
    for my $i (0..($mtp_count - 1)) {
        eval {
            push @{$self->{mtp}}, GuitarPro::MeasureTrackPair->load($binary_reader);
        }; if ($@) {
            warn $@;
            last;
        }
    }

    delete $self->{bytes};
    return bless $self => $class;
}

sub version($)
{
    my ($self) = @_;
    return $self->{version};
}

sub info($)
{
    my ($self) = @_;
    return $self->{info};
}

sub measures_count($)
{
    my ($self) = @_;
    return $self->{measures_count};
}

sub measure($$)
{
    my ($self, $id) = @_;
    return $self->{measures}[$id];
}

sub xml($)
{
    my ($self) = @_;
    return "<piece>"
        ."<version>".quote($self->version())."</version>"
        .$self->info->xml()."</piece>";
}

1;

