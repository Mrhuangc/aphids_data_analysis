#!/usr/bin/perl
use strict;
use warnings;

my $model=2;      # 0, 1
my $Nsites=2 ;      # 0, 1, 2, 3, 7, 8

my $main = $ARGV[0]; 
my $dir = $ARGV[1];
my $filename = $ARGV[2];
my $tree = $ARGV[3];
my $codemlfile = $ARGV[4];
my $codeml_dir = $ARGV[5]; 
my $outfilefoder='M'.$model.'N'.$Nsites.'_unroot';       # output files path
my $outfile = $filename; $outfile=~ s/\.phy$/\.out/;
my $restoutfile=$outfile; $restoutfile=~s/\.out/\.rst/;

my $outcodeml = $codemlfile.".out";
open(FILE, "$main/$codeml_dir/$codemlfile");
open(OUT,">$main/$codeml_dir/$outcodeml");

while( my $line = <FILE> ){
	if( $line =~ /seqfile =/ ){
		print OUT "      seqfile = $dir/$filename\n";
	}          
    elsif( $line =~ /treefile =/ ){
		print OUT "      treefile = $main/$tree\n";
    }
    elsif( $line =~ /outfile =/ ){
		print OUT "      outfile = $main/$outfilefoder/$outfile        * main result file name\n";
	}
    elsif ($line =~ / model =/ ){
        print OUT "      model =     $model\n" ; 
    } 
    elsif ($line =~ / NSsites =/ ){
        print OUT "      NSsites =   $Nsites\n" ; 
    } 
    elsif ($line =~ /fix_omega = 0/ ) {
        print OUT "      fix_omega = 1\n" ; 
    }        # fix_omega = 0  * 1: omega or omega_1 fixed, 0: estimate 
    elsif ($line =~ /omega = .4/ ){
        print OUT "      omega = 1\n" ; 
    }       # omega = .4 * initial or fixed omega, for codons or codon-based AAs
    else{
		print OUT "$line";
	}            			
}
close FILE;
close OUT;

print "confile.ok\n";
print "$main/$codeml_dir/$outcodeml\n";
system ("codeml $main/$codeml_dir/$outcodeml");
print "run codeml ok\n";
#system ("rm codeml.ctl");
system ("mv rst $restoutfile");
system ("cp $restoutfile $main/$outfilefoder");
#system ("rm $restoutfile");
