#!/usr/bin/perl
use strict;
## conda activate comp_ana


my $main = `pwd`; chomp $main;
my @species = ("SHE","ELA","SCH","AGO","API","MPE","NFO","RMA","SMI");#change this part with your own species!
my $spe_num = $#species + 1; 
#my $spe_num = scalar @species;
my $ref = "ELA,SCH";         #the outgroup
my $astral = "/home/Huangchen/software/ASTRAL/Astral/astral.5.7.8.jar";         #path to the astral software JAR file
my $cpu = "36";
my $orth_cpu = 3*$cpu;

# step 1.0: run orthofinder
print "step 1.0: run orthofinder\n";
my $pep_dir = "./0.genomic_data/pep"; #change this part with your own pep directory!
my $cds_dir = "./0.genomic_data/cds"; #change this part with your own cds directory!
my $orth_work = "./1.orthologs"; # add this variable, the orthofinder will auto produced!
unless(-e "$orth_work/0.orthofinder.ok"){
	system("orthofinder -f $pep_dir -M msa -a $orth_cpu -o ./$orth_work") == 0 or die $!;
	open(OUT, ">$orth_work/0.orthofinder.ok") or die "$!";
	close OUT;
}

# step 1.1: select single_copy genes
print "step 1.1: select single_copy genes\n";
unless(-e "$orth_work/1.single_copy.ok"){
	system("perl ./scripts/1.select.unique.pl $orth_work/Results_*/Orthogroups/Orthogroups_SingleCopyOrthologues.txt $orth_work/single.copy.genes.txt $orth_work/Results_*/Orthogroups/Orthogroups.tsv") == 0 or die $!;
	open(OUT, ">$orth_work/1.single_copy.ok") or die "$!";
	close OUT;
}

# step 2.0: split pep with single_copy gene sets
print "step 2.0: split pep with single_copy gene sets\n";
my $align_dir = "2.gene_align";
unless(-e "$align_dir"){system(mkdir "$align_dir");}
unless(-e "$align_dir/2.gene_align.ok"){
	system("perl ./scripts/2.split_protein_for_run_prank.pl $pep_dir $orth_work $align_dir $orth_cpu");
	open(OUT, ">$align_dir/2.gene_align.ok") or die "$!";
	close OUT;
}
#=pod
# step 3: construct tree
print "step 3: construct tree\n";
my $construct_tree = "3.phylogenetic_tree";
unless(-e "$construct_tree"){system("mkdir $construct_tree");}
unless(-e "$construct_tree/3.constuct_tree.ok"){
	my $trimal_dir = "3.0.0.trimal_pep"; unless(-e "$construct_tree/$trimal_dir"){system("mkdir -p $construct_tree/$trimal_dir")}
	my $trimal_filter = "3.0.1.trimal_pep_filter"; unless(-e "$construct_tree/$trimal_filter"){system("mkdir -p $construct_tree/$trimal_filter")}
	system("perl ./scripts/3.0.0.trimal_filter_pep.pl $construct_tree $align_dir $trimal_dir $trimal_filter $spe_num $cpu") == 0 or die $!;

	
	my $pep_mer = "3.0.pep_merged"; unless(-e "$construct_tree/$pep_mer"){system("mkdir -p $construct_tree/$pep_mer")}
	system("perl ./scripts/3.0.merge_singlecopygenes_phy.pl $trimal_filter $construct_tree $pep_mer @species") == 0 or die $!;
	unless(-e "$construct_tree/3.0.pepmerged.const.ok"){
	chdir "$construct_tree/$pep_mer";
		#system("nohup raxmlHPC-PTHREADS-AVX2 -T 32 -f a -N 100 --bootstop-perms=1000 -m PROTGAMMAWAG -x 12345 -p 12345 -o $ref -s merged.aln.phy -n merged.aln.nwk &");#protein
		system("nohup raxmlHPC-PTHREADS-AVX2 -T 32 -f a -N 100 --bootstop-perms=1000 -m PROTGAMMAWAG -x 12345 -p 12345 -o $ref -s trim.merged.aln.phy -n trim.merged.aln.nwk &") == 0 or die $!;#protein
		chdir "../../";
		open(MPC, ">$construct_tree/3.0.pepmerged.const.ok") or die "$!";
		close MPC;
	}
	
	my $pep_phy = "3.1.aligned_pep_phy"; unless(-e "$construct_tree/$pep_phy"){system("mkdir -p $construct_tree/$pep_phy");}
	system("perl ./scripts/3.1.pep_phy.pl $construct_tree $trimal_filter $pep_phy @species") == 0 or die $!;
	
	unless(-e "$construct_tree/3.1.split_pep.const.ok"){
		opendir(PEPP, "$construct_tree/$pep_phy") or die "$!";my @pep_phys = grep(/phy/, readdir(PEPP)); close PEPP;
		my $out_tree = "3.1.out_pep_tree"; unless(-e "$construct_tree/$out_tree"){system("mkdir -p $construct_tree/$out_tree");}
		chdir "$construct_tree/$out_tree";
		open(PA_PC, ">../parafly_run.construct.pep.txt") or die "$!";		
		foreach my $each (sort @pep_phys){
			my $out = $each; $out =~ s/\.phy$/.nwk/;
			print PA_PC "raxmlHPC-PTHREADS-AVX2 -T 1 -f a -N 100 --bootstop-perms=1000 -m PROTGAMMAWAG -x 12345 -p 12345 -o $ref -s \"../$pep_phy/$each\" -n $out\n";
		}
		system("nohup ParaFly -c ../parafly_run.construct.pep.txt -CPU $cpu &");
		chdir "../../";
		open(MPC, ">$construct_tree/3.1.split_pep.const.ok") or die "$!";
		close MPC;
	}
	
	unless(-e "$construct_tree/3.2.split_pep.const_noroot.ok"){ ## noroot tree, and for anstral
		opendir(PEPP, "$construct_tree/$pep_phy") or die "$!";my @pep_phys = grep(/phy/, readdir(PEPP)); close PEPP;
		my $out_tree = "3.2.out_pep_tree_noroot"; unless(-e "$construct_tree/$out_tree"){system("mkdir -p $construct_tree/$out_tree");}
		chdir "$construct_tree/$out_tree";
		open(PA_PC, ">../parafly_run.construct_noroot.pep.txt") or die "$!";		
		foreach my $each (sort @pep_phys){
			my $out = $each; $out =~ s/\.phy$/.nwk/;
			print PA_PC "raxmlHPC-PTHREADS-AVX2 -T 1 -f a -N 100 --bootstop-perms=1000 -m PROTGAMMAWAG -x 12345 -p 12345 -s \"../$pep_phy/$each\" -n $out\n";
		}
		system("nohup ParaFly -c ../parafly_run.construct_noroot.pep.txt -CPU $cpu && cat RAxML_bestTree.* >../combined.all.tree.txt && java -jar $astral -r 1000 -i ../combined.all.tree.txt -o ../all_pep_astral.nwk &") == 0 or die $!;
		chdir "../../";
		open(MPC, ">$construct_tree/3.2.split_pep.const_noroot.ok") or die "$!";
		close MPC;
	}
	
	open(OUT, ">$construct_tree/3.constuct_tree.ok") or die "$!";
	close OUT;
}
#=cut
#=pod
# step 4: prepare for positive selection
print "step 4: prepare for positive selection\n";
my $pos_selection = "4.pre_ps";
unless(-e "$pos_selection"){system("mkdir $pos_selection");}
unless(-e "$pos_selection/4.prepare.ps.ok"){
	my $ps_dir1 = "4.0_CDS_format"; unless(-e "$pos_selection/$ps_dir1"){system("mkdir -p $pos_selection/$ps_dir1");}
	system("perl ./scripts/4.0.format.cds.pl $cds_dir $pos_selection $ps_dir1");
	
	my $ps_dir2 = "4.1_CDS_unalgin"; unless(-e "$pos_selection/$ps_dir2"){system("mkdir -p $pos_selection/$ps_dir2");}
	system("perl ./scripts/4.1.split_cds.pl $cds_dir $orth_work $pos_selection $spe_num");

	my $ps_dir3 = "4.2_CDS_match"; unless(-e "$pos_selection/$ps_dir3"){system("mkdir -p $pos_selection/$ps_dir3");}
	system("perl ./scripts/4.2.match_AA_NU_Prank.pl $pos_selection $ps_dir2 $align_dir $ps_dir3");
	
	my $ps_dir3_1 = "4.2_filter_cds_match"; unless(-e "pos_selection/$ps_dir3_1"){system("mkdir -p $pos_selection/$ps_dir3_1");}
	my $ps_dir3_1_1 = "4.2_filter_cds_match_phy"; unless(-e "pos_selection/$ps_dir3_1_1"){system("mkdir -p $pos_selection/$ps_dir3_1_1");}
	unless(-e "$pos_selection/4.2.fa2phy.ok"){
		opendir(DIR, "$pos_selection/$ps_dir3_1") or die $!; my @fastas = grep(/\.fasta$/, readdir(DIR)); close DIR;
		foreach my $fa (sort @fastas){
			my $phy = $fa; $phy =~ s/\.fasta$/.phy/;
			system("perl $main/scripts/Fasta2Phylip.pl $pos_selection/$ps_dir3_1/$fa $pos_selection/$ps_dir3_1_1/$phy") == 0 or die $!;
		}
		open(OUT, ">$pos_selection/4.2.fa2phy.ok") or die "$!";
		close OUT;
	}
	
	my $ps_dir3_2 = "4.2_trimal_filter_cds_match"; unless(-e "pos_selection/$ps_dir3_2"){system("mkdir -p $pos_selection/$ps_dir3_2");}
	my $ps_dir3_3 = "4.2_trimal_refilter_cds_match"; unless(-e "pos_selection/$ps_dir3_3"){system("mkdir -p $pos_selection/$ps_dir3_3");}
	system("perl ./scripts/4.2.match_trim_filter.pl $pos_selection $ps_dir3 $ps_dir3_1 $ps_dir3_2 $ps_dir3_3 $spe_num $cpu"); # trim the unaligned nucleotide
	
	my $cds_merge = "4.3_CDS_merge_tree"; unless(-e "$pos_selection/$cds_merge"){system("mkdir -p $pos_selection/$cds_merge");}
	system("perl ./scripts/4.3.merge_singlecopygenes_phy.pl $pos_selection $cds_merge @species");
	unless(-e "$pos_selection/4.3.merged_cds.tree.ok"){
		chdir("$pos_selection/$cds_merge");
		#system("nohup raxmlHPC-PTHREADS-AVX -T 2 -f a -N 100 --bootstop-perms=1000 -m GTRCATI -x 12345 -p 12345 -o $ref -s merged.aln.phy -n merged.aln.nwk &");#-m GTRCATI，GTRGAMMA for nucleotide,-f 慢速搜索，结果几乎无差异		chdir "../../";	
		system("nohup raxmlHPC-PTHREADS-AVX2 -T 32 -f a -N 100 --bootstop-perms=1000 -m GTRCATI -x 12345 -p 12345 -o $ref -s merged.aln.phy -n merged.aln.nwk &");#-m GTRCATI，GTRGAMMA for nucleotide,-f 慢速搜索，结果几乎无差异		chdir "../../";	
		chdir "../../";
		open(OUT, ">$pos_selection/4.3.merged_cds.tree.ok") or die "$!";
		close OUT;
	}

	my $ps_dir4 = "4.4_aligned_cds_phy"; unless(-e "$pos_selection/$ps_dir4"){system("mkdir -p $pos_selection/$ps_dir4");}
	system("perl ./scripts/4.4.Reorder_Change_phy_format.pl $pos_selection $ps_dir3_3 $ps_dir4 @species");
	
	unless(-e "$pos_selection/4.4.split_cds.const.ok"){
		opendir(PEPP, "$pos_selection/$ps_dir4") or die "$!";my @cds_phys = grep(/phy/, readdir(PEPP)); close PEPP;
		my $out_tree = "4.4_out_cds_tree";
		unless(-e "$pos_selection/$out_tree"){system("mkdir -p $pos_selection/$out_tree");}
		chdir "$pos_selection/$out_tree";
		open(PA_PC, ">../parafly_run.construct.cds.txt") or die "$!";		
		foreach my $each (sort @cds_phys){
			my $out = $each; $out =~ s/\.phy$/.nwk/;
			print PA_PC "raxmlHPC-PTHREADS-AVX2 -T 2 -f a -N 100 --bootstop-perms=1000 -m GTRCATI -x 12345 -p 12345 -o $ref -s \"../$ps_dir4/$each\" -n $out\n";
		}
		system("nohup ParaFly -c ../parafly_run.construct.cds.txt -CPU $cpu &");
		chdir "../../";
		open(MPC, ">$pos_selection/4.4.split_cds.const.ok") or die "$!";
		close MPC;
	}

	unless(-e "$pos_selection/4.4.split_cds_noroot.const.ok"){
		opendir(PEPP, "$pos_selection/$ps_dir4") or die "$!";my @cds_phys = grep(/phy/, readdir(PEPP)); close PEPP;
		my $out_tree = "4.4_out_cds_tree_noroot";
		unless(-e "$pos_selection/$out_tree"){system("mkdir -p $pos_selection/$out_tree");}
		chdir "$pos_selection/$out_tree";
		open(PA_PC, ">../parafly_run.construct.cds_noroot.txt") or die "$!";		
		foreach my $each (sort @cds_phys){
			my $out = $each; $out =~ s/\.phy$/.nwk/;
			print PA_PC "raxmlHPC-PTHREADS-AVX2 -T 1 -f a -N 100 --bootstop-perms=1000 -m GTRCATI -x 12345 -p 12345 -s \"../$ps_dir4/$each\" -n $out\n";
		}
		system("nohup ParaFly -c ../parafly_run.construct.cds_noroot.txt -CPU $cpu && cat RAxML_bestTree.* >../combined.all.tree.txt && java -jar $astral -r 1000 -i ../combined.all.tree.txt -o ../astral.nwk &");
		chdir "../../";
		open(MPC, ">$pos_selection/4.4.split_cds_noroot.const.ok") or die "$!";
		close MPC;
	}
=pod	
	my $ps_dir5 = "4.5_gblock_aligned_ori"; unless(-e "$pos_selection/$ps_dir5"){system("mkdir -p $pos_selection/$ps_dir5");}
	opendir(A_CDS, "$pos_selection/$ps_dir3_1") or die $!; my @matched_cds = grep(/\.fasta/g, readdir(A_CDS)); close A_CDS;
	chdir "$pos_selection/$ps_dir5";
	open(PA_GB, ">parafly_run.gblocks.txt") or die "$!";	
	foreach my $each (sort @matched_cds){
		my $cmd = "cp ../$ps_dir3_1/$each ./ && Gblocks $each -t=c && rm -rf ./$each";
		print PA_GB "$cmd\n";
	}close PA_GB;
	system("ParaFly -c parafly_run.gblocks.txt -CPU 32") or die $!;
	chdir "../..";
	
	my $ps_dir6 = "4.6_gblock2paml"; unless(-e "$pos_selection/$ps_dir6"){system("mkdir -p $pos_selection/$ps_dir6");}
	opendir(G_CDS, "$pos_selection/$ps_dir5") or die $!; my @matched_gblocks = grep(/\-gb$/, readdir(G_CDS)); close G_CDS;
	chdir "$pos_selection/$ps_dir6";
	open(PA_GBPM, ">parafly_run.gblocks2paml.txt") or die "$!";
	foreach my $each (sort @matched_gblocks){
		my $out = "$each".".paml";
		#print "$out\n";
		system("perl ../../scripts/4.5.Gblocks2Paml.pl ../$ps_dir5/$each $out") == 0 or die $!;
		print PA_GBPM "perl ../../scripts/4.5.Gblocks2Paml.pl ../$ps_dir5/$each $out\n";
	}close PA_GBPM;
	system("ParaFly -c parafly_run.gblocks2paml.txt -CPU 32") or die $!;
	chdir "../..";	
=cut	
	open(OUT, ">$pos_selection/4.prepare.ps.ok") or die "$!";
	close OUT;
}
#=cut
