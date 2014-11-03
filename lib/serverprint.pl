#! /usr/bin/env perl

#use strict;
use warnings;
use Getopt::Long qw(:config pass_through);
use File::Basename;

use constant SCP => "/usr/bin/scp";
use constant SSH => "/usr/bin/ssh";
use constant CORRECT_PDF_VERSION => 1.4;

my %opts = (
  'p' => "Stuga",
  's' => "stuga",
  'n' => 1,
  'c' => 1,
  'two_sided' => 1,
  'no_side' => 0,
  'pages_per_print_page' => 1,
);
my $additional_opts = "";

sub help_text {
  print "Usage: \n",
  "serverprint -o '-o sides=two-sided-short-edge' path/to/printeable-file.pdf another-file.pdf\n",
  "  -p is the name of the printer as identified by cups/lpq (default: 'Stuga')\n",
  "  -s should be a server-reference processable by ssh, preferably a config-host (default: 'stuga')\n",
  "  -c asks for automatic file conversions if the printing is likely to trigger problems(default: on)\n",
  "    --convert equivalent to -c\n",
  "    --no-convert disables convert-mode\n",
  "  --two-sided prints page in --two-sided-long-edge mode (default)\n",
  "  --one-sided prints page in --one-sided (does not print on the back)\n",
  "  --no-side do not pass side-information to lpr (use server-default)\n",
  "  --pages-per-print-page is the count of file pages per print page (default: 1)\n",
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
  $original_filepath = shift;
  print "trying to convert...";
  $filepath = "/tmp/".basename($original_filepath);
  $to_ps_cmd = "pdftops -paper A4 ".quotemeta($original_filepath)." ".quotemeta($filepath).".ps"."\n";
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

sub is_pdf {
  $filename = shift;
  return $filename =~ m/\.pdf$/;
}

sub build_pages_per_print_page_option {
  $pages_value = shift;
  $option = "";
  if ($pages_value != 1) {
    if ($pages_value != 0 && ($pages_value % 2) == 0) {
      $option = " -o number-up=".$pages_value;
    } else {
      die("invalid value '".$pages_value."' for --pages-per-print-page.".
        " See manpage for details.\n");
    }
  }
  return $option;
}

sub build_page_sides_option {
  $no_side = shift;
  $two_sided = shift;
  $option = "";
  if (!$no_side) {
    if ($two_sided) {
      $option = " -o sides=two-sided-long-edge";
    } else {
      $option = " -o sides=one-sided"
    }
  }
  return $option;
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
  # lpr-options: print back/front of pages
  $command .= build_page_sides_option($opts{no_side}, $opts{two_sided});
  # lpr-options: print multiple file-pages per page
  $command .= build_pages_per_print_page_option($opts{pages_per_print_page});
  return $command;
}

sub print_pages_handler {
  my ($opt_name, $count) = @_;
  $opts{pages_per_print_page} = $count;
}

sub try_conversion {
  $filepath = shift;
  if (is_pdf($filepath)) {
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

    print $filepath.": ";
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
      $filepath = perform_conversion($opts{d}, $filepath);
    }
  } else {
    print "file is not a pdf, won't convert.\n";
  }
  return $filepath;
}

sub die_hard {
  $message = shift;
  $exit_state = shift || 1;
  print $message."\n";
  exit $exit_state;
}

# -o, -p, -n, & -s take arguments. Values can be found in %opts
GetOptions(\%opts, 'o=s', 'p=s', 's=s', 'n=i', 'c|convert!',
  'd', 'h|help',
  'two-sided' => \$opts{two_sided},
  'one-sided' => sub { $opts{two_sided} = 0 },
  'no-side' => sub { $opts{no_side} = 1 },
  'pages-per-print-page=i' => \&print_pages_handler);

die help_text if $opts{h} || @ARGV == 0;

foreach(@ARGV) {
  my $filepath = $_;
  if ($opts{o}) {
    $additional_opts = " ".$opts{o};
  }

  if (-e $filepath) {
    $filepath = try_conversion($filepath) if $opts{c};
  } else {
    die_hard "The file '".$filepath."' does not exist, aborting!";
  }

  my $command = build_copy_print_command($filepath);

  if ($opts{d}) {
    print $command, "\n";
  } else {
    system($command);
  }
}

die "unhappy result" if ($? >> 8) == -1;
__END__
