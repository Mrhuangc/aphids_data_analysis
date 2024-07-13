#!/usr/bin/perl

use strict;
use warnings;

my $main = `pwd`; chomp $main;
my $branch = $ARGV[0];# branch name
my $M0N0="$main/$branch/site1/M2N2_unroot";    # change the path
my $M1N0="$main/$branch/site2/M2N2_unroot";

opendir(FOLDER,"$M0N0"); my @arrayfile = grep(/out$/,readdir(FOLDER));close FOLDER;

my $outfilefolder="$main/$branch";unless(-e $outfilefolder){system("mkdir -p $outfilefolder");}

# system ("md $outfilefolder"); 

my $outfile="BS_domestic_".$branch.".sum"; 
open (OUT, ">>$outfilefolder/$outfile");
###################################################################################################################################### 
###  This part need to be changed for your own data.  
print OUT "Gene_name	LN1	Ln2	pro_1	pro_2	pro_2a	pro_2b	bac_1	bac_2	bac_2a	bac_2b	for_1	for_2	for_2a	for_2b	LRT	Significance\n";   
######################################################################################################################################
foreach my $filename ( @arrayfile ){
	my $M0N0file="$M0N0/$filename";
    my $M1N0file="$M1N0/$filename";
    $filename=~s/\.out//;
	print OUT "$filename\t";
	
	open (M0N0, "$M0N0file") or die print "can not open M0N0"; 
	my $Ln1; 
	while (<M0N0>){   
		my $line=$_;
		if($line=~/lnL\(ntime: .+  np: .+\):\s*(\S+)\s+.+/){$Ln1=$1;}
	}
    close M0N0; 
	if(!defined($Ln1)){
		print "$filename\n";
	}else{
	print OUT "$Ln1\t";
	}
	
	open (M1N0, "$M1N0file") or die print "can not open M1N0"; 
	my $Ln2;
	my $offon=0; 
	 
	while (<M1N0>){   
		my $line=$_;
		if($line=~/lnL\(ntime: .+  np: .+\):\s*(\S+)\s+.+/){$Ln2=$1;  print OUT "$Ln2\t";}  
	#   5..1       0.000   1441.7    295.3   0.4416   0.0000   0.0000    0.0    0.0 
		if ($line=~/^kappa/) {$offon=1} 
		if ($line=~/Naive Empirical Bayes/)   {$offon=0} 
###################################################################################################################################### 
	###  This part need to be changed for your own data.        number of each branch are different
	    if (($line=~/proportion/) and ($offon ==  1)){             
			my @array=split(/\s+/,$line);     
			print OUT"$array[1]\t$array[2]\t$array[3]\t$array[4]\t";  
		}     
	    if (($line=~/background w/) and ($offon ==  1)){                 
			my @array=split(/\s+/,$line);
			print OUT"$array[2]\t$array[3]\t$array[4]\t$array[5]\t";  
		}
	    if (($line=~/foreground w/) and ($offon ==  1)){                 
			my @array=split(/\s+/,$line);
			print OUT"$array[2]\t$array[3]\t$array[4]\t$array[5]\t";  
		}
############################################################################################################################   
	}
	close M1N0;
	
	my $LRT=(abs($Ln2-$Ln1))*2; 
    print OUT "$LRT\t";
    if ($LRT>6.635)  {print OUT "Very_significant\n";}
    if ($LRT<3.841)  {print OUT "Not_significant\n";}
    if (($LRT>3.841) and ($LRT<6.635))  {print OUT "Significant\n";}
	
	#1          2.706     3.841     5.024     6.635    10.828
}
close OUT;