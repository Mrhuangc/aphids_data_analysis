#!/usr/bin/perl
use strict;

# mannually setup the cafe configures with tree file
# step 7: gene family expansion and contraction;
# python2 env
print "step 7: gene family expansion and contraction\n";

my $timetree = "";   #time tree, nwk format

my $main = `pwd`;
chomp($main);
my $orth_work = "1.orthologs";
my $exp_contra = "7.expansion_contraction";
unless(-e ""){system("mkdir -p $exp_contra");}
chdir "$exp_contra";
unless(-e "$exp_contra/7.gene_fam_exp_contra.ok"){
	my $pre_cafe = "7.0.filter_input"; unless(-e $pre_cafe){system("mkdir -p $pre_cafe");} 
	chdir "$pre_cafe";
	system("cp $main/$orth_work/Results*/Orthogroups/Orthogroups.GeneCount.tsv ./");
	#my $cmd = qq{awk 'OFS="\t" {$NF=""; print}' Orthogroups.GeneCount.tsv > tmp && awk '{print "(null)""\t"$0}' tmp > cafe.input.tsv && sed -i '1s/(null)/Desc/g' cafe.input.tsv && rm tmp};
	#system($cmd);
	
	open(IN, "Orthogroups.GeneCount.tsv") or die $!;
	open(TRANS, ">cafe.input.tsv") or die $!;
	while(my $line = <IN>){
		chomp($line);
		next if $line =~ /^\s+/;
		my @arr = split(/\t/, $line);
		if($line =~ /^OG/){
			print TRANS "(null)\t$arr[0]\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[4]\t$arr[5]\t$arr[6]\t$arr[7]\t$arr[8]\t$arr[9]\t$arr[10]\t$arr[11]\t$arr[12]\t$arr[13]\t$arr[14]\n";
		}else{
			print TRANS "Desc\t$arr[0]\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[4]\t$arr[5]\t$arr[6]\t$arr[7]\t$arr[8]\t$arr[9]\t$arr[10]\t$arr[11]\t$arr[12]\t$arr[13]\t$arr[14]\n";
		}
	}close IN; close TRANS;
	
	system("python3 $main/scripts/cafetutorial_clade_and_size_filter.py -i cafe.input.tsv -o filtered_cafe_input.txt -s 2> filtered.log");
	chdir "../";
	
	my $run_cafe = "7.1.run_cafe"; unless(-e $run_cafe){system("mkdir -p $run_cafe");}
	chdir "$run_cafe";
	system("cp ../$pre_cafe/filtered_cafe_input.txt ./");
	system("sed -i 's/\.pep//g' filtered_cafe_input.txt");
	system("cp $main/configures/cafetutorial_run1.sh ./");
	unless(-e "reports"){system("mkdir -p reports");}
	system("cafe ./cafetutorial_run1.sh");
	system("python2 $main/scripts/cafetutorial_report_analysis.py -i reports/report_run1.cafe -o reports/summary_run1");# -s default is 100, you can specific this, but less than 200
	my @cafe_type = ("Expansions", "Contractions", "Rapid");
	my $tree_nwk;
	open(TREE, "$timetree") or die "$!";
	while(my $line = <TREE>){
		chomp($line);
		$line =~ s/\;$//; $tree_nwk = $line;
	}close TREE;
	my $node;
	open(ND, "./reports/summary_run1_fams.txt") or die $!;
	while(my $line = <ND>){
		chomp($line);
		if($line =~ m/^\# The/){
			my @arr = split(/\s+/, $line); $node = $arr[-1];
		}
	}close ND;
	foreach my $each (@cafe_type){
		system("python3 $main/scripts/cafetutorial_draw_tree.py -i ./reports/summary_run1_node.txt -t \"$tree_nwk\" -d \"$node\" -o summary_run1_tree_$each.png -y $each");
	}
	chdir "../../";
	
	open(OUT, ">$main/$exp_contra/7.gene_fam_exp_contra.ok") or die $!;
	close OUT;	
}