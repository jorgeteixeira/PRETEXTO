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
use PRETEXTO::Lists;
use utf8;
binmode(STDOUT, ':utf8');


my $lists = PRETEXTO::Lists->new();
$lists = PRETEXTO::Lists->Init();

warn "EVENTS:\n";
for (keys %PRETEXTO::Lists::events_list) {
	warn "\t" . $_ . "\n";
}

warn "COUNTRIES:\n";
for (keys %PRETEXTO::Lists::countries_list) {
	print "\t" . $_ . "\n";
}

warn "COMMUNICATION VERBS:\n";
for (keys %PRETEXTO::Lists::communication_verbs_list) {
	print "\t" . $_ . "\n";
}

warn "ERGOS:\n";
for (keys %PRETEXTO::Lists::ergos_list) {
	print "\t" . $_ . "\n";
}

warn "ROLES:\n";
for (keys %PRETEXTO::Lists::roles_list) {
	print "\t" . $_ . "\n";
}

warn "GEOGRAPHIC:\n";
for (keys %PRETEXTO::Lists::geographic_list) {
	print "\t" . $_ . "\n";
}

warn "HUMAN INFO:\n";
for (keys %PRETEXTO::Lists::human_info_list) {
	print "\t" . $_ . "\n";
}

warn "WEEKDAYS:\n";
for (keys %PRETEXTO::Lists::weekdays_list) {
	print "\t" . $_ . "\n";
}

warn "MONTHS:\n";
for (keys %PRETEXTO::Lists::months_list) {
	print "\t" . $_ . "\n";
}

warn "NATIONALITIES:\n";
for (keys %PRETEXTO::Lists::nacionalities_list) {
	print "\t" . $_ . "\n";
}

warn "INDEXES:\n";
for (keys %PRETEXTO::Lists::indexes_list) {
	print "\t" . $_ . "\n";
}

warn "ORGANIZATIONS:\n";
for (keys %PRETEXTO::Lists::organizations_list) {
	print "\t" . $_ . "\n";
}

warn "PLACES:\n";
for (keys %PRETEXTO::Lists::places_list) {
	print "\t" . $_ . "\n";
}

warn "PUBLICATIONS:\n";
for (keys %PRETEXTO::Lists::publications_list) {
	print "\t" . $_ . "\n";
}

warn "JOURNALS:\n";
for (keys %PRETEXTO::Lists::journals_list) {
	print "\t" . $_ . "\n";
}

warn "HUMAN RELATIONS:\n";
for (keys %PRETEXTO::Lists::human_relations_list) {
	print "\t" . $_ . "\n";
}

warn "CURRENCY:\n";
for (keys %PRETEXTO::Lists::currency_list) {
	print "\t" . $_ . "\n";
}
