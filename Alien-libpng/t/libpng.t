#line 2 "Libpng.t.tmpl"
use warnings;
use strict;
use Test::More tests => 20;
use FindBin;
use File::Compare;
use Test2::Bundle::Extended;
use Test::Alien;
use Alien::libpng;
use utf8;
use Alien::libpng::Const ':all';

my $builder = Test::More->builder;

binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
binmode STDOUT, ":utf8";

my $png = Alien::libpng::create_read_struct ();
ok ($png, 'call "create_read_struct" and get something');
$png->set_verbosity (1);
my $file_name = "$FindBin::Bin/test.png";

open my $file, "<", $file_name or die "Can't open '$file_name': $!";

$png->init_io ($file);
$png->read_info ();

my $IHDR = $png->get_IHDR ();
ok ($IHDR->{width} == 100, "width");
ok ($IHDR->{height} == 100, "height");
$png->destroy_read_struct ();
close $file or die $!;

my $file_in_name = "$FindBin::Bin/test.png";
open my $file_in, "<", $file_in_name or die "Can't open '$file_in_name': $!";

my $png_in = Alien::libpng::create_read_struct ();
$png_in->init_io ($file_in);
$png_in->read_png (0);
close $file_in or die $!;
my $file_out_name = "$FindBin::Bin/test-write.png";
my $png_out = Alien::libpng::create_write_struct ();
my $time_file_name = "$FindBin::Bin/with-time.png";
open my $file2, "<", $time_file_name or die "Can't open '$time_file_name': $!";
my $png2 = Alien::libpng::create_read_struct ();
$png2->init_io ($file2);
$png2->read_info ();
my %times;
%times = %{$png2->get_tIME ()};
ok ($times{year} == 2010, "year");
ok ($times{month} == 12, "month");
ok ($times{day} == 29, "day");
ok ($times{hour} == 16, "hour");
ok ($times{minute} == 20, "minute");
ok ($times{second} == 20, "second");
close $file2 or die $!;

my $text_file_name = "$FindBin::Bin/with-text.png";
open my $file3, "<", $text_file_name or die "Can't open '$text_file_name': $!";
my $png3 = Alien::libpng::create_read_struct ();
$png3->init_io ($file3);
$png3->read_info ();
my @text_chunks = @{$png3->get_text ()};

my $chunk1 = $text_chunks[0];
ok ($chunk1->{compression} == 0, "text compression");
ok ($chunk1->{key} eq 'Title', "text key");
ok ($chunk1->{text} eq 'Mona Lisa', "text text");

SKIP: {
    skip "Your libpng does not support iTXt", 3
        unless (Alien::libpng::supports ('iTXt'));
    my $chunk3 = $text_chunks[2];
    ok ($chunk3->{compression} == 1, "text compression for iTXT");
    ok ($chunk3->{key} eq 'Detective', "text key");
    ok ($chunk3->{text} eq '工藤俊作', "text text in UTF-8");
};

#Alien::libpng::destroy_read_struct ($png3);
close $file3 or die $!;

my $number_version = Alien::libpng::access_version_number ();
ok ($number_version =~ /^\d+$/, "Numerical version number OK");
my $version = Alien::libpng::get_libpng_ver ();
$version =~ s/\./0/g;

# The following fails for older versions of libpng which seem to have
# a different numbering system.

if ($number_version > 100000) {
    ok ($number_version == $version,
        "Library version $number_version == $version OK");
}

# Read a file which is not correct. On version 0.02 this caused a core
# dump of Perl because of a mistake in the error handler in
# perl-libpng.c.tmpl. The error was fixed in 0.03 but this test is new
# in 0.04.

my $badpngfile = "$FindBin::Bin/xlfn0g04.png";
if (! -f $badpngfile) {
    die "You are missing a test file";
}
eval {
    open my $badfh, "<:raw", $badpngfile or die $!;
    my $badpng = Alien::libpng::create_read_struct ();
    $badpng->init_io ($badfh);
    $badpng->read_png ();
};
ok ($@, "Error reading bad PNG causes croak (not core dump)");
ok ($@ =~ /libpng error/, "Found string 'libpng error' in error message.");

eval {
    my $png_no_rows = Alien::libpng::create_write_struct ();
    $png_no_rows->set_IHDR ({
        width => 200,
        height => 200,
        bit_depth => 1,
        color_type => PNG_COLOR_TYPE_GRAY,
    });
    my @rows;
    $png_no_rows->set_rows (\@rows);
};
like ($@, qr/requires 200 rows/, "Produces error for empty \@rows");

eval {
    my $png_no_io_init = Alien::libpng::create_write_struct ();
    $png_no_io_init->set_IHDR ({
        width => 1,
        height => 1,
        bit_depth => 1,
        color_type => PNG_COLOR_TYPE_GRAY,
    });
    $png_no_io_init->set_rows ([0]);
    $png_no_io_init->write_png ($png_no_io_init);
};
like ($@, qr/Attempt to write PNG without calling init_io/,
      "Produces error on write if no output file has been set");

# Local variables:
# mode: perl
# End:
