#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*
 uri_encode.c - functions for URI percent encoding / decoding
*/

/* original by URI::XSEscape */
static char* uri_encode_tbl[256] =
/*    0     1     2     3     4     5     6     7     8     9     a     b     c     d     e     f */
{
    "%00", "%01", "%02", "%03", "%04", "%05", "%06", "%07", "%08", "%09", "%0A", "%0B", "%0C", "%0D", "%0E", "%0F",  /* 0:   0 ~  15 */
    "%10", "%11", "%12", "%13", "%14", "%15", "%16", "%17", "%18", "%19", "%1A", "%1B", "%1C", "%1D", "%1E", "%1F",  /* 1:  16 ~  31 */
    "%20", "%21", "%22", "%23", "%24", "%25", "%26", "%27", "%28", "%29", "%2A", "%2B", "%2C", 0 , 0 , "%2F",  /* 2:  32 ~  47 */
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , "%3A", "%3B", "%3C", "%3D", "%3E", "%3F",  /* 3:  48 ~  63 */
    "%40", 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,  /* 4:  64 ~  79 */
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , "%5B", "%5C", "%5D", "%5E", 0 ,  /* 5:  80 ~  95 */
    "%60", 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,  /* 6:  96 ~ 111 */
    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0,  "%7B", "%7C", "%7D",  0 , "%7F",  /* 7: 112 ~ 127 */
    "%80", "%81", "%82", "%83", "%84", "%85", "%86", "%87", "%88", "%89", "%8A", "%8B", "%8C", "%8D", "%8E", "%8F",  /* 8: 128 ~ 143 */
    "%90", "%91", "%92", "%93", "%94", "%95", "%96", "%97", "%98", "%99", "%9A", "%9B", "%9C", "%9D", "%9E", "%9F",  /* 9: 144 ~ 159 */
    "%A0", "%A1", "%A2", "%A3", "%A4", "%A5", "%A6", "%A7", "%A8", "%A9", "%AA", "%AB", "%AC", "%AD", "%AE", "%AF",  /* A: 160 ~ 175 */
    "%B0", "%B1", "%B2", "%B3", "%B4", "%B5", "%B6", "%B7", "%B8", "%B9", "%BA", "%BB", "%BC", "%BD", "%BE", "%BF",  /* B: 176 ~ 191 */
    "%C0", "%C1", "%C2", "%C3", "%C4", "%C5", "%C6", "%C7", "%C8", "%C9", "%CA", "%CB", "%CC", "%CD", "%CE", "%CF",  /* C: 192 ~ 207 */
    "%D0", "%D1", "%D2", "%D3", "%D4", "%D5", "%D6", "%D7", "%D8", "%D9", "%DA", "%DB", "%DC", "%DD", "%DE", "%DF",  /* D: 208 ~ 223 */
    "%E0", "%E1", "%E2", "%E3", "%E4", "%E5", "%E6", "%E7", "%E8", "%E9", "%EA", "%EB", "%EC", "%ED", "%EE", "%EF",  /* E: 224 ~ 239 */
    "%F0", "%F1", "%F2", "%F3", "%F4", "%F5", "%F6", "%F7", "%F8", "%F9", "%FA", "%FB", "%FC", "%FD", "%FE", "%FF",  /* F: 240 ~ 255 */
};

/* https://stackoverflow.com/questions/10324/convert-a-hexadecimal-string-to-an-integer-efficiently-in-c
 * thanks to Orwellophile
*/
static const long hextable[] = {
   [0 ... 255] = -1, // bit aligned access into this table is considerably
   ['0'] = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, // faster for most modern processors,
   ['A'] = 10, 11, 12, 13, 14, 15,       // for the space conscious, reduce to
   ['a'] = 10, 11, 12, 13, 14, 15        // signed char.
};

char *uri_encode (char *uri, char *buffer)
{
  unsigned char *uuri = (unsigned char*)uri;
  int i = 0, j = 0;
  while (uuri[i] != '\0')
  {
    char * code = uri_encode_tbl[ uuri[i] ];
    if (code)
    {
      strcat(buffer, code);
      j += 3;
    }
    else
    {
      buffer[j] = uuri[i];
      buffer[j+1] = '\0';
      j++;
    }
    i++;
  }
  return buffer;
}

char *uri_decode (char *uri, char *buffer)
{
  int i = 0, j = 0;
  int len = strlen(uri);
  while(uri[i] != '\0')
  {
    if(uri[i] == '%')
    {
      if (i + 2 < len)
      {
        /* thanks to Jesse DuMond */
        buffer[j] = (hextable[ uri[i+1] ] << 4) | hextable[ uri[i+2] ];
        i += 3;
        j++;
      }
      /* skip trailing percent chars */
      else
      {
        i++;
      }
    }
    else
    {
      buffer[j] = uri[i];
      i++;
      j++;
    }
  }
  buffer[j] = '\0';
  return buffer;
}

MODULE = URI::Encode::XS      PACKAGE = URI::Encode::XS

PROTOTYPES: ENABLED

char *
uri_encode(char *uri)
    CODE:
        if (!uri || *uri == '\0')
        {
          croak("uri_encode() requires a scalar argument to encode!");
        }
        char buffer[ strlen(uri) * 3 + 1 ];
        buffer[0] = '\0';
        uri_encode(uri, buffer);
        RETVAL = buffer;
    OUTPUT: RETVAL

char *
uri_decode(char *uri)
    CODE:
        if (!uri || *uri == '\0')
        {
          croak("uri_decode() requires a scalar argument to decode!");
        }
        char buffer[ strlen(uri) ];
        buffer[0] = '\0';
        uri_decode(uri, buffer);
        RETVAL = buffer;
    OUTPUT: RETVAL

