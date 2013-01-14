#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 25/04/2011
##
##	This script creates a text file based on the NewsCorpus database.
##		This file has a structure like where news are separated by newline and
##			items of each news separated by tab:
##			"news_id1		title1		body1
##			"news_id2		title2		body2"
##
##	It creates a test set of the last 20,000 news items
##
use strict;
use warnings;
use DBI;
use utf8;
binmode(STDOUT, ':utf8');


## Set DBI
my $db = "verbatim";
my $host = "10.135.67.168";
my $dbi = DBI->connect("DBI:mysql:database=$db;$host;timeout=240",
											 "verbatim_reader", 
											 "verbatim_reader_pass", 
											 {mysql_enable_utf8=>1});
											 
sub ExecuteSQL($) {
  my $q = shift;  
  ## Trim, prepare and execute a querie
  while ($q=~s/^\s//g) {}
  ##warn("Preparing '$q'\n");
  my $sth = $dbi->prepare($q);
  if (defined($sth)) { 
    $sth->execute(); 
  } else { 
    warn ("Problems with: ". $q ."\n"); 
  }

  ## Fetch results in case of a select into an array and return
  if ($q!~/^SELECT/i) {
    return;
  }
  my @tuples = ();
  	while (my $hashRef = $sth->fetchrow_hashref()) { 
  	  push (@tuples, $hashRef);
  }
  return @tuples;
}											   

## Prepare dataset file
open TESTSET, ">:utf8", "dataset/news_dataset.txt";


## Latest 1000 news
my $q = "SELECT id, title, content FROM news GROUP BY content ORDER BY id DESC LIMIT 100000";
my @tuples = ExecuteSQL($q);
for (@tuples) {
	my %news_info = %{$_};
	
	my $id = $news_info{id};
	my $title = $news_info{title};
	my $content = $news_info{content};
	
	print TESTSET $id . "\t" . $title . "\t" . $content . "\n";
}

close TESTSET;