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
open (REPENTINOXML, "repentino.xml") or die $!;


## Open output list
my $fh2 = new FileHandle();
open (REPENTINO, ">repentino.txt") or die $!;



my %senders = ();
while (<REPENTINOXML>) {
	my $line = $_;
	my $proper_name = "";

	#warn("=> $line\n");
	if ($line =~ /<EN_SER subcat=\"HUM\"\>(.+?)<\/EN_SER>/s) {
		my $proper_name = $1;
		Encode::from_to($proper_name, "iso-8859-1", "utf8");		
		my @tokens = split(' ', $proper_name);
		for (@tokens) {
			$senders{$_}++;
		}
	}
}


for (sort keys %senders ) {
	if (length($_) < 3 || $_ =~ /^\(|\.|\&|\d|\'/) {
		next;
	}
	my $token = lc($_);
	print REPENTINO $token . "\n";
	warn($token . "\n");
}
close (REPENTINO);
