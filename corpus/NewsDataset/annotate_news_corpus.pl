#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 13/10/2010
##
##	This script tries to make a exact match of the Proper Names lists extracted 
##		from REPENTINO and Verbatim with the dataset of news previously prepared
##		from the NewsCorpus database.
##	The annotated data is stored in annotated_news_corpus.txt file, where each
##		identified proper name is marked with the tag <PN>José Sócrates</PN> 
##
##
use strict;
use warnings;
use FileHandle;
use utf8;
binmode(STDOUT, ':utf8');

# Propor names
my %proper_names = ();


# Open Verbatim list
open (VERBATIMNAMES, "../Verbatim/proper_names_verbatim.txt") or die $!;
my $verbatim_counter = 0;
while (<VERBATIMNAMES>) {
	my $line = $_;
	$line =~ s/\n//s;
	$proper_names{$line}++;
	$verbatim_counter++;		
}
close (VERBATIMNAMES);
print("Verbatim names: $verbatim_counter\n\n");

my %names = ();
for (keys %proper_names) {
	$names{$_} = length($_);
}


# Open news dataset
open (DATASET, "big_dataset_news.txt") or die $!;

# Open annotated corpus file
open (FILENEWS, ">big_annotated_news_corpus.txt") or die $!;
# há caracteres marados no dataset, se forço a ser utf8 fica tudo marado...
#open (FILENEWS, ">:utf8", "annotated_news_corpus.txt") or die $!;

# Match DATASET with the list of proper names
my $title_counter = 0;
my $body_counter = 0;
my $line_counter = 0;
while (<DATASET>) {
	$line_counter++;
	warn("-> $line_counter\n");	
	my $line = $_;
	$line =~ /^(.+?)\t(.+?)\t(.+?)$/gs;
	my $news_id = $1;
	my $title = $2;
	my $body = $3;
	
	for (sort {$names{$b}<=>$names{$a}} keys %names) {
		my $proper_name = $_;
		
		$title =~ s/$proper_name/<PN>$proper_name<\/PN>/gs;
		$body =~ s/$proper_name/<PN>$proper_name<\/PN>/gs;
		
	}
	
	print FILENEWS $news_id . "\t" . $title . "\t" . $body . "\n";
	#warn("\n[$line_counter] TITLE: $title\n BODY: $body\n");
	
	if ($title =~ /<PN>/) {
		$title_counter++;		
	}
	if ($body =~ /<PN>/) {
		$body_counter++;
	}
	if ($title =~ /<PN>(.+?)<\/PN>/ || $body =~ /<PN>(.+?)<\/PN>/) {
		#warn("-> $1\n");
	}	
}
close (FILENEWS);

warn("\n\nTitle matches: $title_counter\nBody matches: $body_counter\n");