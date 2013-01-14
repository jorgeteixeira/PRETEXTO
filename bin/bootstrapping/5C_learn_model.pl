#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 25/04/2011
##
##	This script creates a CRF learning model based on the dataset (formated 
##		with the CRF++ structure)
##
##
use strict;
use warnings;


## CYCLE
my $cycle = shift || 0;


## -m 50 -> 50 iterations at max
## -p 2 -> 2 threads
## -e 0.009 -> termination creterion set to 0.009
## -H 10 -> 10 iterations to achieve optimal result before shrinking
##
## crf_learn [optional parameters] [template] [training_data] [output_model]
my $system_call = "crf_learn -m 50 templates/template_crf.txt models/dataset_" . $cycle . ".crf models/" . $cycle . ".model";
print $system_call . "\n";
system($system_call);