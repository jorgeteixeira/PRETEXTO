#!/usr/bin/perl
##
## Authors: Jorge Teixeira
##
## Creation data: 28/10/2011
##
##	This script tests the call and decoding of a WS from SemanticLists
##	
use strict;
use warnings;
use PRETEXTO::FeaturesGenerator;
use utf8;
binmode(STDOUT, ':utf8');


my $text = shift || "";

my $fgenerator = PRETEXTO::FeaturesGenerator->new();
$fgenerator->GenerateFeaturesFromText($text);