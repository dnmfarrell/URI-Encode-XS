#!perl
use strict;
use Test::More;

use URI::Encode::XS qw/uri_encode uri_decode/;pass 'imported module';

subtest encode => sub {
  is uri_encode("something"), 'something';
  is uri_encode(" "), '%20';
  is uri_encode("|abcå"), "%7Cabc%C3%A5";

  # from URI::Escape t/escape.t
  is uri_encode("~*'()"), "~%2A%27%28%29";
  is uri_encode("<\">"), "%3C%22%3E";
};

subtest decode => sub {
  is uri_decode("something"), 'something';
  is uri_decode("something%"), 'something', 'ignore trailing percent';
  is uri_decode('something%a'), 'somethinga', 'ignore trailing percent';
  is uri_decode('%20'), ' ';
  is uri_decode("%7Cabc%C3%A5"), "|abcå";
  is uri_decode("~%2A%27%28%29"), "~*'()";
  is uri_decode("%3C%22%3E"), "<\">";
};

subtest exceptions => sub {
  eval { URI::Encode::XS::uri_encode('') };
  like $@, qr/uri_encode\(\) requires a scalar argument to encode!/, 'croak on empty string';
  eval { URI::Encode::XS::uri_decode('') };
  like $@, qr/uri_decode\(\) requires a scalar argument to decode!/, 'croak on empty string';
  eval { URI::Encode::XS::uri_encode(undef) };
  like $@, qr/uri_encode\(\) requires a scalar argument to encode!/, 'croak on undef';
  eval { URI::Encode::XS::uri_decode(undef) };
  like $@, qr/uri_decode\(\) requires a scalar argument to decode!/, 'croak on undef';
};

done_testing();
