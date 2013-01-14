package PRETEXTO::WSClients;

use strict;
use warnings;
use LWP::Simple;
use JSON;
use utf8;


sub new {
	shift;
  my $this = {};
     
	$this->{verbose} = 1;     
     
  bless $this;
  return $this;
}


sub GetWordsFromList {
	my $this = shift;
	my $list_tag = shift || "";
	my $list_sub_tag = shift || "";
	my %output = ();  
	
	my $ws_response = "";
	if ($list_tag eq "" && $list_sub_tag eq "") {
		return 0;
	}
	elsif ($list_sub_tag eq "") {
		$ws_response = get("http://services.sapo.pt/InformationRetrieval/SemanticLists/GetWords?tag=$list_tag");
	} 
	else {
		$ws_response = get("http://services.sapo.pt/InformationRetrieval/SemanticLists/GetWords?tag=$list_tag&subtag=$list_sub_tag");	
	}
	
	# '{"verbetes":[{"jobs":[{"lastSeen":"2011-03-03","num":"6","ergo":"escritor","active":"yes","firstSeen":"2009-10-09"}],"officialName":"José Saramago","status":"dead","alternativeNames":["Saramago"]}]}'
	my $json_struct = decode_json($ws_response);
	my %info = %{$json_struct};
	my %words = %{$info{words}};
	for (keys %words) {
		#print "$_\n";
		$output{$_}++;
		
		# extract alternative names from the countries list
		if ($list_tag eq "cnt") {
			my %alternatives = %{$words{$_}};
			for (keys %alternatives) {
				if ($_ =~ /alternative/) {
					#print "\t$_ -> $alternatives{$_}\n";
					$output{$alternatives{$_}}++;					
				}
			}
		}
	}
	
	return \%output;
}


sub GetErgosFromVerbetes {
	my $this = shift;
	my $threshold = shift || 2;
	my %output = ();
	
	my $ws_response = get("http://services.sapo.pt/InformationRetrieval/Verbetes/GetErgos?min=$threshold");
	
	if ($ws_response =~ /Request timed out/) {
		warn("Request timeout... try a higher 'min' value.\n");
		return 0;
	}
	
	# '{ "listErgos":{"presidente": 12558,"ministro": 3115,...,"vendedora": 2}}
	my $json_struct = decode_json($ws_response);
	my %info = %{$json_struct};
	my %words = %{$info{listErgos}};
	for (keys %words) {
		#print "$_\n";
		$output{$_}++;	
	}
	
	return \%output;
}


sub GetNamesFromVerbetes {
	my $this = shift;
	my $threshold = shift || 2;
	my %output = ();
	
	my $ws_response = get("http://services.sapo.pt/InformationRetrieval/Verbetes/GetPersonalities");
	
	if ($ws_response =~ /Request timed out/) {
		warn("Request timeout... try a higher 'min' value.\n");
		return 0;
	}
	
	# '{ "listPersonalities":{"José Eduardo Matos":10,"João Semedo":79,...,"José Mota":28}}
	my $json_struct = decode_json($ws_response);
	my %info = %{$json_struct};
	my %words = %{$info{listPersonalities}};
	for (keys %words) {
		#print "$_\n";
		$output{$_}++;	
	}
	
	return \%output;
}


sub SetVerbose() {
	my $this = shift;
  $this->{verbose} = shift || 0;
}


sub Warn() {
  my $this = shift;
  my $message = shift;
  my $min_verbose = shift || 1;

  if ($this->{verbose} < $min_verbose) {
    return;
  }
  ## Caller Info
  my ($package, $filename, $line, $subroutine, 
      $hasargs, $wantarray, $evaltext, $is_require) = caller(1);
  
  ## Time Info
  my ($sec, $min, $hour, $mday, $mon, 
      $year, $wday, $yday, $isdst) = localtime(time());
  if ($sec < 10) {
    $sec = "0" . $sec;
  }
  if ($min < 10) {
    $min = "0" . $min;
  }
  
  warn($hour . ":" . $min . ":" . $sec . " $subroutine($line) - $message\n");
}

1;


__END__

=head1 NAME

	WSClients

=head1 SYNOPSIS

	use PRETEXTO::WSClients;

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

Copyright (C) 2011 by Jorge Teixeira

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.


=cut
