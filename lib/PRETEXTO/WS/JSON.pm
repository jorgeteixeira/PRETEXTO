package PRETEXTO::WS::JSON;

use strict;
use warnings;
use JSON;
use PRETEXTO::Tools;
use utf8;
binmode(STDOUT, ':utf8');


sub new () {
	shift;
  my $this = {};
	$this->{tools} = new PRETEXTO::Tools;	
 	bless $this;
  return $this;
}




# Returns a json structure with the NER annotation
sub PrepareAnnotationedText {
	my $this = shift;
	my $annotation_ref = shift || "";
	
	my %annotation = %{$annotation_ref};
	my %results = ('Input text' => $annotation{'input_text'},
								 'Annotated text' => $annotation{'annotated_text'},
								 'Annotations' => $annotation{'annotations'});
	
	my $output = encode_json \%results;
	$output = $this->{tools}->SetStringToUtf8($output);
	
	return $output;
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



1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

PRETEXTO - Perl extension for blah blah blah

=head1 SYNOPSIS

  use PRETEXTO::JSON;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for PRETEXTO, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Jorge Teixeira, E<lt>jft@fe.up.ptE<gt>
=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Jorge Teixeira

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
