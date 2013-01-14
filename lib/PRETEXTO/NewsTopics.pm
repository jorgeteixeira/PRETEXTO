package PRETEXTO::NewsTopics;

use strict;
use warnings;
use PRETEXTO::DBI;
use utf8;


sub new {
	shift;
  my $this = {};
     
	$this->{verbose} = 1;
	$this->{dbi} = PRETEXTO::DBI->new();
	$this->{dbi}->ConnectToHost("*", "*", "*", "*");     
     
  bless $this;
  return $this;
}


sub Get1TokenTopics {
	my $this = shift;
	my $threshold = shift || 200;
	my %output = ();
	
	my $q = "SELECT * 
						FROM indexes_1_token 
						WHERE 
							frequency > $threshold AND 
							length(token) > 2";

	for ( $this->{dbi}->ExecuteSQL($q) ) {
		my %hash = %{$_};
		# avoid for example 'at.'
		if ($hash{token} =~ /\./) { next; }
		$output{$hash{token}} = $hash{frequency};
	}
	
	return \%output;
}


sub Get2TokensTopics {
	my $this = shift;
	my $threshold = shift || 200;
	my %output = ();
	
	my $q = "SELECT * 
						FROM indexes_2_tokens 
						WHERE 
							frequency > $threshold";

	for ( $this->{dbi}->ExecuteSQL($q) ) {
		my %hash = %{$_};
		
		# first token should not start with lower case: avoid 'de Frankfurt'
		# second token should not start with lower case: avoid 'América do'
		if ( $hash{token} =~ /^[a-záàãâéèêíìîóòõôúùû]/ || 
				 $hash{token} =~ /^(.+?) [a-záàãâéèêíìîóòõôúùû]/ ) {
			next;
		}
		$output{$hash{token}} = $hash{frequency};
	}
	
	return \%output;
}


sub Get3TokensTopics {
	my $this = shift;
	my $threshold = shift || 20;
	my %output = ();
	
	my $q = "SELECT * 
						FROM indexes_3_tokens 
						WHERE 
							frequency > $threshold";

	for ( $this->{dbi}->ExecuteSQL($q) ) {
		my %hash = %{$_};
		
		# first token should not start with lower case: avoid 'anos na Europa'
		# third token should have more than 2 letters: avoid 'Dia Mundial do'
		if ( $hash{token} =~ /^[a-záàãâéèêíìîóòõôúùû]/ || 
				 $hash{token} =~ /^(.+?) (.+?) \w{1,2}$/ ) {
			next;
		}		
		$output{$hash{token}} = $hash{frequency};
	}
	
	return \%output;
}



sub GetPlaces {
	my $this = shift;
	my $threshold = shift || 5;
	my %output = ();
	
	my $q = "SELECT 
						tag, count(*) as num 
					 FROM tags 
					 WHERE 
					 	type = \"GEO_LABEL\" 
					 GROUP BY tag 
					 HAVING num > $threshold 
					 ORDER BY num DESC";

	for ( $this->{dbi}->ExecuteSQL($q) ) {
		my %hash = %{$_};
		$output{$hash{tag}} = $hash{num};
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

	NewsTopics

=head1 SYNOPSIS

	use PRETEXTO::NewsTopics;

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
