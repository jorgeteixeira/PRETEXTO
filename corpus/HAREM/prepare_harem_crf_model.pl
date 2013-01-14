#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 24/10/2010
##
##	This script converts the annotated_harem.txt corpus into the "CRF" standards
##		(annotated_harem_crf.txt)
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
open (HAREMCRF, ">:utf8", "annotated_harem_crf.txt") or die $!;


## Open annotated_harem.txt
open (HAREM, "annotated_harem.txt") or die $!;
while (<HAREM>) {
	my $sentence = $_;
	if ($sentence eq "") {
		next;
	}
	$sentence =~ s/\n//s;
		
	## Get list CRF features (all features)
	my $ref_features_sentence = $crf->GenerateFeatures($sentence);
	my @sentence_features = @{$ref_features_sentence};
	for (@sentence_features) {
		#warn("[TITLE] => $_");
		print HAREMCRF $_;
	}

}

close (HAREMCRF);
close (HAREM);