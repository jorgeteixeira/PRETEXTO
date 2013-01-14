#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 25/04/2011
##
##	This script tests the dataset of news in the CRF model build
##
##
use strict;
use warnings;



## Initialization
my $cycle = 0;
my $nr_new_names = 1000;



## Run this loop (bootstrapping) until the number of new names is < 100
while ($nr_new_names > 100) {
	print "Running iteration $cycle\n";
	
	system("perl 3C_annotate_dataset_news.pl $cycle > logs/annotated_dataset_$cycle.log");
	system("perl 4C_convert_dataset_to_crf_structure.pl $cycle");
	system("perl 5C_learn_model.pl $cycle");
	system("perl 6C_test_data.pl $cycle");
	system("perl 7C_identify_new_names_test_dataset.pl $cycle > logs/iteration_$cycle.log");

	# Ready to start a new iteration of 
	$cycle++;	

	# Check the number of new names found for this iteration
	$nr_new_names = 0;
	open DIC, "dataset/dictionary_new_names_$cycle.txt" or die $!;
	while (<DIC>) {
		my $line = $_;
		$nr_new_names++;
	}
	close DIC;

}

print "Estabilizou....\n";
