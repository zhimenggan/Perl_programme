#!/usr/bin/perl -w
# Author: Thomas Thiel
# Program name: prim_output.pl
# Description: converts the Primer3 output into an table

open (SRC,"<$ARGV[0]") || die ("\nError: Couldn't open Primer3 results file (*.p3out) !\n\n");
my $filename = $ARGV[0];
$filename =~ s/\.p3out//;
#open (IN,"<$ARGV[1]") || die ("\nError: Couldn't open source file containing MISA (*.misa) results !\n\n");
open (OUT,">$filename.results") || die ("nError: Couldn't create file !\n\n");

my ($seq_names_failed,$count,$countfailed);

print OUT "ID\t";
print OUT "FORWARD PRIMER1 (5'-3')\tTm(��)\tsize\tREVERSE PRIMER1 (5'-3')\tTm(��)\tsize\tPRODUCT1 size (bp)\tstart (bp)\tend (bp)\t";
print OUT "FORWARD PRIMER2 (5'-3')\tTm(��)\tsize\tREVERSE PRIMER2 (5'-3')\tTm(��)\tsize\tPRODUCT2 size (bp)\tstart (bp)\tend (bp)\t";
print OUT "FORWARD PRIMER3 (5'-3')\tTm(��)\tsize\tREVERSE PRIMER3 (5'-3')\tTm(��)\tsize\tPRODUCT3 size (bp)\tstart (bp)\tend (bp)\n";

#undef $/;
#my $in = <IN>;
#study $in;

$/ = "=\n";
$count_failed=0;
$count=0;
while (<SRC>)
  {
  my ($id) = (/PRIMER_SEQUENCE_ID=(\S+)/);
  
#$in =~ /($id\t$ssr_nr\t.*)\n/;
#my $misa = $1;
  
  /PRIMER_LEFT_SEQUENCE=(.*)/ || do {$count_failed++;print OUT "$id\n"; next};
  my $info = "$1\t";
  
  /PRIMER_LEFT_TM=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT=\d+,(\d+)/; $info .= "$1\t";
  
  /PRIMER_RIGHT_SEQUENCE=(.*)/;  $info .= "$1\t";
  /PRIMER_RIGHT_TM=(.*)/; $info .= "$1\t";
  /PRIMER_RIGHT=\d+,(\d+)/; $info .= "$1\t";
  
  /PRIMER_PRODUCT_SIZE=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT=(\d+),\d+/; $info .= "$1\t";
  /PRIMER_RIGHT=(\d+),\d+/; $info .= "$1\t";
  
  
  /PRIMER_LEFT_1_SEQUENCE=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_1_TM=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_1=\d+,(\d+)/; $info .= "$1\t";
    
  /PRIMER_RIGHT_1_SEQUENCE=(.*)/;  $info .= "$1\t";
  /PRIMER_RIGHT_1_TM=(.*)/; $info .= "$1\t";
  /PRIMER_RIGHT_1=\d+,(\d+)/; $info .= "$1\t";
  
  /PRIMER_PRODUCT_SIZE_1=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_1=(\d+),\d+/; $info .= "$1\t";
  /PRIMER_RIGHT_1=(\d+),\d+/; $info .= "$1\t";
  
  
  /PRIMER_LEFT_2_SEQUENCE=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_2_TM=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_2=\d+,(\d+)/; $info .= "$1\t";
    
  /PRIMER_RIGHT_2_SEQUENCE=(.*)/;  $info .= "$1\t";
  /PRIMER_RIGHT_2_TM=(.*)/; $info .= "$1\t";
  /PRIMER_RIGHT_2=\d+,(\d+)/; $info .= "$1\t";
  
  /PRIMER_PRODUCT_SIZE_2=(.*)/; $info .= "$1\t";
  /PRIMER_LEFT_2=(\d+),\d+/; $info .= "$1\t";
  /PRIMER_RIGHT_2=(\d+),\d+/; $info .= "$1";
  
  $count++;
  print OUT "$id\t$info\n"
  };

print "\nPrimer modelling was successful for $count sequences.\n";
print "Primer modelling failed for $count_failed sequences.\n";
