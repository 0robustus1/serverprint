#! /usr/bin/env perl

#use strict;
use warnings;
use Getopt::Std;
use File::Basename;

use constant SCP => "/usr/bin/scp";
use constant SSH => "/usr/bin/ssh";

my %opts = (
  'p' => "Stuga",
  's' => "stuga",
  'n' => 1
);

sub help_text {
  print "Usage: \n",
  "serverprint -p Printer -s Server -f File -n NoOfCopies -c -o '-o sides=two-sided-long-edge'\n";
  exit 0;
}

sub try_load {
  my $mod = shift;

  eval("use $mod");

  if ($@) {
    return(0);
  } else {
    return(1);
  }
}

sub check_size {
  $actual_size = shift;
  $wanted_size = shift;
  if (($actual_size-0.5)<=$wanted_size && ($actual_size+0.5)>=$wanted_size){
    return 1;
  } else {
    return 0;
  }
}

# -o, -f, -p, -n, & -s take arguments. Values can be found in %opts
getopts('o:f:p:s:n:c', \%opts);
die help_text unless $opts{f};
my $additional_opts = $opts{o} ? $opts{o} : "";
my $command = SCP." ".$opts{f}." ".$opts{s}.": && ".SSH." ".$opts{s}." lpr ". $additional_opts ." -r -P ".$opts{p}." ".basename($opts{f})." -#".$opts{n};
if ($opts{c}) {
  open(PDF,"pdfinfo ".$opts{f}." |") || die "Failed: not able to complete dimensionscheck\n","try again without the -c switch...";
  my $width;
  my $height;
  while ( <PDF> )
  {
    if ($_ =~ m/^Page size:\s*(\d+?\.?\d*?)\s*x\s*(\d+?\.?\d*?)\s*pts/){
      $width = sprintf("%.2f",$1/72);
      $height = sprintf("%.2f",$2/72);
    }
  }
  my $portrait = (check_size($width,8.3) && check_size($height,11.7));
  my $landscape = (check_size($height,8.3) && check_size($width,11.7));
  if ($portrait || $landscape) {
    print "file dimensions ok, printing...\n";
  } else {
    print "file dimension are not matching Din A4\n";
    print "trying to convert...";
    system("pdftops -paper A4 ".$opts{f}." /tmp/".basename($opts{f}).".ps"."\n");
    system("pstopdf /tmp/".basename($opts{f}).".ps -o /tmp/".basename($opts{f})."\n");
    print "ok\n";
    $command = SCP." /tmp/".basename($opts{f})." ".$opts{s}.": && ".SSH." ".$opts{s}." lpr ".$additional_opts." -r -P ".$opts{p}." ".basename($opts{f})." -#".$opts{n};
  }
}

system($command);
die "unhappy result" if ($? >> 8) == -1;
__END__
