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

sub perform_conversion {
  $opts = shift;
  $additional_opts = shift;
  $debug = shift;
  print "trying to convert...";
  $filepath = "/tmp/".basename($opts{f});
  $to_ps_cmd = "pdftops -paper A4 ".$opts{f}." ".$filepath.".ps"."\n";
  $to_pdf_cmd = "pstopdf ".$filepath.".ps -o ".$filepath."\n";
  if ($debug) {
    print "\n";
    print $to_ps_cmd;
    print $to_pdf_cmd;
  } else {
    system($to_ps_cmd);
    system($to_pdf_cmd);
  }
  print "ok\n";
  return $filepath;
}

sub build_copy_print_command {
  $opts = shift;
  $additional_opts = shift;
  $filepath = shift;
  $command = SCP." ".$filepath." ".$opts{s}.": && ".SSH." ".$opts{s}." lpr ".$additional_opts." -r -P ".$opts{p}." ".basename($filepath)." -#".$opts{n};
  return $command;
}

# -o, -f, -p, -n, & -s take arguments. Values can be found in %opts
getopts('o:f:p:s:n:cd', \%opts);
die help_text unless $opts{f};
my $additional_opts = $opts{o} ? $opts{o} : "";
my $command = build_copy_print_command($opts, $additional_opts, $opts{f});
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
    my $filepath = perform_conversion($opts, $additional_opts, $opts{d});
    $command = build_copy_print_command($opts, $additional_opts, $filepath);
  }
}

if ($opts{d}) {
  print $command, "\n";
} else {
  system($command);
}

die "unhappy result" if ($? >> 8) == -1;
__END__
