#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 13/10/2010
##
##	This script creates a text file based on the NewsCorpus database.
##		This file has a structure like where news are separated by newline and
##			items of each news separated by tab:
##			"news_id1		title1		body1
##			"news_id2		title2		body2"
##
##
use strict;
use warnings;
use PRETEXTO::DBI;

## Set DBI
my $dbi = new PRETEXTO::DBI();
$dbi->ConnectToHost();
$dbi->SetVerbose(1);


## Download dataset
my $dataset_ref = $dbi->DownloadDataset();

## Build news dataset
$dbi->WriteDatasetToFile($dataset_ref, "");