#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 06/10/2010
##
##	This script 
##
##
use strict;
use warnings;
use FileHandle;
use Encode;


## Open REPENTINO xml file
my $fh = new FileHandle();
my $filename = "repentino.xml";
if (!$fh->open("$filename")) {
	die("Could not open '$filename'\n");
}

## Open output list
my $fh2 = new FileHandle();
my $filename2 = ">proper_names_repentino.txt";
if (!$fh2->open("$filename2")) {
    die("Could not open '$filename2'\n");
}

my %senders = ();
while (!$fh->eof()) {
	my $line = $fh->getline();
	my $proper_name = "";

	#warn("=> $line\n");
	if ($line =~ /<EN_SER subcat=\"HUM\"\>(.+?)<\/EN_SER>/s) {
		my $proper_name = $1;
		Encode::from_to($proper_name, "iso-8859-1", "utf8");
		#warn("-> $proper_name\n");
		#$fh2->print($proper_name . "\n");
		
		$senders{$proper_name} = length($proper_name);
	}
	
}


## Open output list
open (FILE, ">proper_names_repentino.txt") or die $!;
for (sort {$senders{$b} <=> $senders{$a}} keys %senders ) {
	print FILE $_ . "\n";
}
close (FILE);
