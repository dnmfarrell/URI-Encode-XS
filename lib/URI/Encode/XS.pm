use strict;
use warnings;
package URI::Encode::XS;

use XSLoader;
use Exporter 5.57 'import';

our $VERSION     = '0.08';
our @EXPORT_OK   = ( qw/uri_encode uri_encode_utf8 uri_decode uri_decode_utf8/ );

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

This is a Perl URI encoder/decoder written in XS based on L<RFC3986|https://tools.ietf.org/html/rfc3986>.
This module always encodes characters that are not unreserved. When decoding, invalid escape sequences
are preserved, e.g:

  uri_decode("foo%20bar%a/"); # foo bar%a/
  uri_decode("foo%20bar%a");  # foo bar%a
  uri_decode("foo%20bar%");   # foo bar%

As of version 0.08, the C<bench> script shows it to be significantly faster
than C<URI::Escape>:

              Rate escape encode
  escape  142718/s     --   -98%
  encode 7893963/s  5431%     --
                Rate unescape   decode
  unescape  194275/s       --     -97%
  decode   5894526/s    2934%       --

However this is just one string - the fewer encoded/decoded characters are
in the string, the closer the benchmark is likely to be (see C<bench> for
details of the benchmark). Different hardware will yield different results.

Another fast encoder/decoder which supports custom escape lists, is
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

=head1 CONTRIBUTORS

=over 4

=item * L<Christian Hansen|https://github.com/chansen>

=item * Jesse DuMond

=back

=head1 REPOSITORY

L<https://github.com/dnmfarrell/URI-Encode-XS>

=head1 LICENSE

See LICENSE

=head1 AUTHOR

E<copy> 2016 David Farrell

=cut
