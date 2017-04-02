use Alien::Build;

my $build = Alien::Build->load('./alienfile');
$build->load_requires('configure');
$build->set_prefix('/usr/local');
$build->set_stage('/Users/admin/stage');  # needs to be absolute
$build->load_requires($build->install_type);
$build->download;
$build->build;
# files are now in /Users/admin/stage, it is your job (or
# ExtUtils::MakeMaker, Module::Build, etc) to copy
# those files into /usr/local
