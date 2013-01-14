#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 25/10/2010
##
##	This script annotate the dataset of news with initial dictioanry of names
##		plus all the new names identified on each iteration
##
##
use strict;
use warnings;
use PRETEXTO::Tools;
use LSP::Utils;
use utf8;
binmode(STDOUT, ':utf8');
my $tools = PRETEXTO::Tools->new();
my $lsp = LSP::Utils->new();


## CYCLE
my $cycle = shift || 0;



## Load initial dictionary of names
warn("Loading dictionary of names...\n");
my %dictionary = ();
open DICTIONARY, "dataset/dictionary_names_0.txt" or die $!;
print "Loading dataset/dictionary_names_0.txt\n";
while (<DICTIONARY>) {
	my $line = $_;
	$line =~ /^(.+?)\t(.+?)$/;
	$line = $tools->SetStringToUtf8($line);
	$dictionary{$1} = $2;
}
close DICTIONARY;


## Load new dictionaries of names
if ($cycle > 0) {
	for (my $ii = 1; $ii <= $cycle; $ii++) {
		my $path_new_dictionary = "dataset/dictionary_new_names_" . $ii . ".txt";
		print "Loading dataset/dictionary_names_$ii.txt\n";
		
		## Add new names to %dictionary
		open NEW_DIC, $path_new_dictionary or die $!;
		while (<NEW_DIC>) {
			my $line = $_;
			$line =~ /^(.+?)\t(.+?)$/;
			$line = $tools->SetStringToUtf8($line);
			$dictionary{$1} = $2;
		}
		close NEW_DIC;
			
	}	
}



## Prepare output file
warn("Creating 'dataset/annotated_dataset_news_$cycle.txt' ...\n");
my $path_annotated_dataset = "dataset/annotated_dataset_news_" . $cycle . ".txt";
open ANNOTATED_DATASET, ">:utf8", $path_annotated_dataset or die $!;



my $counter = 0;
## Open dataset of news
open DATASET, "dataset/news_dataset.txt" or die $!;
my $identified_complete_names_on_title = 0;
my $identified_complete_names_on_content = 0;
while (<DATASET>) {
	my $line = $_;
	$line =~ /^(.+?)\t(.+?)\t(.+?)$/;
	my $id = $1;
	my $title = $2;
	$title = $lsp->TokenizeString($title);
	my $content = $3;
	$content = $lsp->TokenizeString($content);
	for (sort { $dictionary{$b} <=> $dictionary{$a}} keys %dictionary) {
		my $name = $_; 
				
		## TITLE ( this (^|\s|«|“)$name($|\s|»|”) is because of tokenization misses)
		while ($title =~ /(^|\s|«|“|''|"|\.|,)$name($|\s|»|”|\.|,|''|")/ && $title !~ /<PN>$name<\/PN>/) {
			
			# Prepare string with annotated name
			my @words = split(' ', $name);
			my $string = "";
			for (@words) {
				$string .= "<PN>$_</PN> ";	
			}
			$string =~ s/ $//;			
			$title =~ s/(^|\s|«|“|''|"|\.|,)$name($|\s|»|”|\.|,|''|")/$1$string$2/g;
			#print "NAME: $name -> $string\nTITLE: $title\n\n";
			$identified_complete_names_on_title++;
		}

		## CONTENT ( this (^|\s|«|“)$name($|\s|»|”) is because of tokenization misses)
		while ($content =~ /(^|\s|«|“|''|"|\.|,)$name($|\s|»|”|\.|,|''|")/ && $content !~ /<PN>$name<\/PN>/) {	
			
			# Prepare string with annotated name
			my @words = split(' ', $name);
			my $string = "";
			for (@words) {
				$string .= "<PN>$_</PN> ";	
			}
			$string =~ s/ $//;			
			$content =~ s/(^|\s|«|“|''|"|\.|,)$name($|\s|»|”|\.|,|''|")/$1$string$2/g;
			#print "NAME: $name -> $string\nCONTENT: $content\n\n";
			$identified_complete_names_on_content++;
		}


	}
	$counter++;
	if ($counter % 50 eq 0) {
		warn "Processing news $counter...\n";
	}
	if ($counter > 1001) {
		#last;
	}
	$title = $tools->SetStringToUtf8($title);
	$content = $tools->SetStringToUtf8($content);
	print ANNOTATED_DATASET $id . "\t" . $title . "\t" . $content . "\n";
}
close DATASET;
close ANNOTATED_DATASET;

print "\nIDENTIFIED $identified_complete_names_on_content complete names on content...\n";
print "IDENTIFIED $identified_complete_names_on_title complete names on title...\n";

