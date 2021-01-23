package Alien::gdal;

use 5.010;
use strict;
use warnings;
use parent qw( Alien::Base );
use FFI::CheckLib;
use Env qw ( @PATH @LD_LIBRARY_PATH @DYLD_LIBRARY_PATH );
use Capture::Tiny qw /:all/;
use Path::Tiny qw /path/;
use Alien::proj;

our $VERSION = '1.23';

my ($have_geos, $have_proj, $have_spatialite);
my @have_aliens;
BEGIN {
    $have_geos = eval 'require Alien::geos::af';
    $have_spatialite = eval 'require Alien::spatialite';
    foreach my $alien_lib (qw /Alien::geos::af Alien::sqlite Alien::proj Alien::freexl Alien::libtiff/) {
        my $have_lib = eval "require $alien_lib";
        my $pushed_to_env = 0;
        if ($have_lib && $alien_lib->install_type eq 'share') {
            push @have_aliens, $alien_lib;
            #  crude, but otherwise Geo::GDAL::FFI does not
            #  get fed all the needed info
            #warn "Adding Alien::geos bin to path: " . Alien::geos::af->bin_dir;
            push @PATH, $alien_lib->bin_dir;
            #warn $ENV{PATH};
        }
    }
    # 
    if ($^O =~ /mswin/i and !$ENV{PROJSO} and Alien::gdal->version lt 3) {
        my $libpath;
        $have_proj = eval 'require Alien::proj';
        if ($have_proj) {
            #  make sure we get the proj lib early in the search
            ($libpath) = Alien::proj->bin_dir;
        }
        my $proj_lib = FFI::CheckLib::find_lib (
            libpath => $libpath,
            lib     => 'proj',
        );
        #warn "PROJ_LIB FILE IS $proj_lib";
        $ENV{PROJSO} //= $proj_lib;
    }
    if (Alien::gdal->version ge '3') {
        push @PATH, 'Alien::proj'->bin_dirs
          if 'Alien::proj'->can('bin_dirs');
        if ($have_spatialite && Alien::spatialite->version ge 5) {
          push @PATH, 'Alien::spatialite'->bin_dirs
            if 'Alien::spatialite'->can('bin_dirs');
          push @have_aliens, 'Alien::spatialite';
        }
    }
}

sub dynamic_libs {
    my $self = shift;
    
    my (@libs) = $self->SUPER::dynamic_libs;

    foreach my $alien (@have_aliens) {
        push @libs, $alien->dynamic_libs;
    }
    my (%seen, @libs2);
    foreach my $lib (@libs) {
        next if $seen{$lib};
        push @libs2, $lib;
        $seen{$lib}++;
    }
    if ($have_geos
        && $^O =~ /bsd/
        && Alien::geos::af->install_type eq 'share'
        ) {
        #  underhanded, but we are getting failures if this is not set
        #  maybe should be done in A::g::af
        my $libdir = Alien::geos::af->dist_dir . q{/lib};
        push @LD_LIBRARY_PATH, $libdir
          if !grep {/$libdir/} @LD_LIBRARY_PATH;
        warn "Adding $libdir to LD_LIBRARY_PATH";
    }
    
    return @libs2;
}

sub cflags {
    my $self = shift;
    
    my $cflags = $self->SUPER::cflags;
    
    if ($have_geos) {
        $cflags .= ' ' . Alien::geos::af->cflags;
    }
    
    return $cflags;
}

sub libs {
    my $self = shift;
    
    my $cflags = $self->SUPER::libs;
    
    if ($have_geos) {
        $cflags .= ' ' . Alien::geos::af->libs;
    }
    
    return $cflags;
}

#sub cflags_static {
#    my $self = shift;
#    
#    my $cflags = $self->SUPER::cflags_static;
#    
#    if ($have_geos) {
#        $cflags .= ' ' . Alien::geos::af->cflags_static;
#    }
#    
#    return $cflags;
#}
#
#sub libs_static {
#    my $self = shift;
#    
#    my $cflags = $self->SUPER::libs_static;
#    
#    if ($have_geos) {
#        $cflags .= ' ' . Alien::geos::af->libs_static;
#    }
#    
#    return $cflags;
#}

sub run_utility {
    my ($self, $utility, @args) = @_;

    my @alien_bins
      = grep {defined}
        map {$_->bin_dir}
        ($self, @have_aliens);
    push @alien_bins, Alien::proj->bin_dirs
      if Alien::proj->can ('bin_dirs');
    
    local $ENV{PATH} = $ENV{PATH};
    unshift @PATH, @alien_bins
      if @alien_bins;

    #  something of a hack
    local $ENV{LD_LIBRARY_PATH} = $ENV{LD_LIBRARY_PATH};
    push @LD_LIBRARY_PATH, Alien::gdal->dist_dir . '/lib';

    local $ENV{DYLD_LIBRARY_PATH} = $ENV{DYLD_LIBRARY_PATH};
    push @DYLD_LIBRARY_PATH, Alien::gdal->dist_dir . '/lib';

    if ($self->install_type eq 'share') {
        my @bin_dirs = $self->bin_dir;
        my $bin = $bin_dirs[0] // '';
        $utility = "$bin/$utility";  #  should strip path from $utility first?
    }
    #  handle spaces in path
    if ($^O =~ /mswin/i) {
        if ($utility =~ /\s/) {
            $utility = qq{"$utility"};
        }
    }
    else {
        $utility =~ s|(\s)|\$1|g;
    }


    #  user gets the pieces if it breaks
    capture {system $utility, @args};
}

sub data_dir {
    my $self = shift;
 
    my $path = $self->dist_dir . '/share/gdal';
    
    if (!-d $path) {
        #  try PkgConfig
        use PkgConfig;
        my %options;
        if (-d $self->dist_dir . '/lib/pkgconfig') {
            $options{search_path_override} = [$self->dist_dir . '/lib/pkgconfig'];
        }
        my $o = PkgConfig->find('gdal', %options);
        if ($o->errmsg) {
            warn $o->errmsg;       
        }
        else {
            $path = $o->get_var('datadir');
            if ($path =~ m|/data$|) {
                my $alt_path = $path;
                $alt_path =~ s|/data$||;
                if (!-d $path && -d $alt_path) {
                    #  GDAL 2.3.x and earlier erroneously appended /data
                    $path = $alt_path;
                }
            }
        }
    }

    warn "Cannot find gdal data dir"
      if not (defined $path and -d $path);

    return $path;
}

1;

__END__

=head1 NAME

Alien::gdal - Compile GDAL, the Geographic Data Abstraction Library

=head1 BUILD STATUS
 
=begin HTML
 
<p>
    <img src="https://img.shields.io/badge/perl-5.10+-blue.svg" alt="Requires Perl 5.10+" />
    <a href="https://travis-ci.org/shawnlaffan/perl-alien-gdal"><img src="https://travis-ci.org/shawnlaffan/perl-alien-gdal.svg?branch=master" /></a>
    <a href="https://ci.appveyor.com/project/shawnlaffan/perl-alien-gdal"><img src="https://ci.appveyor.com/api/projects/status/1tqk5rd40cv2ve8q?svg=true" /></a>
</p>

=end HTML

=head1 SYNOPSIS

    use Alien::gdal;

    use Env qw(@PATH);
    unshift @PATH, Alien::gdal->bin_dir;

    print Alien::gdal->dist_dir;

    #  assuming you have populated @args already
    my ($stdout, $stderr, $exit_code)
      = Alien::gdal->run_utility ('gdalwarp', @args);
    #  Note that this is currently experimental.
    #  Please report issues and solutions.  
    
    #  Access the GDAL data directory
    #  (note that not all system installs include it)
    my $path = Alien::gdal->data_dir;
    
=head1 DESCRIPTION

GDAL is the Geographic Data Abstraction Library.  See L<http://www.gdal.org>.


=head1 REPORTING BUGS

Please send any bugs, suggestions, or feature requests to 
L<https://github.com/shawnlaffan/perl-alien-gdal/issues>.

=head1 SEE ALSO

L<Geo::GDAL>

L<Geo::GDAL::FFI>

L<Alien::geos::af>

=head1 AUTHORS

Shawn Laffan, E<lt>shawnlaffan@gmail.comE<gt>

Jason Mumbulla (did all the initial work - see git log for details)

Ari Jolma

=head1 COPYRIGHT AND LICENSE


Copyright 2017- by Shawn Laffan and Jason Mumbulla


This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
