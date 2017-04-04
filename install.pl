
use strict;
use warnings;
use 5.010;
use Alien::Build;
use alienfile;

##########################################################
# Constants
##########################################################
use constant STAGE        => '/tmp';
use constant PREFIX        => '/usr/local';

# Get the alienfiles from the recept directory
my $dir = "receipts";
#my $dh;

opendir(my $dh, $dir) || die "Can't open $dir: $!";
while (readdir $dh) {
    next if ($_ eq "." || $_ eq "..");
    my $receipt_path =  "$dir/$_";
    install($receipt_path);
#    my $cmd = "rm -fR " . STAGE . "/_alien";
#    my $result = `$cmd`;
}
closedir $dh;

# build the software
sub install {
    my $alienfile = shift;
    print "processing: $alienfile\n";

    my $builder = Alien::Build->load($alienfile);
    $builder->load_requires('configure');
    $builder->set_prefix(PREFIX);
    $builder->set_stage(STAGE);  # needs to be absolute
    $builder->load_requires($builder->install_type);
    $builder->download;
    $builder->build;
    # files are now in /Users/admin/stage, it is your job (or
    # ExtUtils::MakeMaker, Module::Build, etc) to copy
    # those files into /usr/local

    return;
}
