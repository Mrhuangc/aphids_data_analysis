#!/bin/perl
use strict;

my $main = `pwd`; chomp $main;

## change this part;
my $dir = "/DATADISK/Huangchen/comp/aphis_comp_nine/4.pre_ps/4.2_filter_cds_match_phy"; opendir(DIR, $dir) or die "$!"; my @files = grep(/\.phy$/, readdir(DIR)); close DIR;
my $scr = "Run_CODEML_unroot_site2.pl"; # change!
my $model=2;      # 0, 1  # change!
my $Nsites=2 ;      # 0, 1, 2, 3, 7, 8  # change!
my $tree = "tree_site.txt";
##

my $outfilefoder='M'.$model.'N'.$Nsites.'_unroot'; unless(-e "$outfilefoder"){system("mkdir -p $outfilefoder");} 
my $codeml_dir = "cof"; unless(-e "$codeml_dir"){system("mkdir -p $codeml_dir");} 

open(OUT, ">parafly_multirun.txt") or die "$!";
foreach my $file (@files){
	my $file_dir = $file; $file_dir =~ s/\.phy$/_phy_dir/; unless(-e "$file_dir"){system("mkdir -p $file_dir");}
	my $new_conf = $file; $new_conf =~ s/_match_align\.phy$//; $new_conf = "codeml.".$new_conf.".ctl";
	system("cp $main/codeml_copy.ctl $main/$codeml_dir/$new_conf");
	print OUT "cd $main/$file_dir && perl $main/$scr $main $dir $file $tree $new_conf $codeml_dir && cd ../ && rm -rf $file_dir\n";
}
system("ParaFly -c $main/parafly_multirun.txt -CPU 16");
