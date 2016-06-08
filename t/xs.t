#!perl
use strict;
use Test::More;

use URI::Encode::XS;pass 'imported module';

subtest encode => sub {
  is URI::Encode::XS::uri_encode("something"), 'something';
  is URI::Encode::XS::uri_encode(" "), '%20';
  is URI::Encode::XS::uri_encode("|abcå"), "%7Cabc%C3%A5";

  # from URI::Escape t/escape.t
  is URI::Encode::XS::uri_encode("~*'()"), "~%2A%27%28%29";
  is URI::Encode::XS::uri_encode("<\">"), "%3C%22%3E";

};

subtest decode => sub {
  is URI::Encode::XS::uri_decode("something"), 'something';
  is URI::Encode::XS::uri_decode('%20'), ' ';
  is URI::Encode::XS::uri_decode("%7Cabc%C3%A5"), "|abcå";
  is URI::Encode::XS::uri_decode("~%2A%27%28%29"), "~*'()";
  is URI::Encode::XS::uri_decode("%3C%22%3E"), "<\">";
};

subtest exceptions => sub {
  eval { URI::Encode::XS::uri_encode(undef) };
  like $@, qr/uri_encode\(\) requires a scalar argument to encode!/, 'croak on undef';
  eval { URI::Encode::XS::uri_decode(undef) };
  like $@, qr/uri_decode\(\) requires a scalar argument to decode!/, 'croak on undef';
};

done_testing();
