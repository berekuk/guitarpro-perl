package GuitarPro::Lyrics;

use strict;
use warnings;

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');

    my $lyrics = bless {} => $class;
    return $lyrics if $binary_reader->version() eq 'FICHIER GUITAR PRO v3.00'; # FIXME - older versions too?

    $lyrics->{track_id} = $binary_reader->readInt();

    $lyrics->{lines} = [];
    for my $i (0..4) {
        my $measure_number = $binary_reader->readInt(); # not mentioned in doc, copied from dguitar source
        push @{$lyrics->{lines}}, $binary_reader->readStringInteger();
    }
    return $lyrics;
}

sub xml($)
{
    my ($self) = @_;
    return unless exists $self->{lines};
    my $xml = qq{<lyrics track="$self->{track_id}>};
    $xml .= join "\n", grep {$_} @{$self->{lines}};
    $xml .= "</lyrics>";
    return $xml;
}

1;
