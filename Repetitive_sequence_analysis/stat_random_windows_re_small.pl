#!/usr/bin/perl
use strict;

my $indir = shift @ARGV;
#my $final_out = shift @ARGV;
my $re_type_file = shift @ARGV;

opendir(IN,"$indir") or die $!;
my @arr = grep(/bed$/,readdir(IN));
my @arr = sort @arr;
my $outfile  = $indir."_stat.txt";

my @re_type;
open(TYPE,"$re_type_file") or die $!;
while(my $line = <TYPE>){
	chomp $line;
	push @re_type,$line;
}
close TYPE;

my $re_num = 0;my $re_type_head_line = "file_id\t";
open(OUTT,">para_grep_retype.txt") or die $!;
unless(-e 'random_windows_10000_overlap_stat'){system("mkdir random_windows_10000_overlap_stat")}
foreach my $type (sort @re_type){
	foreach my $each (sort @arr){
		my $outfile_small = $each;
		$outfile_small = $outfile_small.".stats";
		my $pattern = '$'."'$type\\t'";
		print OUTT "grep $pattern $indir/$each | wc -l >> random_windows_10000_overlap_stat/$outfile_small\n";
	}
	$re_num++;
	$re_type_head_line .= "$type\t";
}
$re_type_head_line =~ s/\t$/\n/;
close OUTT;

=pod
open(STAT,"$outfile") or die $!;
open(OUT,">$final_out") or die $!;
print OUT "$re_type_head_line";
my $num = 1;my $string;my $tag = 0;
while(my $line = <STAT>){
	chomp $line;
	if($num == $re_num){
		$string .= "$line\n";
		$num = 1;
		print OUT "$arr[$tag]\t$string";
		$tag++;
		$string = "";
		next;
	}
	if($num < $re_num){
		$string .= "$line\t";
		$num++;
	}
	
}
close STAT;
close OUT;
=cut