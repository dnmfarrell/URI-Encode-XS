use strict;
use warnings;
package URI::Encode::XS;

use XSLoader;
use Exporter 5.57 'import';

our $VERSION     = '0.001';
our %EXPORT_TAGS = ( 'all' => [] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );

XSLoader::load('URI::Encode::XS', $VERSION);

1;
