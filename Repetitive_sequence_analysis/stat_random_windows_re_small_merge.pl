#!/use/bin/perl
use strict;

my $overlap_small_re_dir = shift;
my $re_type_file = shift;
my $outputfile = shift;

opendir(DIR,"$overlap_small_re_dir") or die $!;
my @file = grep(/stats$/,readdir(DIR));close DIR;

open(TYPE,"$re_type_file") or die $!;
my $re_type = "file_id\t";
while(my $line = <TYPE>){
	chomp $line;
	$re_type .= "$line\t";
}
$re_type =~ s/\t$/\n/;
close TYPE;

open(OUT,">$outputfile") or die $!;
print OUT "$re_type";
foreach my $each (sort @file){
	my $string = "$each\t";
	open(IN,"$overlap_small_re_dir/$each") or die $!;
	while(my $line = <IN>){
		chomp $line;
		$string .= "$line\t";
	}
	$string =~ s/\t$/\n/;
	print OUT "$string";
	close IN;
}