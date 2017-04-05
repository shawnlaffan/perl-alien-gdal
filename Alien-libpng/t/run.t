use Test2::Bundle::Extended;
use Test::Alien;
use Alien::libpng;

alien_ok 'Alien::libpng';

xs_ok do { local $/; <DATA> }, with_subtest {
  my $version = libpng::lzma_version_string();
  ok $version;
  note "version = $version";
};

done_testing;

__DATA__

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <png.h>

MODULE = libpng PACKAGE = libpng

const char *
libpng_version_string()
