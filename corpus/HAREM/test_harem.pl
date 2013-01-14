#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 13/10/2010
##
##	This script t
##
##
use strict;
use warnings;
use FileHandle;
use utf8;
binmode(STDOUT, ':utf8');


sub ProcessLine($) {
	my $line = shift;
	my @output_list = ();
	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL">(.+?)<\/EM>//s){
		push(@output_list, $1);
	}
	
	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="ident">(.+?)<\/EM>//s){
		#print "-> " . $2 . "\n";
		push(@output_list, $2);
	}


	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="autor_de">(.+?)<\/EM>//s) {
		#print "-> " . $2 . "\n";
		push(@output_list, $2);
	}

	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="participante_em">(.+?)<\/EM>//s) {
		#print "-> " . $2 . "\n";
		push(@output_list, $2);
	}

	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="ter_participacao_de">(.+?)<\/EM>//s) {
		#print "-> " . $2 . "\n";
		push(@output_list, $2);
	}

	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="vinculo_inst">(.+?)<\/EM>//s) {
		#print "-> " . $2 . "\n";
		push(@output_list, $2);
	}

	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="incluido">(.+?)<\/EM>//s) {
		#print "-> " . $2 . "\n";
		push(@output_list, $2);
	}

	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="relacao_familiar">(.+?)<\/EM>//s) {
		#print "-> " . $2 . "\n";
		push(@output_list, $2);
	}

	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="natural_de">(.+?)<\/EM>//s) {
		#print "-> " . $2 . "\n";
		push(@output_list, $2);
	}

	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="ident ident">(.+?)<\/EM>//s) {
		#print "-> " . $2 . "\n";
		push(@output_list, $2);
	}

	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="ter_participacao_de praticante_de">(.+?)<\/EM>//s) {
		#print "-> " . $2 . "\n";
		push(@output_list, $2);
	}
	
	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="ident vinculo_inst vinculo_inst" COMENT="(.+?)">(.+?)<\/EM>//s) {
		#print "-> " . $3 . "\n";
		push(@output_list, $3);
	}	

	while ($line =~ s/CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="relacao_profissional">(.+?)<\/EM>//s) {
		print "-> " . $2 . "\n";
		push(@output_list, $2);
	}	

	return @output_list;
}


# Open ListHAREM names file
open (HAREMNAMES, ">:utf8" ,"HAREM_names.txt") or die $!;


# Open HAREM
open (FILE, "HAREM.xml") or die $!;
my $counter = 0;
my %names = ();
while (<FILE>) {
	my $line = $_;
	$line =~ s/\n//s;
	my @names = ProcessLine($line);
	if (scalar(@names) eq 0) {
		next;
	} else {
		for (@names) {
			$names{$_}++;
			$counter++;			
		}
	}
}
close (FILE);


# Print HAREM names ordered by length
for (sort keys %names) {
			print HAREMNAMES $_ . "\t" . $names{$_} . "\n";
#			print $_ . "\n";
}


print "Found $counter names on HAREM.\n";