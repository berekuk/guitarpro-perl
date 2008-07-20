package GuitarPro::Piece::Piece1;

use strict;
use warnings;

use GuitarPro::BinaryReader;

use GuitarPro::Info;
use GuitarPro::Lyrics;
use GuitarPro::MidiChannel;
use GuitarPro::Measure;
use GuitarPro::Track;
use GuitarPro::MeasureTrackPair;

use GuitarPro::Utils;

sub load($$)
{
    my ($class, $binary_reader) = @_;

    my $self = bless {} => $class;

    # version
    $self->{version} = $binary_reader->version();

    $self->{info} = GuitarPro::Info->load($binary_reader);

    # other information about piece
    $self->{tempo} = $binary_reader->readInt();
    $self->{info}->triplet_feel($binary_reader->readInt());

    if ($binary_reader->subversion > 2) {
        $self->{key} = $binary_reader->readInt();
    } else {
        $self->{key} = 0;
    }

    $self->{octave} = 0;

    if ($binary_reader->subversion > 2) {
        $self->{tracks_count} = 8;
    } else {
        $self->{tracks_count} = 1;
    }

    # read tracks
    $self->{tracks} = [];
    for my $track_id (0..($self->{tracks_count} - 1)) {
        my $track = GuitarPro::Track->load($binary_reader);
        push @{$self->{tracks}}, $track;
    }

    $self->{measures_count} = $binary_reader->readInt();
    if ($self->{measures_count} < 0 || $self->{measures_count} > 10000) {
        die "Broken measure count $self->{measures_count}";
    }

    # read more tracks
    for (@{$self->{tracks}}) {
        $_->load_more($binary_reader);
    }

    if ($binary_reader->subversion > 2) {
        # skip 10 bytes (from tux-guitar source), what is this?
        $binary_reader->skip(10);
    }

    ### BODY ###
    for my $measure_id (0..($self->{measures_count} - 1)) {
        my $measure = GuitarPro::Measure->load($binary_reader, {tracks => $self->{tracks}});
        push @{$self->{measures}}, $measure;
        for my $track_id (0..($self->{tracks_count}-1)) {
            my $mtp;
            eval {
                $mtp = GuitarPro::MeasureTrackPair->load($binary_reader, {
                    track_id => $track_id,
                    measure_id => $measure_id,
                    number_of_beats => $self->{measures}[$measure_id]{number_of_beats}[$track_id],
                });
            }; if ($@) {
                die "Broken mtp[$measure_id, $track_id]: $@";
            }
            push @{$self->{mtp}}, $mtp;
        }
    }
    # TODO - track/measure pairs

    $self->fill_beat_sizes();
    return $self;
}

# fill percent-of-measure for each beat
sub fill_beat_sizes($)
{
    my ($self) = @_;
    my ($numerator, $denominator) = (4, 4); # default values, should it be better to fail?
    my $measure_length = $numerator / $denominator;

    for my $mtp (@{$self->{mtp}}) {
        my $measure = $self->{measures}[$mtp->measure_id()];
        if (my $new_numerator = $measure->numerator()) {
            $numerator = $new_numerator; # mtp's are sorted, so measures are sorted too
            $measure_length = $numerator / $denominator;
        }
        if (my $new_denominator = $measure->denominator()) {
            $denominator = $new_denominator;
            $measure_length = $numerator / $denominator;
        }

        for my $beat ($mtp->beats()) {
            my $d = $beat->duration();
            $beat->set_length($measure_length * 2 ** (-$d-2));
        }
    }
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
    my $xml = '<piece>';
    $xml .= "<version>".quote($self->version())."</version>";
    $xml .= $self->info->xml();

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

