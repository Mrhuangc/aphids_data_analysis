#/usr/bin/perl
use strict;

my $input = shift;
my $outfile = $input.".rerange.bed";

open(IN,"$input") or die $!;
open(OUT,">$outfile") or die $!;
while(my $line = <IN>){
	chomp $line;
	my @arr = split(/\t/,$line);
	if($arr[1] > $arr[2]){
		print OUT "$arr[0]\t$arr[2]\t$arr[1]\n";
	}else{
		print OUT "$line\n";
	}
}
close IN;
close OUT;