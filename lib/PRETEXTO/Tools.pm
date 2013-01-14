package PRETEXTO::Tools;

use strict;
use warnings;
use LSP::Utils;
use PRETEXTO::Tokenizer;
use Encode;
use utf8;
binmode(STDOUT, ':utf8');


sub new () {
	shift;
  my $this = {};	
  
  $this->{lsp_utils} = LSP::Utils->new();
  $this->{tokenizer} = ""; #PRETEXTO::Tokenizer->new();  
  
 	bless $this;
  return $this;
}


# This method is like GOLD, tons of GOLD!!!! (credits to C.Valente)
sub SetStringToUtf8 () {
	my $this = shift;
	my $string = shift || "";

	if ( Encode::is_utf8( $string ) ) {
		#warn("'$string' is utf8\n");
		# String is in utf-8		
		return $string;
	} else {
		#try to see if it's valid utf8 but the flag is off
		Encode::_utf8_on( $string );
		if ( Encode::is_utf8( $string, 1 ) ) {
			#warn("'$string' is utf8 (flagged turned on)\n");
			return $string;
		} else {
			Encode::_utf8_off( $string );
			Encode::_utf8_on( $string );
			#warn("'$string' is utf8 (last chance...)\n");
			return $string;
		}
	}
	
	return $string;
}


# LSP::Utils tokenizer
sub TokenizeString() {
	my $this = shift;
	my $input_string = shift || "";
	
	my $tokenized_string = $this->{lsp_utils}->TokenizeString($input_string);
	
	if (defined($tokenized_string)) {
		return $tokenized_string;	
	} else {
		return 0;
	}
		
}


# GUSTAVO TOKENIZER
sub Tokenize {
	my $this = shift;
	my $string = shift || "";
	
	my $tokenized_string = $this->{tokenizer}->Tokenize($string);
	
	return $tokenized_string;
}


sub SplitSentences {
	my $this = shift;
	my $string = shift || "";
	
	return $this->{lsp_utils}->SplitSentences($string);
}


1;

