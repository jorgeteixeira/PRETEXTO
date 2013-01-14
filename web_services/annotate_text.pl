#!/usr/bin/perl
##
## Authors: Jorge Teixeira
##
## Creation data: 07/11/2011
##
##	Description:
##
##		This is a REST web-service (POST) server-side script.
##		This web-service returns the egocentric network of a given personality for a 
##		specific time interval. This egocentric network can has depth 1, 1.5 or 2				
##
##
##	Who to call this method:
##
##		/cgi-bin/NER/annotate_text.pl?text='..' (POST)
##
##
use strict;
use warnings;
use CGI;
use PRETEXTO::WS::Server;
use Encode;
use utf8;
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');


## Initializations
my $query = CGI->new();	
$query->charset('UTF-8');
my $server = PRETEXTO::WS::Server->new();


## Input parameters
my $input_text = $query->param('text') || "";
my $format = $query->param('format') || "json"; 
$input_text = Encode::decode('utf8', $input_text);


## Prepare header
if ($format eq "json") {
	print($query->header(-type => "application/json; charset=utf-8"));
}
if ($format eq "xml") {
	print($query->header(-type => "application/xml; charset=utf-8"));
}


## Prepare output
print $server->AnnotateText($input_text, $format);	
