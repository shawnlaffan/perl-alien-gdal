use strict;
use warnings;
use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
  "ABSTRACT" => "Find or build gdal",
  "AUTHOR" => "Jason Mumbulla <jasonmumbulla\@gmail.com>",
  "NAME" => "Alien::gdal",
  "VERSION_FROM" => "lib/Alien/gdal.pm",
  "CONFIGURE_REQUIRES" => {
    "Alien::Build" => 0,
    "ExtUtils::MakeMaker" => "6.52",
    "Alien::Build::MM" => 0,
    "PkgConfig" => 0,
    ($^O =~ /mswin/i) ? ("Alien::MSYS" => 0) : (),
    "HTTP::Tiny" => 0.044,  #  something, somewhere needs this version, need to track it down
  },
  "PREREQ_PM" => {
    "Alien::Base" => "0.038",
  },
  "DISTNAME" => "Alien-gdal",
  "LICENSE" => "perl",
);

use Alien::Build::MM;
my $abmm = Alien::Build::MM->new;
%WriteMakefileArgs = $abmm->mm_args(%WriteMakefileArgs);

WriteMakefile(%WriteMakefileArgs);

sub MY::postamble {
  $abmm->mm_postamble;
}
