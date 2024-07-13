#!/usr/bin/perl
use strict;

my $infile = shift @ARGV;
my $outfile = $infile.".stats";

system("grep 'DNA' $infile | wc -l >> $outfile");
system("grep 'SINE' $infile | wc -l >> $outfile");
system("grep 'LINE' $infile | wc -l >> $outfile");
system("grep 'LTR' $infile | wc -l >> $outfile");
system("grep 'RC' $infile | wc -l >> $outfile");
system("grep 'Retro' $infile | wc -l >> $outfile");
system("grep 'Unknown' $infile | wc -l >> $outfile");
system("grep 'Simple' $infile | wc -l >> $outfile");
system("grep 'Low_complexity' $infile | wc -l >> $outfile");