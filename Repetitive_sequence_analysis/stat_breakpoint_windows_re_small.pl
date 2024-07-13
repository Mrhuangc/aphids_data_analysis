#!/usr/bin/perl
use strict;

my $infile = shift @ARGV;
my $outfile = $infile.".stats.small";
my $re_type_file = shift @ARGV;

my @re_type;
open(TYPE,"$re_type_file") or die $!;
while(my $line = <TYPE>){
	chomp $line;
	push @re_type,$line;
}
close TYPE;

foreach my $each (sort @re_type){
	my $pattern = '$'."'$each\\t'";
	print "$each\n";
	system("grep $pattern $infile | wc -l >> $outfile");
}