use strict;
use warnings;
use Test::More;
#use Config;
use Test::Alien;
use Alien::gdal;

alien_ok 'Alien::gdal';

diag (Alien::gdal->libs);
diag (Alien::gdal->cflags);
diag ('Dynamic libs: ' . join ':', Alien::gdal->dynamic_libs);

TODO: {
    local $TODO = 'known to fail under macos'
      if $^O =~ /darwin/i;
    my $xs = do { local $/; <DATA> };
    xs_ok {xs => $xs, verbose => 0}, with_subtest {
      my($module) = @_;
      ok $module->version;
    };
}

#  check we can run one of the utilities
run_ok([ 'gdalwarp', '--version' ])
  ->success
  ->out_like(qr{GDAL \d+\.\d+\.\d+, released \d{4}/\d{2}/\d{2}}); 


done_testing();

 
__DATA__

//  A very simple test.  It really only tests that we can load gdal.h.

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "stdio.h"
#include "gdal.h"

int main()
{
   printf("Hello, World!");
   return 0;
}

const char *
version(const char *class)
{
  return "v1";
}

MODULE = TA_MODULE PACKAGE = TA_MODULE
 
const char *version(class);
    const char *class;

