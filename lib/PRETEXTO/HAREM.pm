package PRETEXTO::HAREM;

use strict;
use warnings;
use utf8;
binmode(STDOUT, ':utf8');

sub new {
	shift;
  my $this = {};
     
  bless $this;
  return $this;
}



sub ProcessLineFromHAREM() {
	my $this = shift;
	my $line = shift || "";

	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL">(.+?)<\/EM>/__PN__$2__PN2__/s){
		print "\tR1: $2\n";
	}
	
	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="ident">(.+?)<\/EM>/__PN__$3__PN2__/s){
		print "\tR2: $3\n";
	}


	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="autor_de">(.+?)<\/EM>/__PN__$3__PN2__/s) {
		print "\tR3: $3\n";
	}

	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="participante_em">(.+?)<\/EM>/__PN__$3__PN2__/s) {
		print "\tR4: $3\n";
	}

	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="ter_participacao_de">(.+?)<\/EM>/__PN__$3__PN2__/s) {
		print "\tR5: $3\n";
	}

	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="vinculo_inst">(.+?)<\/EM>/__PN__$3__PN2__/s) {
		print "\tR6: $3\n";
	}

	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="incluido">(.+?)<\/EM>/__PN__$3__PN2__/s) {
		print "\tR7: $3\n";
	}

	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="relacao_familiar">(.+?)<\/EM>/__PN__$3__PN2__/s) {
		print "\tR8: $3\n";
	}

	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="natural_de">(.+?)<\/EM>/__PN__$3__PN2__/s) {
		print "\tR9: $3\n";
	}

	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="ident ident">(.+?)<\/EM>/__PN__$3__PN2__/s) {
		print "\tR10: $3\n";
	}

	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="ter_participacao_de praticante_de">(.+?)<\/EM>/__PN__$3__PN2__/s) {
		print "\tR11: $3\n";
	}
	
	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="ident vinculo_inst vinculo_inst" COMENT="(.+?)">(.+?)<\/EM>/__PN__$4__PN2__/s) {
		print "\tR12: $4\n";
	}

	while ($line =~ s/<(.+?)CATEG="PESSOA" TIPO="INDIVIDUAL" COREL="(.+?)" TIPOREL="relacao_profissional">(.+?)<\/EM>/__PN__$3__PN2__/s) {
		print "\tR13: $3\n";
	}
	
	# Finally clear all the other XML tags
	while ($line =~ /<(.+?)>(.+?)<(.+?)>/s) {
	#	print "----> $line\n";
		#if ($1 eq "PN") {next; }
		$line =~ s/<(.+?)>(.+?)<(.+?)>/$2/gs;
	#	print "++++> $line\n";
	}
	while ($line =~ /<(.+?)>/s) {
	#	print "----> $line\n";
		#if ($1 eq "PN" || $1 eq "/PN") {next; }
		$line =~ s/<(.+?)>//gs;
	#	print "++++> $line\n";
	}	

	$line =~ s/__PN__/<PN>/gs;
	$line =~ s/__PN2__/<\/PN>/gs;
	
	return $line;
}



1;


__END__

=head1 NAME

	Exporter

=head1 SYNOPSIS

	use PRETEXTO::HAREM;

=head1 DESCRIPTION

	This module ...

=head1 METHODS

=head2 new()

	Initialize the module
	

=head2 SetVerbose ()

	Method used to define the level of warnings.
	
=head2 Warn ()

	This method is used to release warning during the program execution accordingly
	to the verbose level previously defined.

=head1 SEE ALSO


=head1 AUTHOR

Jorge Teixeira, E<lt>jft@fe.up.ptE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Jorge Teixeira

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.


=cut