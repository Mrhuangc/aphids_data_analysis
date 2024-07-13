#!/usr/bin/perl
use strict;
use warnings;

my $model=0;      # 0, 1
my $Nsites=0 ;      # 0, 1, 2, 3, 7, 8

my $outfilefoder='M'.$model.'N'.$Nsites.'_unroot';       # output files path
my $filename = $ARGV[0]; my $tree = $ARGV[1]; my $codemlfile = $ARGV[2]; my $dir = $ARGV[3];
my $outfile = $filename; $outfile=~ s/\.phy/\.out/;
my $restoutfile=$outfile; $restoutfile=~s/\.out/\.rst/;
my $outcodeml = $codemlfile.".out";
open(FILE, "./codemlfile/$codemlfile");
open(OUT,">./codemlfile/$outcodeml");

while( my $line = <FILE> ){
	if( $line =~ /seqfile =/ ){
		print OUT "      seqfile = $dir/$filename\n";
	}          
    elsif( $line =~ /treefile =/ ){
		print OUT "      treefile = $tree\n";
    }
    elsif( $line =~ /outfile =/ ){
		print OUT "      outfile = $outfilefoder/$outfile        * main result file name\n";
	}
    elsif ($line =~ / model =/ ){
        print OUT "      model =     $model\n" ; 
    } 
    elsif ($line =~ / NSsites =/ ){
        print OUT "      NSsites =   $Nsites\n" ; 
    } 
    #elsif ($line =~ /fix_omega = 0/ ) {
    #    print OUT "      fix_omega = 1\n" ; 
    #}        # fix_omega = 0  * 1: omega or omega_1 fixed, 0: estimate 
    #elsif ($line =~ /omega = .4/ ){
    #    print OUT "      omega = 1\n" ; 
    #}       # omega = .4 * initial or fixed omega, for codons or codon-based AAs
    else{
		print OUT "$line";
	}            			
}
close FILE;
close OUT;

system ("codeml ./codemlfile/$outcodeml");
#system ("rm codeml.ctl");
#system ("rename rst $restoutfile");
#system ("cp $restoutfile $outfilefoder");
#system ("rm $restoutfile");
