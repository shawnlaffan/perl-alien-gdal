use strict;
use warnings;
use Test::More;
use Alien::libpng;

diag( 'NAME=' . Alien::libpng->config('name') );
diag( 'VERSION=' . Alien::libpng->config('version') );

my $alien = Alien::libpng->new;

diag( 'CFLAGS=' . $alien->cflags );
diag( 'LIBS=' . $alien->libs );

SKIP: {
    skip "system libs may not need -I or -L", 2
        if $alien->install_type('system');
    like( $alien->cflags, qr/-I/ );
    like( $alien->libs,   qr/-L/ );
}

done_testing();

