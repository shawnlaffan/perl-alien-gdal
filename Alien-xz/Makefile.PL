use strict;
use warnings;
use ExtUtils::MakeMaker;
use Alien::Build::MM;

my %WriteMakefileArgs = (
  "ABSTRACT" => "Find or build xz",
  "AUTHOR" => "Jason Mumbulla <jasonmumbulla\@gmail.com>",
  "VERSION_FROM" => "lib/Alien/xz.pm",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.52",
  },
  "PREREQ_PM" => {
    "Alien::Base" => "0.038",
  },
  "DISTNAME" => "Alien-xz",
  "LICENSE" => "perl",
  "NAME" => "Alien::xz",
  "PREREQ_PM" => {
    "Alien::Base" => "0.038"
  },
);

my $abmm = Alien::Build::MM->new;
%WriteMakefileArgs = $abmm->mm_args(%WriteMakefileArgs);

WriteMakefile(%WriteMakefileArgs);

sub MY::postamble {
  $abmm->mm_postamble;
}
