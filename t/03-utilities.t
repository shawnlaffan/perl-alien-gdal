use strict;
use warnings;
use Test::More;
#use Config;
use Test::Alien;
use Alien::gdal;


#  nasty hack
#$ENV{LD_LIBRARY_PATH}   = Alien::gdal->dist_dir . '/lib';
#$ENV{DYLD_LIBRARY_PATH} = Alien::gdal->dist_dir . '/lib';


#  check we can run one of the utilities
#TODO: {
#    local $TODO = 'There are known issues running utilities';

    my ($result, $stderr, $exit) = Alien::gdal->run_utility ("gdalwarp", '--version');
    like ($result, qr{GDAL \d+\.\d+\.\d+, released \d{4}/\d{2}/\d{2}},
        'Got expected result from utility');
    diag ("\nUtility results:\n" . $result);
    diag $stderr if $stderr;
    diag "Exit code is $exit";
    diag '';
#}

done_testing();

