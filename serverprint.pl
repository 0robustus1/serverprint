#! /usr/bin/env perl

#use strict;
use warnings;
use Getopt::Std;
use File::Basename;

use constant SCP => "/usr/bin/scp";
use constant SSH => "/usr/bin/ssh";
use constant CORRECT_PDF_VERSION => 1.4;

my %opts = (
  'p' => "Stuga",
  's' => "stuga",
  'n' => 1
);
my $additional_opts = "";

sub help_text {
  print "Usage: \n",
  "serverprint -p Printer -s Server -f File -n NoOfCopies -c -o '-o sides=two-sided-long-edge'\n",
  "  -p is the name of the printer as identified by cups/lpq (default: 'Stuga')\n",
  "  -s should be a server-reference processable by ssh, preferably a config-host (default: 'stuga')\n",
  "  -c asks for automatic file conversions if the printing is likely to trigger problems\n",
  "  -o takes additional arguments, that should be passed to lpr, as a singular string argument\n";
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
  $debug = shift;
  print "trying to convert...";
  $filepath = "/tmp/".basename($opts{f});
  $to_ps_cmd = "pdftops -paper A4 ".quotemeta($opts{f})." ".quotemeta($filepath).".ps"."\n";
  $to_pdf_cmd = "pstopdf ".quotemeta($filepath).".ps -o ".quotemeta($filepath)."\n";
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
  $filepath = shift;
  # scp portion
  $command = SCP." ".quotemeta($filepath)." ".$opts{s}.": ";
  # second command
  $command .= "&& ";
  # ssh portion
  $command .= SSH." ".$opts{s}." ";
  # inner ssh command: lpr
  $command .= "lpr ".$additional_opts." -r -P ".$opts{p}." '".quotemeta(basename($filepath))."' -#".$opts{n};
  return $command;
}

# -o, -f, -p, -n, & -s take arguments. Values can be found in %opts
getopts('o:f:p:s:n:cd', \%opts);
die help_text unless $opts{f};
if ($opts{o}) {
  $additional_opts = " ".$opts{o};
}

my $filepath = $opts{f};
if ($opts{c}) {
  open(PDF,"pdfinfo ".quotemeta($filepath)." |") ||
    die "Failed: not able to complete dimensionscheck\n",
        "try again without the -c switch...";
  my $width;
  my $height;
  my $pdf_version;

  while ( <PDF> )
  {
    if ($_ =~ m/^Page size:\s*(\d+?\.?\d*?)\s*x\s*(\d+?\.?\d*?)\s*pts/){
      $width = sprintf("%.2f",$1/72);
      $height = sprintf("%.2f",$2/72);
    } elsif ($_ =~ m/^PDF version:\s*(\d+\.?\d*)\s*$/){
      $pdf_version = $1;
    }
  }

  my $portrait = (check_size($width,8.3) && check_size($height,11.7));
  my $landscape = (check_size($height,8.3) && check_size($width,11.7));
  my $perform_conversion = 0;

  if (!($portrait || $landscape)) {
    print "file dimensions are not matching Din A4\n";
    $perform_conversion = 1;
  } elsif ($pdf_version > CORRECT_PDF_VERSION) {
    print "pdf version does not match the correct version\n";
    $perform_conversion = 1;
  } else {
    print "file dimensions ok, printing...\n";
  }
  if ($perform_conversion) {
    $filepath = perform_conversion($opts{d});
  }
}

my $command = build_copy_print_command($filepath);

if ($opts{d}) {
  print $command, "\n";
} else {
  system($command);
}

die "unhappy result" if ($? >> 8) == -1;
__END__
