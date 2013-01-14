#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 13/10/2010
##
##	This script selects 100 random annotated news from the big set of news.
##	Its objective is to evaluate the quality of the automatic annotation.
##
##
use strict;
use warnings;
use FileHandle;
use utf8;
binmode(STDOUT, ':utf8');

# Propor names
my %proper_names = ();


# Open random set of news
open (RANDOMNEWS, ">random_set_news.txt") or die $!;

# Open News Dataset
my @list_news = ();
open (NEWSSET, "big_annotated_news_corpus.txt") or die $!;
while (<NEWSSET>) {
	#print $_ . "\n";
	push(@list_news, $_);
}

my $nr_analysis = int(scalar(@list_news) / 200);
my $ii = 0;
my %indexes = ();
while ($ii <= $nr_analysis) {
	my $index = int(rand(scalar(@list_news)));
	if(!defined($indexes{$index}) && $list_news[$index] =~ /^\d/) {
		$indexes{$index}++;
		
		$list_news[$index] =~ /^(.+?)\t(.+?)\t(.+?)$/;
		my $index = $1;
		my $annotated_title = $2 || "";
		my $annotated_body = $3 || "";
		my $title = $annotated_title;
		my $body = $annotated_body;

		my $output = "";
		while ($title =~ s/<PN>(.+?)<\/PN>//) {
			$output .= $1 . "\t";
		}
		while ($body =~ s/<PN>(.+?)<\/PN>//) {
			$output .= $1 . "\t";
		}

		if ($output ne "" && length($body) < 500) {
			$ii++;
			print RANDOMNEWS "$index\t$annotated_title\t$annotated_body\n\t->$output\n\n";
			print $index . "\n";
		}
		
		
	}
}

#warn "$ii notícias para avaliar\n";

