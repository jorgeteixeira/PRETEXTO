#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 25/10/2010
##
##	This script converts the dataset of news 'dataset/annotated_dataset_news_0.txt'
##		to a CRF structure file 'models/dataset_0.crf'
##
##
use strict;
use warnings;
use LSP::Utils;	
use PRETEXTO::CRF;
use PRETEXTO::Tools;



## Initializations
my $lsp_utils = new LSP::Utils();
my $crf = new PRETEXTO::CRF();
$crf->LoadRepentino();
my $tools = new PRETEXTO::Tools;



## Create test_data.txt
open (STRUCTURE_CRF, ">:utf8", "models/dataset_0.crf") or die $!;




## Open annotated_harem.txt
my $counter = 0;
open (DATASET, "dataset/annotated_dataset_news_0.txt") or die $!;
while (<DATASET>) {
	my $line = $_;
	$line =~ /^(.+?)\t(.+?)\t(.+?)$/;
	my $id = $1;
	my $title = $2;
	my $content = $3;
		
	## print news id
	my $ref_features_id = $crf->GenerateFeatures($id);
	my @id_features = @{$ref_features_id};
	for (@id_features) {
		my $line = $_;
		$line = $tools->SetStringToUtf8($line);
		#warn("[TITLE] => $_");
		print STRUCTURE_CRF $line;
	}	
		
	## Get list CRF features for title
	my $ref_features_title = $crf->GenerateFeatures($title);
	my @title_features = @{$ref_features_title};
	for (@title_features) {
		my $line = $_;
		$line = $tools->SetStringToUtf8($line);
		#warn("[TITLE] => $_");
		print STRUCTURE_CRF $line;
	}
	
	## Get list CRF features for content
	my $ref_features_content = $crf->GenerateFeatures($content);
	my @content_features = @{$ref_features_content};
	for (@content_features) {
		my $line = $_;
		$line = $tools->SetStringToUtf8($line);
		#warn("[TITLE] => $_");
		print STRUCTURE_CRF $line;
	}	
	$counter++;
	if ($counter % 50 eq 0) {
		print "Processing news $counter of 20,000...\n";
	}	
}

close (STRUCTURE_CRF);
close (DATASET);