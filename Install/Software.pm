=head1 SOFTWARE

Dowloads, builds and installs software.

=cut

package Install::Software; 

use strict;
use warnings;
use 5.010;
use Alien::Build;
use alienfile;

##########################################################
# Constants
##########################################################

##########################################################
# Construction
##########################################################

=head Constructor

=cut

sub new {
    my $class     = shift;
    my %args      = @_;

    my $name       = $args{name};
    my $probe      = $args{probe};
    my $url        = $args{url};
    my $prefix     = $args{prefix} // '/usr/local';
    my $stage      = $args{stage} // '/tmp';

    my $self = {
        name   => $name,
        probe  => $probe,
        url    => $url,
        prefix => $prefix,
        stage  => $stage,
    };
    bless $self, $class;

    return $self;
};

=head2 Build

Builds the required software.

=cut

# build the software
sub install {
    my $self = shift;

    #my $builder = Alien::Build->load('./gdal.af');
    my $builder = Alien::Build->load($self->buildfile());
    #my $builder = Alien::Build->load($self->buildfile($self->{name},$self->{probe},$self->{url}));
    $builder->load_requires('configure');
    $builder->set_prefix($self->{prefix});
    $builder->set_stage($self->{stage});  # needs to be absolute
    $builder->load_requires($builder->install_type);
    $builder->download;
    $builder->build;
    # files are now in /Users/admin/stage, it is your job (or
    # ExtUtils::MakeMaker, Module::Build, etc) to copy
    # those files into /usr/local

    return;
}

=head2 Alienfile

Builds an alienfile.

=cut

# Builds an alienfile from the supplied
# name, url and command to probe.
sub buildfile {
    my $self   = shift;
#    my $name   = shift;
#    my $probe  = shift;
#    my $url    = shift;

    plugin 'PkgConfig' => $self->{name};
    
    plugin 'Probe::CommandLine' => (
      command   => $self->{probe},
      secondary => 1,
    );
    
    share {
    
      plugin Download => (
        url     => $self->{url},
        version => qr/^$self->{name}-([0-9\.]+)\.tar\.gz$/,
      );
    
      plugin Extract => 'tar.gz';
    
      plugin 'Build::Autoconf' => ();
    
      # the build step is only necessary if you need to customize the
      # options passed to ./configure.  The default set by the
      # Build::Autoconf plugin is frequently sufficient.
      build [
        '%{configure} --disable-shared',
        '%{make}',
        '%{make} install',
      ];
    };
    return;
}

1;
