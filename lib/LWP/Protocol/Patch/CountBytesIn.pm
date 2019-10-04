package LWP::Protocol::Patch::CountBytesIn;

# DATE
# VERSION

use 5.010001;
use strict 'subs', 'vars';
no warnings;
use Log::ger;

use Module::Patch ();
use base qw(Module::Patch);

use Scalar::Util qw(refaddr);

our %config;
our $bytes_in = 0;

sub _get_byte_size {
    my($self, @strings) = @_;
    my $bytes = 0;

    {
        use bytes;
        for my $string (@strings) {
            $bytes += length($string);
        }
    }

    return $bytes;
}

sub _wrap_collect {
    my $ctx = shift;

    my ($self, $arg, $response, $collector) = @_;

    push @{ $response->{handlers}{response_data} }, {
        callback => sub {
            $bytes_in += _get_byte_size(__PACKAGE__, $_[3]);
        },
    };

    $ctx->{orig}->(@_);
}

sub patch_data {
    return {
        v => 3,
        config => {
        },
        patches => [
            {
                action => 'wrap',
                #mod_version => qr/^6\./,
                sub_name => 'collect',
                code => \&_wrap_collect,
            },
        ],
    };
}

1;
# ABSTRACT: Count bytes in

=head1 SYNOPSIS

 use LWP::Protocol::Patch::CountBytesIn;

 # ... use LWP

 printf "Total downloaded : %9d bytes\n", $LWP::Protocol::Patch::CountBytesIn::bytes_in;


=head1 DESCRIPTION


=head1 SEE ALSO

L<IO::Socket::ByteCounter>

=cut
