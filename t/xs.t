#!perl
use strict;
use Test::More;

use URI::Encode::XS;pass 'imported module';

is URI::Encode::XS::uri_encode("something"), 'something', 'encode something';
is URI::Encode::XS::uri_encode(" "), '%20', 'encode space';
is URI::Encode::XS::uri_encode("|abcå"), "%7Cabc%C3%A5";

# from URI::Escape t/escape.t
is URI::Encode::XS::uri_encode("~*'()"), "~%2A%27%28%29";
is URI::Encode::XS::uri_encode("<\">"), "%3C%22%3E";
eval { URI::Encode::XS::uri_encode(undef) };
like $@, qr/uri_encode\(\) requires a scalar argument to encode!/, 'croak on undef';


#is URI::Encode::XS::uri_encode("abc", "b-d"), "a%62%63";
done_testing();
