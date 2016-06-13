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
static const char* uri_encode_tbl[256] =
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

#define __ 0xFF
static const unsigned char hexval[0x100] = {
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* 00-0F */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* 10-1F */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* 20-2F */
   0, 1, 2, 3, 4, 5, 6, 7, 8, 9,__,__,__,__,__,__, /* 30-3F */
  __,10,11,12,13,14,15,__,__,__,__,__,__,__,__,__, /* 40-4F */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* 50-5F */
  __,10,11,12,13,14,15,__,__,__,__,__,__,__,__,__, /* 60-6F */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* 70-7F */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* 80-8F */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* 90-9F */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* A0-AF */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* B0-BF */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* C0-CF */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* D0-DF */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* E0-EF */
  __,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__, /* F0-FF */
};
#undef __

size_t uri_encode (const char *src, const size_t len, char *dst)
{
  size_t i = 0, j = 0;
  while (i < len)
  {
    const char * code = uri_encode_tbl[ (unsigned char)src[i] ];
    if (code)
    {
      memcpy(&dst[j], code, 3);
      j += 3;
    }
    else
    {
      dst[j] = src[i];
      j++;
    }
    i++;
  }
  dst[j] = '\0';
  return j;
}

size_t uri_decode (const char *src, const size_t len, char *dst)
{
  size_t i = 0, j = 0;
  while(i < len)
  {
    if(src[i] == '%')
    {
      if (i + 2 < len)
      {
        const unsigned char v1 = hexval[ (unsigned char)src[i+1] ];
        const unsigned char v2 = hexval[ (unsigned char)src[i+2] ];

        /* skip invalid hex sequences */
        if ((v1 | v2) != 0xFF)
        {
          dst[j] = (v1 << 4) | v2;
          j++;
        }
        i += 3;
      }
      /* skip trailing percent chars */
      else
      {
        i++;
      }
    }
    else
    {
      dst[j] = src[i];
      i++;
      j++;
    }
  }
  dst[j] = '\0';
  return j;
}

static void THX_uri_encode_dsv (pTHX_ const char *src, size_t len, SV *dsv)
{
  char *dst;

  SvUPGRADE(dsv, SVt_PV);
  dst = SvGROW(dsv, len * 3 + 1);
  len = uri_encode(src, len, dst);
  SvCUR_set(dsv, len);
  SvPOK_only(dsv);
}

static void THX_uri_decode_dsv (pTHX_ const char *src, size_t len, SV *dsv)
{
  char *dst;

  SvUPGRADE(dsv, SVt_PV);
  dst = SvGROW(dsv, len + 1);
  len = uri_decode(src, len, dst);
  SvCUR_set(dsv, len);
  SvPOK_only(dsv);
}

#define uri_encode_dsv(src, len, dsv) \
  THX_uri_encode_dsv(aTHX_ src, len, dsv)

#define uri_decode_dsv(src, len, dsv) \
  THX_uri_decode_dsv(aTHX_ src, len, dsv)

MODULE = URI::Encode::XS      PACKAGE = URI::Encode::XS

PROTOTYPES: ENABLED

void
uri_encode(SV *uri)
  PREINIT:
    dXSTARG;
    const char *src;
    size_t len;
  PPCODE:
    SvGETMAGIC(uri);
    if (!SvOK(uri))
    {
      croak("uri_encode() requires a scalar argument to encode!");
    }
    src = SvPV_nomg_const(uri, len);
    if (SvUTF8(uri))
    {
      uri = sv_2mortal(newSVpvn(src, len));
      SvUTF8_on(uri);
      if (!sv_utf8_downgrade(uri, TRUE))
          croak("Wide character in octet string");
      src = SvPV_const(uri, len);
    }
    uri_encode_dsv(src, len, TARG);
    PUSHTARG;

void
uri_decode(SV *uri)
  PREINIT:
    dXSTARG;
    const char *src;
    size_t len;
  PPCODE:
    SvGETMAGIC(uri);
    if (!SvOK(uri))
    {
      croak("uri_decode() requires a scalar argument to decode!");
    }
    src = SvPV_nomg_const(uri, len);
    if (SvUTF8(uri))
    {
      uri = sv_2mortal(newSVpvn(src, len));
      SvUTF8_on(uri);
      if (!sv_utf8_downgrade(uri, TRUE))
          croak("Wide character in octet string");
      src = SvPV_const(uri, len);
    }
    uri_decode_dsv(src, len, TARG);
    PUSHTARG;

