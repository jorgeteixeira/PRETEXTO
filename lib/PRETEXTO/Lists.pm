package PRETEXTO::Lists;

use strict;
use warnings;
use PRETEXTO::WSClients;
use PRETEXTO::Tools;
use PRETEXTO::NewsTopics;
use LWP::Simple;
use JSON;
use utf8;
binmode(STDOUT, ':utf8');


sub new {
	shift;
  my $this = {};
     
	$this->{verbose} = 1;
  $this->{tools} = PRETEXTO::Tools->new(); 
  $this->{news_topics} = PRETEXTO::NewsTopics->new();   
     
  bless $this;
  return $this;
}


sub Init {
	my $this = shift;
	
	warn "Loading Lists...\n";
	
	my $ws_client = PRETEXTO::WSClients->new();
	our %events_list = %{$ws_client->GetWordsFromList("evt")};
	our %countries_list = %{$ws_client->GetWordsFromList("cnt")};
	our %communication_verbs_list = %{$ws_client->GetWordsFromList("com")};
	our %ergos_list = %{$ws_client->GetWordsFromList("erg")};
	our %roles_list = %{$ws_client->GetWordsFromList("rol")};
	our %geographic_list = %{$ws_client->GetWordsFromList("geo")};
	our %human_info_list = %{$ws_client->GetWordsFromList("hmn")};	
	our %weekdays_list = %{$ws_client->GetWordsFromList("wkd")};
	our %months_list = %{$ws_client->GetWordsFromList("mth")};
	our %nacionalities_list = %{$ws_client->GetWordsFromList("nat")};
	our %indexes_list = %{$ws_client->GetWordsFromList("nmx")};
	our %organizations_list = %{$ws_client->GetWordsFromList("org")};
	our %places_list = %{$ws_client->GetWordsFromList("plc")};
	our %publications_list = %{$ws_client->GetWordsFromList("pub")};
	our %journals_list = %{$ws_client->GetWordsFromList("pube")};
	our %human_relations_list = %{$ws_client->GetWordsFromList("rel")};
	our %currency_list = %{$ws_client->GetWordsFromList("uni")};	
	our %verbetes_ergos = %{$ws_client->GetErgosFromVerbetes()};
	our %verbetes_names = %{$ws_client->GetNamesFromVerbetes()};
	our %repentino_names = %{$this->PrepareRepentinoNames()};	
	my %news_topics_1_token = %{$this->{news_topics}->Get1TokenTopics()};
	my %news_topics_2_tokens = %{$this->{news_topics}->Get2TokensTopics()};
	my %news_topics_3_tokens = %{$this->{news_topics}->Get3TokensTopics()};
	our %news_topics = (%news_topics_1_token, %news_topics_2_tokens, %news_topics_3_tokens);
	our %places = %{$this->{news_topics}->GetPlaces()};

	warn "Lists loaded...\n";
}


sub PrepareRepentinoNames {
	my $this = shift;
	my $path = shift || "corpus/REPENTINO/proper_names_repentino.txt";
	my $threshold = shift || 200;
	
	my %names = ();
	my %tmp = ();
	open (FILE, $path) or die $!;
	while (<FILE>) {
		my $line = $this->{tools}->SetStringToUtf8($_);
		my @tokens = split(' ', $line);
		for (@tokens) {
			my $token = $_;
			
			# only characters
			if ($token =~ /\W/) {
				next;
			}
			
			# only tokens with 3 or more characters
			if ($token =~ /^\w{1,3}$/) {
				next;
			}
			
			# only capitalized tokens
			if ($token !~ /^[A-ZÁÀÃÂÉÈÊÍÌÎÓÒÔÕÚÙÛ]/) {
				next;
			}			
			 			
			$tmp{$token}++;
		}
	}
	
	for (sort { $tmp{$b} <=> $tmp{$a} } keys %tmp) {
		if ( $tmp{$_} > $threshold ) {
			$names{$_} = $tmp{$_};
			#warn $_ . " -> " . $tmp{$_} . "\n";
		}
	}
	#warn(scalar(keys %names) . " names loaded\n");
	
	return \%names;
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

	use PRETEXTO::Lists;

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
