use strict;
use warnings;
package URI::Encode::XS;

use XSLoader;
use Exporter 5.57 'import';

our $VERSION     = '0.04';
our @EXPORT_OK   = ( qw/uri_encode uri_decode/ );

XSLoader::load('URI::Encode::XS', $VERSION);

1;
__END__
=head1 NAME

URI::Encode::XS - a Perl URI encoder/decoder using C

=head1 SYNOPSIS

  use URI::Encode::XS qw/uri_encode uri_decode/;

  my $encoded = uri_encode($data);
  my $decoded = uri_decode($encoded);

=head1 DESCRIPTION

This is a Perl module that wraps my C URI encoder/decoder based on
L<RFC3986|https://tools.ietf.org/html/rfc3986>. This module always
encodes characters that are not unreserved.

I've benchmarked it and found it significantly faster than URI::Escape at
encoding and decoding:

            Rate escape encode
escape  141724/s     --   -96%
encode 3491116/s  2363%     --
              Rate unescape   decode
unescape  193807/s       --     -96%
decode   4835488/s    2395%       --

However this is just one string - the fewer encoded/decoded characters are
in the string, the closer the benchmark is likely to be (see C<bench> for
details of the benchmark). Different hardware will yield different results.

Another faster encoder/decoder which supports custom escape lists, is
L<URI::XSEscape|https://metacpan.org/pod/URI::XSEscape>.

=head1 INSTALLATION

  $ cpan URI::Encode::XS

Or

  $ git clone https://github.com/dnmfarrell/URI-Encode-XS
  $ cd URI-Encode-XS
  $ perl Makefile.PL
  $ make
  $ make test
  $ make install

=head1 REPOSITORY

L<https://github.com/dnmfarrell/URI-Encode-XS>

=head1 LICENSE

See LICENSE

=head1 AUTHOR

E<copy> 2016 David Farrell

=cut
