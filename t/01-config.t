use strict;
use warnings;
use Test::More;
use Alien::gdal;

diag( 'NAME=' . Alien::gdal->config('name') );
diag( 'VERSION=' . Alien::gdal->config('version') );

my $alien = Alien::gdal->new;

SKIP: {
    skip "system libs may not need -I or -L", 2
        if $alien->install_type('system');
    like( $alien->cflags, qr/-I/ );
    like( $alien->libs,   qr/-L/ );
}

my $data_dir = eval {$alien->data_dir};
ok ($data_dir && -d $data_dir, 'data dir exists');

done_testing();

