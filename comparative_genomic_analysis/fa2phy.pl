#!/usr/bin/perl
use strict;

my $main = `pwd`;
chomp $main;
my $pos_selection = "4.pre_ps";
my $ps_dir3_1 = "4.2_filter_cds_match";
my $ps_dir3_1_1 = "4.2_filter_cds_match_phy";
opendir(DIR, "$pos_selection/$ps_dir3_1") or die $!; my @fastas = grep(/\.fasta$/, readdir(DIR)); close DIR;
foreach my $fa (sort @fastas){
	my $phy = $fa; $phy =~ s/\.fasta$/.phy/;
	system("perl $main/scripts/Fasta2Phylip.pl $pos_selection/$ps_dir3_1/$fa $pos_selection/$ps_dir3_1_1/$phy") == 0 or die $!;
}