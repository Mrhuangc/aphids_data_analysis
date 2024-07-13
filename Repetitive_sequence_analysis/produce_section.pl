#!/usr/bin/perl
use strict;

my $break_point_bed = shift @ARGV;  #Collinear breakpoint regions BED file
my $chr_len_file = shift @ARGV;    #Chromosome length BED file
my $windows_size1 = shift @ARGV;    #Required window size to be generated
my $repeat_num = shift @ARGV;       #Number of repetitions
my $outdir = shift @ARGV;           #Output file directory

my %hash;my %hash1;
open(IN,"$chr_len_file") or die $!;
while(my $line = <IN>){
	chomp $line;
	my @arr = split(/\t/,$line);
	$hash{$arr[0]} = $arr[1];
	$hash1{$arr[0]} = 0;
}
close IN;
my $chr_num = scalar(keys(%hash));

open(INN,"$break_point_bed") or die $!;
while(my $line = <INN>){
	chomp $line;
	foreach my $each (sort(keys %hash1)){
		if($line =~ /$each/){
			$hash1{$each}++;
		}
	}
}
close INN;

sub producewindows{
	my $chr_name = shift @_;
	my $chr_len = shift @_;
	my $windows_size = shift @_;
	my $windows_number = shift @_;
	my $leftpoint = 1000000 + $windows_size/2;
	my $rightpoint = $chr_len - 1000000 - $windows_size/2;
	my @windows_midpoint;
	while(scalar(@windows_midpoint) < $windows_number){
		my $num = int(rand($rightpoint));
		if($num < $leftpoint){
			$num = $num + $leftpoint;
		}
		if(scalar(@windows_midpoint) < 1){
			push @windows_midpoint,$num;
			next;
		}
		my $tag = 0;
		foreach my $each (@windows_midpoint){
			if(abs($num - $each) < $windows_size){
				$tag = 1;
			}
		}
		if($tag == 0){
			push @windows_midpoint,$num;
		}
	}
	my $string;
	foreach my $each (sort @windows_midpoint){
		 my $start = $each - $windows_size/2;
		 my $end = $each + $windows_size/2;
		 $string .= "$chr_name\t$start\t$end\n";
	}
	return "$string";
}

unless(-e '$outdir'){system("mkdir $outdir");}
for(my $a = 1;$a <= $repeat_num;$a = $a + 1){
	my $outfile;
	$outfile = $chr_len_file."window.".$a.".bed";
	my $string;
	foreach my $each (sort(keys %hash)){
		$string .= producewindows($each,$hash{$each},$windows_size1,$hash1{$each});
	}
	open(OUT,">$outdir/$outfile") or die $!;
	print OUT "$string";
	close OUT;
}
