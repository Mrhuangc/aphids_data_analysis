#!/usr/bin/perl
use strict;

my $indir = shift @ARGV;     #windows目录
my $outdir = shift @ARGV;    #输出目录
my $RE_bed = shift @ARGV;    #重复序列bed文件

opendir(IN,"$indir") or die $!;
my @arr = grep(/bed$/,readdir(IN));closedir IN;

unless(-e '$outdir'){system("mkdir $outdir");}
my $para = "para_run_intersect.".$indir.".txt";
open(OUT,">$para") or die $!;
foreach my $each (@arr){
	chomp $each;
	my $outfile = $each;
	$outfile =~ s/bed/overlap.bed/;
	print OUT "bedtools intersect -b $RE_bed -a $indir/$each -wao > $outdir/$outfile\n";
#	system("bedtools intersect -b $RE_bed -a $indir/$each -wao > $outdir/$outfile");
}

system("ParaFly -c $para -CPU 50");