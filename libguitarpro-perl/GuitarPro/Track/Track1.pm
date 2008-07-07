package GuitarPro::Track::Track1;

use strict;
use warnings;

use GuitarPro::Utils;

{
    no strict 'refs';
    for my $field (qw(name strings_count)) {
        *{$field} = sub($;$) {
            my ($self, $value) = @_;
            if (defined $value) {
                $self->{$field} = $value;
            }
            return $self->{$field};
        };
    }
    use strict;
}

sub load($$)
{
    my ($class, $binary_reader) = @_;
    die "Strange reader class" unless $binary_reader->isa('GuitarPro::BinaryReader');
    my $track = bless {} => $class;

    $track->{name} = "Track 1";
    if ($binary_reader->subversion > 1) {
        $track->{strings_count} = $binary_reader->readInt();
    } else {
        $track->{strings_count} = 6;
    }
    $track->{strings_tuning} = [];
    for my $i (1..$track->{strings_count}) {
        push @{$track->{strings_tuning}}, $binary_reader->readInt();
    }
    return $track;
}

sub load_more($$)
{
    my ($self, $binary_reader) = @_;
    $binary_reader->readInt(); # this is channel instrument, FIXME
    if ($binary_reader->subversion > 2) {
        $self->{frets} = $binary_reader->readInt();
        $self->{name} = $binary_reader->readStringByte();
        # channel properties
        $binary_reader->readByte(); # is_solo
        $binary_reader->readInt(); # volume
        $binary_reader->readInt(); # balance
        $binary_reader->readInt(); # chorus
        $binary_reader->readInt(); # reverb
        $binary_reader->readInt(); # offset
    }
}

sub xml($)
{
    my ($self) = @_;
    my $xml = "<track>";
    $xml .= "<name>".quote($self->{name})."</name>";
    $xml .= "</track>";
    return $xml;
}

1;

