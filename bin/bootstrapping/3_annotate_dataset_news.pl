#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 25/10/2010
##
##	This script annotate the dataset of news with the dictioanry of names
##		Used only in the first iteration of bootstrapping method.
##
##
use strict;
use warnings;
use PRETEXTO::Tools;
use utf8;
binmode(STDOUT, ':utf8');
my $tools = PRETEXTO::Tools->new();



## Load dictionary of names
my %dictionary = ();
open DICTIONARY, "dataset/dictionary_names_0.txt" or die $!;
while (<DICTIONARY>) {
	my $line = $_;
	$line =~ /^(.+?)\t(.+?)$/;
	$dictionary{$1} = $2;
}




## Prepare output file
open ANNOTATED_DATASET, ">:utf8", "dataset/annotated_dataset_news_0.txt" or die $!;



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
	my $content = $3;
	
	for (sort { $dictionary{$b} <=> $dictionary{$a}} keys %dictionary) {
		my $name = $_; 
				
		## TITLE 
		while ($title =~ /$name/) {
			
			# Prepare string with annotated name
			my @words = split(' ', $name);
			my $string = "";
			for (@words) {
				$string .= "<PN>$_</PN> ";	
			}
			$string =~ s/ $//;			
			$title =~ s/$name/$string/;
			#print "NAME: $name -> $string\nTITLE: $title\n\n";
			$identified_complete_names_on_title++;
		}

		## CONTENT
		while ($content =~ /$name/) {
			
			# Prepare string with annotated name
			my @words = split(' ', $name);
			my $string = "";
			for (@words) {
				$string .= "<PN>$_</PN> ";	
			}
			$string =~ s/ $//;			
			$content =~ s/$name/$string/;
			#print "NAME: $name -> $string\nCONTENT: $content\n\n";
			$identified_complete_names_on_content++;
		}


	}
	$counter++;
	if ($counter % 50 eq 0) {
		print "Processing news $counter of 20,000...\n";
	}
	if ($counter > 101) {
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

