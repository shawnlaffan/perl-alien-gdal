use strict;
use warnings;
use Test::More;
#use Config;
use Test::Alien;
use Alien::gdal;

alien_ok 'Alien::gdal';

diag (Alien::gdal->libs);
diag (Alien::gdal->cflags);

my $xs = do { local $/; <DATA> };
xs_ok {xs => $xs, verbose => 0}, with_subtest {
  my($module) = @_;
  ok $module->version;
};

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

