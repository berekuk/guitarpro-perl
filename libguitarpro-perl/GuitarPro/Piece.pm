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
    my $bytes;

    if (ref($props->{file})  eq 'GLOB') {
        my $fh = $props->{file};
        $bytes = join '', <$fh>;
    } elsif (ref($props->{file}) eq 'SCALAR') {
        # ref to string with data
        $bytes = ${$props->{file}};
    } else {
        # probably filename
        open my $fh, $props->{file} or die "Can't read $props->{file}: $!"; 
        $bytes = join '', <$fh>;
    }

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
        $self->{lyrics}[$i] = $binary_reader->readStringInteger();
    }

    # other information about piece
    $self->{tempo} = $binary_reader->readInt();
    $self->{key} = $binary_reader->readByte(); # TODO - translate into key names
    $self->{octave} = $binary_reader->readInt();

    $self->{midi_channels} = [];
    for my $id (0..63) {
        my $channel = GuitarPro::MidiChannel->load($binary_reader, $id);
        push @{$self->{midi_channels}}, $channel;
    }
    $self->{measures_count} = $binary_reader->readInt();
    if ($self->{measures_count} < 0 || $self->{measures_count} > 10000) {
        die "Broken measure count $self->{measures_count}";
    }
    $self->{tracks_count} = $binary_reader->readInt();
    if ($self->{tracks_count} < 0 || $self->{tracks_count} > 10000) {
        die "Broken measure count $self->{measures_count}";
    }

    ### BODY ###

    # measures
    $self->{measures} = [];
    for my $id (0..($self->{measures_count} - 1)) {
        my $measure = GuitarPro::Measure->load($binary_reader);
        push @{$self->{measures}}, $measure;
    }

    # tracks
    $self->{tracks} = [];
    for my $id (0..($self->{tracks_count} - 1)) {
        my $track = GuitarPro::Track->load($binary_reader);
        push @{$self->{tracks}}, $track;
    }

    # measure-track pairs, beats
    $self->{mtp} = [];
    for my $measure_id (0..($self->{measures_count}-1)) {
        for my $track_id (0..($self->{tracks_count}-1)) {
            my $mtp;
            eval {
                $mtp = GuitarPro::MeasureTrackPair->load($binary_reader, $track_id, $measure_id);
            }; if ($@) {
                die "Broken mtp[$measure_id, $track_id]: $@";
            }
            push @{$self->{mtp}}, $mtp;
        }
    }

    if ($binary_reader->position() != length($self->{bytes})) {
        warn "Position ".$binary_reader->position().", file size: ", length($self->{bytes});
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

sub lyrics($)
{
    my ($self) = @_;
    my $lyrics = join "\n", grep { $_ } @{$self->{lyrics}};
}

sub xml($)
{
    my ($self) = @_;
    my $xml = '<piece>';
    $xml .= "<version>".quote($self->version())."</version>";
    $xml .= $self->info->xml();

    my $lyrics = $self->lyrics();
    if ($lyrics =~ /\S+/) {
        $xml .= qq{<lyrics track="$self->{lyrics_track}">}.quote($lyrics).q{</lyrics>};
    }

    $xml .= "<tempo>$self->{tempo}</tempo>";
    $xml .= "<key>$self->{key}</key>";
    $xml .= "<octave>$self->{octave}</octave>";

    $xml .= "<midi-channels>";
    for my $midi_channel (@{$self->{midi_channels}}) {
        next if $midi_channel->is_empty();
        $xml .= $midi_channel->xml();
    }
    $xml .= "</midi-channels>";

    $xml .= "<measures>";
    for my $measure (@{$self->{measures}}) {
        $xml .= $measure->xml();
    }
    $xml .= "</measures>";

    $xml .= "<tracks>";
    for my $track (@{$self->{tracks}}) {
        $xml .= $track->xml();
    }
    $xml .= "</tracks>";

    $xml .= "<measure-track-pairs>";
    for my $mtp (@{$self->{mtp}}) {
        $xml .= $mtp->xml();
    }
    $xml .= "</measure-track-pairs>";

    $xml .= '</piece>';
    return $xml;
}

1;

