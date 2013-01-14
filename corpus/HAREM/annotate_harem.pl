#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 24/10/2010
##
##	This script uses the HAREM.xml file and generates an 'annotated_harem.txt'
##		file in plain text with names annotated in harem as <PN>...</PN>
##
##
use strict;
use warnings;
use PRETEXTO::HAREM;

my $harem = new PRETEXTO::HAREM;

my $counter = 0;

# output file
open ANNOTATED_HAREM, ">:utf8", "annotated_harem.txt" or die $!;


## Create test_data.txt
open (HAREM, "HAREM.xml") or die $!;
while (<HAREM>) {
	my $line = $_;
	$counter++;
	
	$line =~ s/^( |\t){0,}//s;
	$line =~ s/<\/P>/\n\n/s;

	#print "\n [BEFORE]=> $line\n";
	$line = $harem->ProcessLineFromHAREM($line);
	#print "[AFTER] $line\n";
	
	$line =~ s/\s\s$/##/s;
	$line =~ s/\s$/\*/s;
	
	$line =~ s/##\*/\n/s;
	$line =~ s/##/ /s;	
		
	#print "[$counter] '$line'\n";		
		
	if ($line =~ /^\n$/) {
		next;
	}
	
	$line =~ s/^\s{0,}//s;
	$line =~ s/\s{0,}\n$/\n/s;
	
	print ANNOTATED_HAREM $line;

	#if ($counter > 4000) {
	#	last;
	#}
}



close (HAREM);
close (ANNOTATED_HAREM);