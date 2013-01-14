package PRETEXTO::CRF;

use strict;
use warnings;
use DBI;
use FileHandle;
use LSP::LSP;
use LSP::Utils;	
use utf8;



sub new {
	shift;
  my $this = {};
  $this->{lsp} = new LSP::LSP();
  $this->{lsp_utils} = new LSP::Utils();
  %{$this->{proper_names_repentino}} = ();
  %{$this->{complete_proper_names_repentino}} = ();
     
  bless $this;
  return $this;
}



sub TokenizeString() {
	my $this = shift;
	my $input_string = shift || "";
	
	# tokenizer gustavo
	#use UGC::Tools::Tokenizer;
	#my $tokenizer_obj = new UGC::Tools::Tokenizer();
	#$tokenizer_obj->LoadDefaults();
	#warn("Body: $body\n");	
	#my $tokenized_body = $tokenizer_obj->TokenizeText($body);
	#warn("Body (tokenized Gustavo): $tokenized_body\n");
	
	
	my $tokenized_string = $this->{lsp_utils}->TokenizeString($input_string);
	
	if (defined($tokenized_string)) {
		return $tokenized_string;	
	} else {
		return 0;
	}
		
}


sub SplitSentences() {
	my $this = shift;
	my $paragraph = shift || "";


	$paragraph =~ s/  / /g;
	$paragraph =~ s/\s{2,}/ /gs;
	$paragraph =~ s/\t{1,}/ /gs;
	$paragraph =~ s/<br>/ /gs;

	
	
	
	my %siglas = ("dr" => 1, "dra" => 1, "d" => 1, "s" => 1, "prof" => 1);
	## Vamos corrigir alguns erros dos próprios autores
	for (keys %siglas) {
	$paragraph =~ s/\s($_) \./$1\./ig;
	}
	
	## Vamos testar os padrões de quebra de frase
	$paragraph =~/\s(\S+|\")(\.\.\.|\.|\!|\?) [A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ]/;
	my $p = $1;
	if(defined($p) && !defined($siglas{lc($p)}) && length($p) > 1) {
	$paragraph =~ s/\s(\S+|\")(\.\.\.|\.|\!|\?) ([A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ])/ $1 $2\n$3/g;
	}
	
	## Vamos testar padrões do tipo: (...) motor de desenvolvimento"."Estamos (...)
	if($paragraph =~ /(\") (\.) (\")/) {	
		$paragraph =~ s/(\") (\.) (\")/$1 $2\n$3/g;
	}	
	
	## Vamos testar padrões do tipo: (...) presidente.Todos (...)
	if($paragraph =~ /\s(\S+)(\.)[A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ]/) {
		my $p = $1;
		if(defined($p) && !defined($siglas{lc($p)}) && length($p) > 1) {		
			$paragraph =~ s/\s(\S+)(\.)([A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ])/ $1 $2\n$3/g;
		}
	}
	
	## Vamos testar padrões do tipo: (...) Zuma."É (...)
	if($paragraph =~ /\s(\S+)(\.) (\") [A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ]/) {
		my $p = $1;
		if(defined($p) && !defined($siglas{lc($p)}) && length($p) > 1) {		
			$paragraph =~ s/\s(\S+)(\.) (\") ([A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ])/ $1$2 \n$3$4/g;
		}
	}	
	
	## Vamos testar padrões do tipo: (...) Zuma".É (...)
	if($paragraph =~ /\s(\S+)(\") (\.) [A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ]/) {
		my $p = $1;
		if(defined($p) && !defined($siglas{lc($p)}) && length($p) > 1) {		
			$paragraph =~ s/\s(\S+)(\") (\.) ([A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ])/ $1$2 \n$3$4/g;
		}
	}		
#############	
	##  Vamos testar padrões do tipo: (...) mantê-lo " . Quanto (...)
	if($paragraph =~ /\s(\S+) (\") (\.) [A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ]/) {
		my $p = $1;
		if(defined($p) && !defined($siglas{lc($p)}) && length($p) > 1) {		
			$paragraph =~ s/\s(\S+) (\") (\.) ([A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ])/ $1$2$3 \n$4/g;
		}
	}		
		
	## Vamos testar padrões do tipo: (...) Economia " .O antigo (...)
	if($paragraph =~ /\s(\S+) (\") (\.)[A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ]/) {
		my $p = $1;
		if(defined($p) && !defined($siglas{lc($p)}) && length($p) > 1) {		
			$paragraph =~ s/\s(\S+) (\") (\.)([A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ])/ $1$2$3 \n$4/g;
		}
	}		
	
	## Vamos testar padrões do tipo: (...)água se via».«O cheiro (...)
	if($paragraph =~ /\s(\S+)(\»)(\.)(\«)[A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ]/) {
		my $p = $1;
		if(defined($p) && !defined($siglas{lc($p)}) && length($p) > 1) {		
			$paragraph =~ s/\s(\S+)(\»)(\.)(\«)([A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ])/ $1$2$3 \n$4$5/g;
		}
	}	
	
	## Vamos testar padrões do tipo: (...)água se via.«O cheiro (...)
	if($paragraph =~ /\s(\S+)(\.)\s{0,1}(\«)[A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ]/) {
		my $p = $1;
		if(defined($p) && !defined($siglas{lc($p)}) && length($p) > 1) {		
			$paragraph =~ s/\s(\S+)(\.)\s{0,1}(\«)([A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ])/ $1$2 \n$3$4/g;
		}
	}
	
	## Vamos testar padrões do tipo: (...)água se via».O cheiro (...)
	if($paragraph =~ /\s(\S+)(\»)(\.)\s{0,1}[A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ]/) {
		my $p = $1;
		if(defined($p) && !defined($siglas{lc($p)}) && length($p) > 1) {		
			$paragraph =~ s/\s(\S+)(\»)(\.)\s{0,1}([A-ZÁÉÍÓÚÃĨÕŨÂÊÎÔÛÇ])/ $1$2$3 \n$4/g;
		}
	}	
		
	## mais algumas limpezas
	#$paragraph =~ s/(\w)(\,\.\.\.|\.|\!|\?)$/$1 $2/g;
	$paragraph =~ s/  / /g;
	
	my @sentences = split('\n', $paragraph);	
	
	return @sentences;
}


sub GenerateFeatures() {
	my $this = shift;
	my $input_string = shift || "";
	
	# output
	my @output_list_features = ();
	
	# tokenize
	my @sentences = $this->SplitSentences($input_string);
	for (@sentences) {
		my $sentence = $_;
		#warn("\nSENTENCE: $_\n");
		my $tokenized_string = $this->TokenizeString($sentence);
		#warn("TOKENIZED SENTENCE: $tokenized_string\n");
		my @tokens = split(' ', $tokenized_string);

	
		## FEATURES
		##	0) Token
		##	1) Morphological category: nc, v, prn, ...
		##	2) Lema of the token
		##	3) Semantic category: geo, hmn, ...
		##	4) Capitalized word?
		##  5) Length of the word?
		##	6) Acronym?
		##	7) Proper Noun?
		##	8) Proper Noun from REPENTINO list?		
		
		my $ii = 0;	
		for (@tokens) {

			my $token = $tokens[$ii];
	
			# Proper noun
			my $pn_category = "NULL";
			$pn_category = $this->GetProperNoun(\@tokens, $ii);
			$token =~ s/<PN>//g;
			$token =~ s/<\/PN>//g;
			
			# Proper noun from REPENTINO list
			if ($pn_category eq "NULL") {
				$pn_category = $this->GetProperNounFromRepentino(\@tokens, $ii);
			}
			
			# Morphological category
			my $category = $this->GetCategory($token);
	
			# Lema
			my $lema = $this->GetLema($token);
	
			# Semantic category
			my $semantic_cat = $this->GetSemanticCategory($token);
	
			# Capitalized
			my $capitalized = $this->IsCapitalized($token);
				
			# Token length
			my $length = length($token);
				
			# Acronym
			my $acronym = $this->IsAcronym($token);
	
			my $output_string = $token . "\t" .
													$category . "\t" .
													$semantic_cat . "\t" .
													$lema . "\t" .																										 
													$capitalized . "\t" .
													$length . "\t" .
													$acronym . "\t" .
													$pn_category ."\n";
			push(@output_list_features, $output_string);
			$ii++;

			#warn("TOKEN ($ii): $_ [PN]: $pn_category [CAT]: $category [SEM]: $semantic_cat\n");
		} # for each token
		
		# Add an empty line at the end of each sentence
		my $output_string = "\n";
		push(@output_list_features, $output_string);
		
	} # for each sentence
	
	return \@output_list_features;
}


sub GetProperNoun () {
	my $this = shift;
	my $ref_list_tokens = shift || "";
	my $actual_position = shift || 0;
	my @tokens = @{$ref_list_tokens};
	my $token = $tokens[$actual_position];
	my $pn_category = "NULL";
	
	# Proper noun in the middle 
	# ex: <PN>Teixeira dos Santos<PN>
	# ex: <PN>Marcelo Rebelo de Sousa<PN>

	# First word from a multi-word name
	if ($token =~ /<PN>(.+?)$/ && $token !~ /<\/PN>/) {
		$pn_category = "pn_begin";			
	}
	# Last word from a multi-word name
	if ($token =~ /^(.+?)<\/PN>/) {
		$pn_category = "pn_end";			
	}
	# Middle word from a multi-word name
	if ($token !~ /<\/PN>|<PN>/ && 
			($tokens[$actual_position-1] =~ /^<PN>/ || $tokens[$actual_position-2] =~ /^<PN>/) &&
			($tokens[$actual_position+1] =~ /<\/PN>$/ || $tokens[$actual_position+2] =~ /<\/PN>$/)
			) {
		$pn_category = "pn_middle";			
	}	
	
	return $pn_category;
}


sub LoadRepentino () {
	my $this = shift;
  my $path_to_repentino = shift || "../../corpus/REPENTINO/repentino.txt";
  my $path_to_repentino_complete_names = shift || "../../corpus/REPENTINO/proper_names_repentino.txt";
  
  # proper names with only one word
  open (REPENTINOSHORT, $path_to_repentino) or die $!;
  while (<REPENTINOSHORT>) {
  	my $token = $_;
  	$token =~ s/\t|\n$//;
  	$this->{proper_names_repentino}{$token}++;
  }  
  
  # complete proper names
  open (REPENTINO, $path_to_repentino_complete_names) or die $!;
  while (<REPENTINO>) {
  	my $name = $_;
  	$name =~ s/\t|\n$//;
  	$this->{complete_proper_names_repentino}{$name}++; 	
  }  
  
}


sub GetProperNounFromRepentino () {
	my $this = shift;
	my $tokens_ref = shift || "";
	my $actual_position = shift || 0;
	
	my @tokens = @{$tokens_ref};
	my $token = $tokens[$actual_position];
	my $pn_category = "NULL";


	#### 4 words Noun
	
	# name with 4 words -> received token is in the begining
	if (defined($token) && defined($tokens[$actual_position+1]) && defined ($tokens[$actual_position+2]) && defined ($tokens[$actual_position+3])) {
		my $case_1 = $token . " " . $tokens[$actual_position+1] . " " . $tokens[$actual_position+2] . " " . $tokens[$actual_position+3];
		if ( defined($this->{complete_proper_names_repentino}{$case_1})	) {
			return "pn_begin";
		}
	}

	# name with 4 words -> received token is in the middle
	if (defined($token) && defined($tokens[$actual_position-1]) && defined ($tokens[$actual_position+1]) && defined ($tokens[$actual_position+2])) {
		my $case_2 = $tokens[$actual_position-1] . " " . $token . " " . $tokens[$actual_position+1] . " " . $tokens[$actual_position+2];
		if ( defined($this->{complete_proper_names_repentino}{$case_2})	) {
			return "pn_middle";
		}
	}

	# name with 4 words -> received token is in the middle
	if (defined($token) && defined($tokens[$actual_position-2]) && defined($tokens[$actual_position-1]) && defined ($tokens[$actual_position+1])) {
		my $case_3 = $tokens[$actual_position-2] . " " . $tokens[$actual_position-1] . " " . $token . " " . $tokens[$actual_position+1];
		if ( defined($this->{complete_proper_names_repentino}{$case_3})	) {
			return "pn_middle";
		}
	}

	# name with 3 words -> received token is in the end
	if (defined($token) && defined($tokens[$actual_position-1])  && defined($tokens[$actual_position-2]) && defined ($tokens[$actual_position-3])) {
		my $case_4 = $tokens[$actual_position-3] . " " . $tokens[$actual_position-2] . " " . $tokens[$actual_position-1] . " " . $token;
		if ( defined($this->{complete_proper_names_repentino}{$case_4})	) {
			return "pn_end";
		}
	}
	
	
	#### 3 words Noun

	
	# name with 3 words -> received token is in the begining
	if (defined($token) && defined($tokens[$actual_position+1]) && defined ($tokens[$actual_position+2])) {
		my $case_5 = $token . " " . $tokens[$actual_position+1] . " " . $tokens[$actual_position+2];
		if ( defined($this->{complete_proper_names_repentino}{$case_5})	) {
			return "pn_begin";
		}
	}

	# name with 3 words -> received token is in the middle
	if (defined($token) && defined($tokens[$actual_position-1]) && defined ($tokens[$actual_position+1])) {
		my $case_6 = $tokens[$actual_position-1] . " " . $token . " " . $tokens[$actual_position+1];
		if ( defined($this->{complete_proper_names_repentino}{$case_6})	) {
			return "pn_middle";
		}
	}

	# name with 3 words -> received token is in the end
	if (defined($token) && defined($tokens[$actual_position-1]) && defined ($tokens[$actual_position-2])) {
		my $case_7 = $tokens[$actual_position-2] . " " . $tokens[$actual_position-1] . " " . $token;
		if ( defined($this->{complete_proper_names_repentino}{$case_7})	) {
			return "pn_end";
		}
	}
	
	
	#### 2 words Noun
	
	# name with 2 words -> received token is in the begining
	if (defined($token) && defined($tokens[$actual_position+1])) {
		my $case_8 = $token . " " . $tokens[$actual_position+1];
		if ( defined($this->{complete_proper_names_repentino}{$case_8})	) {
			return "pn_begin";
		}
	}

	# name with 2 words -> received token is in the end
	if (defined($token) && defined($tokens[$actual_position-1])) {
		my $case_9 = $tokens[$actual_position-1] . " " . $token;
		if ( defined($this->{complete_proper_names_repentino}{$case_9})	) {
			return "pn_end";
		}
	}	
	
	return "NULL";
}



sub GetProperNounOneWordFromRepentino () {
	my $this = shift;
	my $token = shift || "";
	$token = lc($token);
	my $pn_category = "NULL";
	
	if (defined($this->{proper_names_repentino}{$token})) {
		$pn_category = "pn_repentino";
	}

	return $pn_category;
}


sub GetCategory () {
	my $this = shift;
	my $token = shift || "";

	my @analysis_list = $this->{lsp}->GetAnalysis($token);
	my $category = "";
	for (@analysis_list) {
 		my %index_list = %{$_};
 		if (defined($index_list{category})) {
 			return $index_list{category};
 		} else {
 			return "NULL";
 		}
	}

	return "NULL";
}


sub GetSemanticCategory () {
	my $this = shift;
	my $token = shift || "";
	
	my @analysis_list = $this->{lsp}->GetAnalysis($token);
	for (@analysis_list) {
 		my %info = %{$_};
 		
 		if(defined($info{semantic_tags}))	{
 			my @semantic_tags = @{$info{semantic_tags}};
			for (@semantic_tags) {
				my $ref = $_;
	  		my %semantic_hash = %{$ref};
				if(defined($semantic_hash{tag_cat})) {
					if(defined($semantic_hash{tag_sub_cat})) {
						return $semantic_hash{tag_cat} . "_" . $semantic_hash{tag_sub_cat};
					}
					return $semantic_hash{tag_cat};
				} else {
					return "NULL";
				}
			}
 		} 
	}
	
	return "NULL";	
}


sub GetLema () {
	my $this = shift;
	my $token = shift || "";

	my @analysis_list = $this->{lsp}->GetAnalysis($token);
	my $category = "";
	for (@analysis_list) {
 		my %index_list = %{$_};
 		if (defined($index_list{radical})) {
 			return $index_list{radical};
 		} else {
 			return "NULL";
 		}
	}

	return "NULL";	
}


sub IsCapitalized() {
	my $this = shift;
	my $token = shift || "";
	if ($token =~ /^[A-ZÁÀÉÈÍÌÓÒÚÙ]/) {
		return "Capitalized";
	}
	 
	return "NULL"; 
}


sub IsAcronym() {
	my $this = shift;
	my $token = shift || "";
	
	if ($token =~ /[a-z]/ || $token =~ /\W/ || $token =~ /\d/ || length($token) < 2) {
		return "NULL";
	}
	
	return "ACRONYM";
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

	CRF (Conditional Random Field)

=head1 SYNOPSIS

	use PRETEXTO::CRF;

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