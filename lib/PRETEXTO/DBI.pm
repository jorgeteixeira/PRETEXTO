package PRETEXTO::DBI;

use strict;
use warnings;
use DBI;
use FileHandle;
use utf8;
binmode(STDOUT, ':utf8');

sub new {
	shift;
  my $this = {};
  $this->{dbi} = "";
     
  bless $this;
  return $this;
}


sub ConnectToHost() {
  my $this = shift;
  
	my $db = shift || "";
	my $host = shift || "";
	my $user = shift || "";
	my $pass = shift || "";
	$this->{dbi} = DBI->connect("DBI:mysql:database=$db;$host;timeout=240",
															$user, 
															$pass, 
															{mysql_enable_utf8=>1});  
	
}


sub ExecuteSQL($) {
  my $this = shift;
  my $q = shift;  
  ## Trim, prepare and execute a querie
  while ($q=~s/^\s//g) {}
  ##warn("Preparing '$q'\n");
  my $sth = $this->{dbi}->prepare($q);
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


sub DownloadDataset () {
	my $this = shift;
	
	my $q = "SELECT news_id, title, body FROM evaluation_tags_dataset";
	my @tuples = $this->ExecuteSQL($q);
	for (@tuples) {
		my %news_info = %{$_};
		
		my $news_id = $news_info{news_id};
		my $title = $news_info{title};
		my $body = $news_info{body};
	}
	
	return \@tuples;
}


sub DownloadBigDataset () {
	my $this = shift;
	my $limit = shift || 2000;
	
	my $q = "SELECT id, title, content FROM news_cleanup limit 300000,$limit";
	my @tuples = $this->ExecuteSQL($q);
	
	return \@tuples;
}


sub WriteDatasetToFile () {
	my $this = shift;
	my $ref = shift || "";
	my $path = shift || ""; 
	
	# Open dataset file
	my $fh = new FileHandle();
	my $filename = "dataset_news.txt";
	if (!$fh->open(">$filename")) {
		die("Could not open '$filename'\n");
	}	
	
	my @tuples = @{$ref};
	for (@tuples) {
		my %news_info = %{$_};
		
		my $news_id = $news_info{news_id};
		my $title = $news_info{title};
		my $body = $news_info{body};
		
		$fh->print($news_id . "\t" . $title . "\t" . $body . "\n");
	}
	
	return 1;	
}


sub WriteBigDatasetToFile () {
	my $this = shift;
	my $ref = shift || ""; 
	
	# Open dataset file
	open (DATASET, ">:utf8", "big_dataset_news.txt") or die $!;
	
	my @tuples = @{$ref};
	for (@tuples) {
		my %news_info = %{$_};
		
		my $id = $news_info{id};
		my $title = $news_info{title};
		my $content = $news_info{content};
		$content =~ s/\n{1,}//g;
		
		print DATASET $id . "\t" . $title . "\t" . $content . "\n";
	}
	
	return 1;	
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

	Exporter

=head1 SYNOPSIS

	use PRETEXTO::DBI;

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