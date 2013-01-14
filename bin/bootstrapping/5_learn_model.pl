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

## -m 50 -> 50 iterations at max
## -p 2 -> 2 threads
## -e 0.009 -> termination creterion set to 0.009
## -H 10 -> 10 iterations to achieve optimal result before shrinking
##
## crf_learn [optional parameters] [template] [training_data] [output_model]
system("crf_learn -m 100 templates/template_crf.txt models/dataset_0.crf models/0.model");