#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 24/10/2010
##
##	This script converts the HAREM.txt corpus into the "CRF" standards (test_harem.txt)
##
##
use strict;
use warnings;
use FileHandle;
use LSP::Utils;	
use PRETEXTO::CRF;

## Initializations
my $lsp_utils = new LSP::Utils();
my $crf = new PRETEXTO::CRF();
$crf->LoadRepentino();



## Create test_data.txt
open (TESTFILE, ">test_harem.txt") or die $!;


## Open HAREM.txt
open (HAREM, "HAREM.txt") or die $!;
while (<HAREM>) {
	my $sentence = $_;
	if ($sentence eq "") {
		next;
	}
	$sentence =~ s/\n//s;
		
	## Get list CRF features
	my $ref_features_sentence = $crf->GenerateFeatures($sentence);
	my @sentence_features = @{$ref_features_sentence};
	for (@sentence_features) {
		#warn("[TITLE] => $_");
		print TESTFILE $_;
	}

}

close (TESTFILE);
close (HAREM);