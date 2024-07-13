#!/usr/bin/perl
use strict;

open(IN,"MPE.genomic.fasta.out") or die $!;
open(OUT,">MPE.genomic.list4.fasta.out") or die $!;
while(my $line = <IN>){
	chomp $line;
	$line =~ s/^\s+//;
	my @arr = split(/\s+/,$line);
	next unless($arr[4] =~ /scaffold_[123456]$/);
	print OUT "$arr[4]\t$arr[5]\t$arr[6]\tName=$arr[10]\n";
}
close IN;
close OUT;