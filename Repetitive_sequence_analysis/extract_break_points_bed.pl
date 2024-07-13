#!/usr/bin/perl
use strict;

my $inputfile = $ARGV[0];
my $outputfile = $inputfile;
my $len = $ARGV[1];
$outputfile =~ s/bed/$len.bed/;

open(IN,"$inputfile") or die $!;
open(OUT,">$outputfile") or die $!;
while(my $line = <IN>){
	chomp $line;
	my @arr = split(/\t/,$line);
	my $start1 = $arr[1] - $len;
	my $end1 = $arr[1];
	my $start2 = $arr[2];
	my $end2 = $arr[2] + $len;
	if($arr[0] eq 'MP1' and ($end2 > 104178091 or $start1 < 1000000)){next;}
	if($arr[0] eq 'MP2' and ($end2 > 85073209 or $start1 < 1000000)){next;}
	if($arr[0] eq 'MP3' and ($end2 > 68480500 or $start1 < 1000000)){next;}
	if($arr[0] eq 'MP4' and ($end2 > 62328371 or $start1 < 1000000)){next;}
	if($arr[0] eq 'MP5' and ($end2 > 29612500 or $start1 < 1000000)){next;}
	if($arr[0] eq 'MP6' and ($end2 > 29865500 or $start1 < 1000000)){next;}
	print OUT "$arr[0]\t$start1\t$end1\n$arr[0]\t$start2\t$end2\n";
}
close IN;
close OUT;