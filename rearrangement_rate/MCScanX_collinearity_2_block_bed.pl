#!/usr/bin/perl
use strict;

my $input_collinearity = shift @ARGV;
my $input_gff = shift @ARGV;

open(ING,"$input_gff") or die $!;
my %SMI_gff_s;my %API_gff_s;my %SMI_gff_e;my %API_gff_e;
while(my $line = <ING>){
	chomp $line;
	my @arr = split(/\t/,$line);
	if($line =~ /SMI/){	
		$SMI_gff_s{$arr[1]} = $arr[2];
		$SMI_gff_e{$arr[1]} = $arr[3];
	}
	if($line =~ /API/){	
		$API_gff_s{$arr[1]} = $arr[2];
		$API_gff_e{$arr[1]} = $arr[3];
	}
}
close ING;

open(INC,"$input_collinearity") or die $!;
my $ID;my %SMI;my %API;
while(my $line = <INC>){
	chomp $line;
	if($line =~ /^##/ and $line !~ /Alignment/){
		next;
	}
	if($line =~ /Alignment/){
		$ID = $line;
	}else{
		my @arr = split(/\t/,$line);
		push @{$SMI{$ID}},$arr[2];
		push @{$API{$ID}},$arr[1];
	}
}
close INC;

#print @{$SMI{'## Alignment 51: score=6355.0 e_value=0 N=129 SMI2&API4 minus'}},"\n";

my $out = $input_collinearity;
$out =~ s/collinearity/collinearity.bed/;
open(OUT,">$out") or die $!;
my %final;
foreach my $each (sort(keys %API)){
	my $API_s = ${$API{$each}}[0];
	my $API_e = ${$API{$each}}[-1];
	my $SMI_s = ${$SMI{$each}}[0];
	my $SMI_e = ${$SMI{$each}}[-1];
	my $SMI_block_s = $SMI_gff_s{$SMI_s};
	my $SMI_block_e = $SMI_gff_e{$SMI_e};
	my $API_block_s = $API_gff_s{$API_s};
	my $API_block_e = $API_gff_e{$API_e};
	my @arr = split(/\s/,$each);
	my @aaa = split(/&/,$arr[6]);
	$final{"$aaa[0]\t$API_block_s\t$API_block_e\t$aaa[1]\t$SMI_block_s\t$SMI_block_e"} = $each;
}

foreach my $each (sort(keys %final)){
	print OUT "$final{$each}\n$each\n";
}
close OUT;
