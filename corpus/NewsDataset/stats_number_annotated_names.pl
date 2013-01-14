#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 13/10/2010
##
##	This script returns the number of annotated names. (for example, 
##		<PN>José Sócrates</PN> counts for one) 
##
##
use strict;
use warnings;
use FileHandle;
use utf8;
binmode(STDOUT, ':utf8');

# Propor names
my $counter = 0;
my %names = ();

# Open Verbatim list
open (CORPUS, "big_annotated_news_corpus.txt") or die $!;
while (<CORPUS>) {
	my $line = $_;
	while ($line =~ s/<PN>(.+?)<\/PN>//g) {
		$counter++;
		$names{$1}++;
	}
}
close (CORPUS);

print "\nNumber annotated names (instances): $counter\n";
print "\nNumber annotated names: " . scalar(keys %names) . "\n";