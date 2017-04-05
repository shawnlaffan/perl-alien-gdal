use Test2::Bundle::Extended;
use Test::Alien;
use Alien::libpng;

alien_ok 'Alien::libpng';

run_ok(['xz', '--version'])
  ->success
  ->out_like(qr{XZ Utils})
  ->note;

done_testing;
