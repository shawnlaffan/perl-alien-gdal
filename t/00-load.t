use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok('Alien::gdal') or BAIL_OUT('Failed to load Alien::gdal');
}

diag(
    sprintf(
        'Testing Alien::gdal %s, Perl %s, %s',
        $Alien::gdal::VERSION, $], $^X
    )
);

done_testing();

