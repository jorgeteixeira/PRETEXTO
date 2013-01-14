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


## CYCLE
my $cycle = shift || 0;

## Test data with CRF model 2 
# -n 1 => only one test 
#
# models/0.model => CRF model
# models/dataset_0.crf => testset to test... is our dataset of news (the 'previous' one), formated to CRF structure
#	tests/test_0.txt => output file, also in CRF structure
#
my $system_call = "crf_test -v1 -n 1 -m models/" . $cycle . ".model models/dataset_" . $cycle . ".crf > tests/test_" . $cycle . ".txt";
print $system_call . "\n";
system($system_call);

