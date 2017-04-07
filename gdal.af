use alienfile;

plugin 'PkgConfig' => 'gdal';

plugin 'Probe::CommandLine' => (
  command   => 'gdal-config',
  secondary => 1,
);

share {

  plugin Download => (
    url     => 'http://download.osgeo.org/gdal/CURRENT',
    version => qr/^gdal-([0-9\.]+)\.tar\.gz$/,
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
