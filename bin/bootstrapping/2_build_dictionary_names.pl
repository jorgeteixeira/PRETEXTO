#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 25/04/2011
##
##	This script creates a dictionary with the most frequent names extracted from
##		Verbetes web-service (http://services.sapo.pt/InformationRetrievel/Verbetes)
##	It creates a test set of the last 20,000 news items
##
use strict;
use warnings;
use LWP::Simple;
use PRETEXTO::Tools;
use utf8;
binmode(STDOUT, ':utf8');

my $tools = PRETEXTO::Tools->new();
my $threshold = shift || 3;


## Request list of names
my $ws_response = get("http://services.sapo.pt/InformationRetrieval/Verbetes/GetPersonalities?min=$threshold");
$ws_response = $tools->SetStringToUtf8($ws_response);
print $ws_response . "\n";



## Prepare dictionary of names
my %dictionary = ();



## Parse JSON (output from web-serve)
$ws_response =~ s/\{ \"listPersonalities\"\:\{//;

# each element: "Teixeira dos Santos": 263,
while ($ws_response =~ s/\"(.+?)\": (.+?),//) {
	$dictionary{$1} = $2;
}

# last part: "Moniz Pereira": 5}}
$ws_response =~ s/\"(.+?)\": (.+?)\}\}//;
$dictionary{$1} = $2;




## Print dictionary to file
open DICTIONARY, ">:utf8", "dataset/dictionary_names_0.txt";
for (sort { $dictionary{$b} <=> $dictionary{$a}} keys %dictionary) {
	print "$_ -> $dictionary{$_}\n";
	print DICTIONARY "$_\t$dictionary{$_}\n";
}
close DICTIONARY;

