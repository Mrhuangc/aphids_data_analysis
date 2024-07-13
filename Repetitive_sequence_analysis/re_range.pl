#!/usr/bin/perl
use strict;

my $refile = shift;
open(IN,"$refile") or die $!;
my $outfile = $refile.".sort";
open(OUT,">$outfile") or die $!;
my @aa;
while(my $line = <IN>){
	chomp $line;
	push @aa,$line;
}
close IN;

foreach my $each (sort @aa){
	print OUT "$each\n";
}
close OUT;
