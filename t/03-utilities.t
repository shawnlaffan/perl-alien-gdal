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

    my $results = Alien::gdal->run_utility ("gdalwarp", '--version');
    like ($results, qr{GDAL \d+\.\d+\.\d+, released \d{4}/\d{2}/\d{2}},
        'Got expected result from utility');
    diag ("\nUtility results:\n" . $results);
    diag '';
#}

done_testing();

