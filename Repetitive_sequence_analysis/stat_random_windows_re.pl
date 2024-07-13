#!/usr/bin/perl
use strict;

my $indir = shift @ARGV;
my $final_out = shift @ARGV;

opendir(IN,"$indir") or die $!;
my @arr = grep(/bed$/,readdir(IN));
my @arr = sort @arr;
my $outfile  = $indir."_stat.txt";

foreach my $each (sort @arr){
	system("grep 'DNA' $indir/$each | wc -l >> $outfile");
	system("grep 'SINE' $indir/$each | wc -l >> $outfile");
	system("grep 'LINE' $indir/$each | wc -l >> $outfile");
	system("grep 'LTR' $indir/$each | wc -l >> $outfile");
	system("grep 'RC' $indir/$each | wc -l >> $outfile");
	system("grep 'Retro' $indir/$each | wc -l >> $outfile");
	system("grep 'Unknown' $indir/$each | wc -l >> $outfile");
	system("grep 'Simple' $indir/$each | wc -l >> $outfile");
	system("grep 'Low_complexity' $indir/$each | wc -l >> $outfile");
}

open(STAT,"$outfile") or die $!;
open(OUT,">$final_out") or die $!;
my $num = 1;my $string;my $tag = 0;
while(my $line = <STAT>){
	chomp $line;
	if($num == 9){
		$string .= "$line\n";
		$num = 1;
		print OUT "$arr[$tag]\t$string";
		$tag++;
		$string = "";
		next;
	}
	if($num < 9){
		$string .= "$line\t";
		$num++;
	}
	
}
close STAT;
close OUT;