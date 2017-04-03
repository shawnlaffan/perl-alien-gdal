use 5.010;
use strict;
use warnings;

use Install::Software;

my $gdal = Install::Software->new(
    name    => 'gdal',
    probe   => 'gdal-config',
    url     => 'http://download.osgeo.org/gdal/CURRENT',
    prefix  => '/usr/local',
    stage   => '/tmp',
);

$gdal->install;

