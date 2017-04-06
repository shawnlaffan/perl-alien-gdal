use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok('Alien::libpng') or BAIL_OUT('Failed to load Alien::libpng');
}

diag(
    sprintf(
        'Testing Alien::libpng %f, Perl %f, %s',
        $Alien::libpng::VERSION, $], $^X
    )
);

done_testing();

