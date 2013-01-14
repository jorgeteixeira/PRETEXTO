package PRETEXTO::WS::Client;

use strict;
use warnings;
use Encode;
use PRETEXTO::Tools;
use utf8;
binmode(STDOUT, ':utf8');


sub new () {
	shift;
  my $this = {};	
  
  $this->{verbose} = 1;
  $this->{dbi} = new Verbetes::DBI;
	$this->{dbi}->ConnectToHost();  
	
	$this->{tools} = new Verbetes::Tools;
  
 	bless $this;
  return $this;
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

