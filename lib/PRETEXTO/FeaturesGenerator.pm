package PRETEXTO::FeaturesGenerator;

use strict;
use warnings;
use LSP::LSP;
use PRETEXTO::Tools;	
use PRETEXTO::Lists;
use Lingua::Jspell;
use utf8;
binmode(STDOUT, ':utf8');



sub new {
	shift;
  my $this = {};
  
  $this->{lsp} = LSP::LSP->new();
  $this->{tools} = PRETEXTO::Tools->new();
  $this->{sapo_lists} = PRETEXTO::Lists->new();
  $this->{sapo_lists}->Init();
  $this->{jspell} = Lingua::Jspell->new("port"); #./dictionary/
   
  %{$this->{features}} = ();
  %{$this->{jspell_info}} = ();
     
  bless $this;
  return $this;
}






######################### PREPARE FEATURES ####################################

sub GenerateFeaturesFromText {
	my $this = shift;
	my $input_text = shift || "";
	
	my $sentences_ref = $this->GetSenteces($input_text);
	my $tokens_ref = $this->GetTokensBySentence($sentences_ref);
	
	# KEEP THIS ORDER
	$this->BuildLexicalFeatures($sentences_ref,$tokens_ref);
	$this->BuildPosicionalFeatures($sentences_ref,$tokens_ref);
	$this->BuildSapoListsFeatures($sentences_ref,$tokens_ref);
	$this->BuildLSPFeatures($sentences_ref,$tokens_ref);	
	$this->BuildRepentinoFeatures($sentences_ref,$tokens_ref);
	$this->BuildNewsTopicsFeatures($sentences_ref,$tokens_ref);
	$this->BuildPlacesFeatures($sentences_ref,$tokens_ref);
	$this->BuildVerbetesFeatures($sentences_ref,$tokens_ref);

	# Prepare the CRF features structure	
	my $output = $this->PrepareCRFWithFeatures($input_text, $sentences_ref, $tokens_ref);
	
	# Clean features
	%{$this->{features}} = ();
	
	return $output;
}


sub GetSenteces {
	my $this = shift;
	my $input_text = shift;
	my %sentences = (); # $sentences{pos} = sentence

	# Split input text into sentences
	my @sentences = $this->{tools}->SplitSentences($input_text);
	my $ii = 0;
	for (@sentences) {
		$sentences{$ii++} = $_;	
	}
	
	return \%sentences;	
}


sub GetTokensBySentence {
	my $this = shift;
	my $sentence_ref = shift;
	my %output = (); # $output{sentence_pos}{token_pos} = token

	my %sentences = %{$sentence_ref};
	for (keys %sentences) {
		my $sentence_position = $_;
		my $sentence = $sentences{$sentence_position};
#		warn "SENTENCE: $sentence\n";
		my $tokenized_sentence = $this->{tools}->Tokenize($sentence); ## GUSTAVO
		#my $tokenized_sentence = $this->{tools}->TokenizeString($sentence); ## LSP::Utils
#		warn "TOKENIZED SENTENCE: $tokenized_sentence\n";
		my @tokens = split(' ', $tokenized_sentence);
		my $ii = 0;
		for (@tokens) {
			$output{$sentence_position}{$ii++} = $_;
		}

	}
	
	return \%output;			
}


sub PrepareCRFWithFeatures {
	my $this = shift;
	my $input_text = shift || "";
	my $sentences_ref = shift || "";
	my $tokens_ref = shift || "";
	my $output = "";
	
	my %sentences = %{$sentences_ref};
	my %tokens = %{$tokens_ref};
	my %features = %{$this->{features}};
	
	
	for ( my $sentence_pos = 1; $sentence_pos < scalar(keys %sentences); $sentence_pos++ ) {
#		warn "\n[$sentence_pos] => [$sentences{$sentence_pos}]\n";
		for ( my $token_pos = 0; $token_pos < scalar(keys %{$tokens{$sentence_pos}}); $token_pos++ ) {
			if ( !defined($features{$sentence_pos}{$token_pos}) ) {
#				warn "\t[$token_pos] => [[$tokens{$sentence_pos}{$token_pos}]]\n";
				$output .= $this->PrepareCrfTemplate($tokens{$sentence_pos}{$token_pos},"");
			} else {
#				warn "\t[$token_pos] => [[$tokens{$sentence_pos}{$token_pos}]] $features{$sentence_pos}{$token_pos}\n";
				$output .= $this->PrepareCrfTemplate($tokens{$sentence_pos}{$token_pos},$features{$sentence_pos}{$token_pos});
			}
		}
		$output .= "\n"; # one extra '\n' after each sentence
	}

	return $output;
}


sub GetTokenPositions {
	my $this = shift;
	my $sentence = shift || "";
	my $tag = shift || "";
	my %output = ();

	my @tag_words = split(' ', lc($tag));
	my @sentence_words = split(' ', lc($sentence));
	for ( my $ii = 0; $ii < scalar(@sentence_words); $ii++ ) {
		
		# e.g.: "Portugal"
		if ( scalar(@tag_words) eq 1 && $sentence_words[$ii] eq $tag_words[0] ) {
			$output{$tag} .= $ii . "\t";
		}

		# e.g.: "Reino Unido"
		if ( scalar(@tag_words) eq 2 && $sentence_words[$ii] eq $tag_words[0] && 
					$sentence_words[$ii+1] eq $tag_words[1]) {		
			$output{$tag} .= $ii . "," . ($ii+1) . "\t";
		}

		# e.g.: "República da Albânia"
		if ( scalar(@tag_words) eq 3 && $sentence_words[$ii] eq $tag_words[0] && 
					$sentence_words[$ii+1] eq $tag_words[1] &&
					$sentence_words[$ii+2] eq $tag_words[2]) {
			$output{$tag} .= $ii . "," . ($ii+1) . "," . ($ii+2) . "\t";
		}		
		
		# e.g.: "República Islâmica do Afeganistão"
		if ( scalar(@tag_words) eq 4 && $sentence_words[$ii] eq $tag_words[0] && 
					$sentence_words[$ii+1] eq $tag_words[1] &&
					$sentence_words[$ii+2] eq $tag_words[2] &&
					$sentence_words[$ii+3] eq $tag_words[3]) {
			$output{$tag} .= $ii . "," . ($ii+1) . "," . ($ii+2) . "," . ($ii+3) . "\t";
		}
		
		# e.g.: "República Popular Democrática da Argélia"
		if ( scalar(@tag_words) eq 5 && $sentence_words[$ii] eq $tag_words[0] && 
					$sentence_words[$ii+1] eq $tag_words[1] &&
					$sentence_words[$ii+2] eq $tag_words[2] &&
					$sentence_words[$ii+3] eq $tag_words[3] &&
					$sentence_words[$ii+4] eq $tag_words[4]) {
			$output{$tag} .= $ii . "," . ($ii+1) . "," . ($ii+2) . "," . ($ii+3) . "," . ($ii+4) . "\t";
		}
		
		# e.g.: "República Democrática Socialista do Seri Lanca"
		if ( scalar(@tag_words) eq 6 && $sentence_words[$ii] eq $tag_words[0] && 
					$sentence_words[$ii+1] eq $tag_words[1] &&
					$sentence_words[$ii+2] eq $tag_words[2] &&
					$sentence_words[$ii+3] eq $tag_words[3] &&
					$sentence_words[$ii+4] eq $tag_words[4] &&
					$sentence_words[$ii+5] eq $tag_words[5]) {
			$output{$tag} .= $ii . "," . ($ii+1) . "," . ($ii+2) . "," . ($ii+3) . "," . ($ii+4) . "," . ($ii+5) . "\t";
		}
						
	}	
	
	return \%output;
}


sub PrepareCrfTemplate {
	my $this = shift;
	my $token = shift;
	my $string_features = shift; 
	# e.g.: '[24] => [[Instituto]] CAPITALIZED	LEMMA_instituto	MORPHO_CAT_nc	SEMANTIC_CAT_ORG_EDU'
	
	# output string in CRF format
	$token =~ s/\s|\t|\n//g;
	my $output = $token . "\t"; 
	my %output_order = ();
	
	# define CRF template accordingly to 'template/template_crf.txt'
	my @features = split('\t', $string_features);
	for (@features) {

		# LSP morphological category
		if ($_ =~ s/^MORPHO_CAT_(.+)$/$1/) {
			$output_order{0} = $1;
		}

		# LSP lemma
		if ($_ =~ s/^LEMMA_(.+)$/$1/) {
			$output_order{1} = $1;
		}

		# Capitalized
		if ($_ =~ /^CAPITALIZED$/) {
			$output_order{2} = "CAPITALIZED";
		}
	
		# Acronym
		if ($_ =~ /^ACRONYM$/) {
			$output_order{3} = "ACRONYM";
		}

		# Punctuation
		if ($_ =~ /^PUNCTUATION/) {
			$output_order{4} = "PUNCTUATION";
		}
		
		# Position on sentence
		if ($_ =~ /^BEGIN_SENTENCE$/ || $_ =~ /^END_SENTENCE$/) {
			$output_order{5} = "$_";
		}		

		# LSP - semantic category
		if ($_ =~ s/^SEMANTIC_CAT_(.+)$/$1/ ) {
			$output_order{6} = "$1";
		}
		
		# Sapo Lists
		if ($_ =~ s/^SAPO_LIST_(.+)$/$1/ ) {
			$output_order{7} = "$1";
		}
		
		# Verbetes ergo
		if ($_ =~ /^VERBETES_ERGO$/ ) {
			$output_order{8} = "$_";
		}							

		# Topico - NewsTopics
		if ($_ =~ /^TOPIC$/ ) {
			$output_order{9} = "$_";
		}							

		# Name - REPENTINO_NAME
		if ($_ =~ /^REPENTINO_NAME$/ ) {
			$output_order{10} = "$_";
		}
		
		# Name - Verbetes name
		if ($_ =~ /^VERBETES_NAME$/ ) {
			$output_order{10} = "$_";
		}		

	}
	
	
	for (my $ii=0; $ii <= 10; $ii++) {
		if ( defined($output_order{$ii}) ) {
			$output .= $output_order{$ii} . "\t";
		} else {
			$output .= "NULL" . "\t";
		}
	}
	$output =~ s/\t$//;
	$output .= "\n";
	
	return $output;
}

################################################################################
############################ FEATURES TYPES ####################################
################################################################################

############################# Lexicais #########################################
# maiuscula, acronimo, sufixo, prefixo (modifiers)
sub BuildLexicalFeatures {
	my $this = shift;
	my $sentences_ref = shift || ""; # $sentences{pos} = sentence
	my $tokens_ref = shift || ""; # $token{sentence_pos}{token_pos} = token
	
	my %tokens = %{$tokens_ref};
	for (keys %tokens) {
		my $sentence_pos = $_;
		for (keys %{$tokens{$sentence_pos}}) {
			my $token_pos = $_;
			my $token = $tokens{$sentence_pos}{$token_pos};
			
			if ($this->IsAcronym($token) eq 1) {
				$this->{features}{$sentence_pos}{$token_pos} .= "ACRONYM" . "\t";
			}
			
			if ($this->IsCapitalized($token) eq 1) {
				$this->{features}{$sentence_pos}{$token_pos} .= "CAPITALIZED" . "\t";
			}

			if ($this->IsQuote($token) eq 1) {
				$this->{features}{$sentence_pos}{$token_pos} .= "PUNCTUATION_QUOTE" . "\t";
			}
						
		}
	}	
}


sub IsAcronym {
	my $this = shift;
	my $token = shift || "";
	
	if ($token =~ /[a-z]/ || $token =~ /\W/ || $token =~ /\d/ || length($token) < 2) {
		return 0;
	}
	
	return 1;
}


sub IsCapitalized {
	my $this = shift;
	my $token = shift || "";
	if ($token =~ /^[A-ZÁÀÂÄÃÉÈÊËÍÌÎÏÓÒÔÖÕÚÙÛÜ]/) {
		return 1;
	}
	 
	return 0; 
}


sub IsQuote {
	my $this = shift;
	my $token = shift || "";
	
	if ( $token =~ /^("|«|“|'|»|”|‘|’)$/ ) {
		return 1;
	}
	
	return 0;
}


############################# Posicionais ######################################
# inicio frase, fim frase
sub BuildPosicionalFeatures {
	my $this = shift;
	my $sentences_ref = shift || ""; # $sentences{pos} = sentence
	my $tokens_ref = shift || ""; # $token{sentence_pos}{token_pos} = token
	
	my %tokens = %{$tokens_ref};
	for (keys %tokens) {
		my $sentence_pos = $_;
		for (keys %{$tokens{$sentence_pos}}) {
			my $token_pos = $_;
			my $token = $tokens{$sentence_pos}{$token_pos};

			# First is begin of sentence
			if ($token_pos eq 0) {
				$this->{features}{$sentence_pos}{$token_pos} .= "BEGIN_SENTENCE" . "\t";
			}			
									
		}
		
		my $nr_tokens = scalar(keys %{$tokens{$sentence_pos}});
		my $last_token_pos = $nr_tokens-1;
		$this->{features}{$sentence_pos}{$last_token_pos} .= "END_SENTENCE" . "\t";							
		
	}	
}


############################# LSP ##############################################
# categoria morfo, semantica e lema
sub BuildLSPFeatures {
	my $this = shift;
	my $sentences_ref = shift || ""; # $sentences{pos} = sentence
	my $tokens_ref = shift || ""; # $token{sentence_pos}{token_pos} = token
		
	my %tokens = %{$tokens_ref};
	for (keys %tokens) {
		my $sentence_pos = $_;
		for (keys %{$tokens{$sentence_pos}}) {
			my $token_pos = $_;
			my $token = $tokens{$sentence_pos}{$token_pos};

			# avoid weired characters that jspell cannot decode (basically quotes)
			if ($token =~ /\x{201c}|\x{201d}|\x{2018}|\x{2019}|\x{2013}|\x{2014}|\x{2026}|\x{20ac}|\x{2022}|\x{0107}|\x{fffd}|\x{06c1}|\x{023c}|\x{03de}|\x{01fb}|\x{0392}|\x{0596}|\x{055e}|\x{2033}/) {
				next;
			}

			# Get lemma
			my $lemma = $this->GetLema($token);
			if ( $lemma ne 0 ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "LEMMA_" . $lemma . "\t";				
			}

			# Get LSP morphological category
			my $morph_cat = $this->GetLSPMorphoCategory($token);
			if ( $morph_cat ne 0 ) {
				if ( $morph_cat eq "punct" ) {
					$this->{features}{$sentence_pos}{$token_pos} .= "PUNCTUATION" . "\t";
				} else {
					$this->{features}{$sentence_pos}{$token_pos} .= "MORPHO_CAT_" . $morph_cat . "\t";	
				}
			}
			
			# Get semantic category if this token does not have a tag from sapo lists
			my $sem_cat = $this->GetSemanticCategory($token);
			if ( $sem_cat ne 0  &&
					 defined($this->{features}{$sentence_pos}{$token_pos}) && 
					 $this->{features}{$sentence_pos}{$token_pos} !~ /SAPO_LIST_/) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SEMANTIC_CAT_" . $sem_cat . "\t";				
			}		
						
		}
	}	
}


sub GetLSPMorphoCategory {
	my $this = shift;
	my $token = shift || "";

	# check if this lemma is not in jspell hash already (this saves a lot of call to jspell!)
	if ( defined($this->{jspell_info}{$token}{morph_cat}) ) {
		return $this->{jspell_info}{$token}{morph_cat};
	} 

	my @analysis_list = $this->{jspell}->fea($token);
	if ( scalar(@analysis_list) eq 0 ) {
		return 0;
	}	
	for (@analysis_list) {
 		my %analysis = %{$_};
 		
 		if (defined($analysis{CAT}) && $analysis{rad} ne "X") {
 			$this->{jspell_info}{$token}{morph_cat} = $analysis{CAT};
 			return $analysis{CAT};
 		}  		
 		else {
 			return 0;
 		}
	}

	return 0;
}


sub GetLema {
	my $this = shift;
	my $token = shift || "";

	# check if this lemma is not in jspell hash already (this saves a lot of call to jspell!)
	if ( defined($this->{jspell_info}{$token}{lemma}) ) {
		return $this->{jspell_info}{$token}{lemma};
	} 

	my @analysis_list = $this->{jspell}->fea($token);
	if ( scalar(@analysis_list) eq 0 ) {
		return 0;
	}
	for (@analysis_list) {
 		my %analysis = %{$_};
 		
 		# lemma cannot be 'pucnt' or 'X' neither it cannot has spaces (bug reported to Alberto Simões)
 		if (defined($analysis{rad}) && defined($analysis{CAT}) && $analysis{CAT} ne "punct" && $analysis{rad} ne "X" && $analysis{rad} !~ /\s/) {
 			$this->{jspell_info}{$token}{lemma} = $analysis{rad};
 			return $analysis{rad};
 		} else {
 			return 0;
 		}
	}

	return 0;	
}


sub GetSemanticCategory () {
	my $this = shift;
	my $token = shift || "";
	
	my @analysis_list = $this->{lsp}->GetAnalysis($token);
	if ( scalar(@analysis_list) eq 0 ) {
		return 0;
	}	
	for (@analysis_list) {
 		my %info = %{$_}; 		
 		if(defined($info{semantic_tags}))	{
			for (@{$info{semantic_tags}}) {
	  		my %semantic_hash = %{$_};
				if(defined($semantic_hash{tag_cat})) {
					if(defined($semantic_hash{tag_sub_cat})) {
						return $semantic_hash{tag_cat} . "_" . $semantic_hash{tag_sub_cat};
					} else {
						return $semantic_hash{tag_cat};
					}
				} else {
					return 0;
				}
			}
 		} 
	}
	
	return 0;	
}


############################# SAPO LISTAS ######################################
# informação semântica
sub BuildSapoListsFeatures {
	my $this = shift;
	my $sentences_ref = shift || ""; # $sentences{pos} = sentence
	my $tokens_ref = shift || ""; # $token{sentence_pos}{token_pos} = token
		
	my %tokens = %{$tokens_ref};
	my %sencentes = %{$sentences_ref};
	for (keys %tokens) {
		my $sentence_pos = $_;
		for (keys %{$tokens{$sentence_pos}}) {
			my $token_pos = $_;
			my $token = $tokens{$sentence_pos}{$token_pos};
			
			# Lets first handle *single-word* lists only	
			 
			# ergo 
			if ( defined( $PRETEXTO::Lists::ergos_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_ERGO" . "\t";
			}

			# roles
			if ( defined( $PRETEXTO::Lists::roles_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_ROLE" . "\t";
			}

			# communication verbs 
			if ( defined( $PRETEXTO::Lists::communication_verbs_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_COM_VERB" . "\t";
			}			

			# geographic places
			if ( defined( $PRETEXTO::Lists::geographic_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_GEO" . "\t";
			}			

			# human info
			if ( defined( $PRETEXTO::Lists::human_info_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_HMN_INFO" . "\t";
			}	
			
			# months
			if ( defined( $PRETEXTO::Lists::months_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_MONTH" . "\t";
			}	
						
			# weekdays
			if ( defined( $PRETEXTO::Lists::weekdays_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_WEEKDAY" . "\t";
			}	
			
			# nationalities
			if ( defined( $PRETEXTO::Lists::nacionalities_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_NAT" . "\t";
			}				
			
			# indexes
			if ( defined( $PRETEXTO::Lists::indexes_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_INDEX" . "\t";
			}	
			
			# organizations
			if ( defined( $PRETEXTO::Lists::organizations_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_ORG" . "\t";
			}	
			
			# places
			if ( defined( $PRETEXTO::Lists::places_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_PLACE" . "\t";
			}	
			
			# publications
			if ( defined( $PRETEXTO::Lists::publications_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_PUBLICATION" . "\t";
			}	
			
			# human relations
			if ( defined( $PRETEXTO::Lists::human_relations_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_HMN_REL" . "\t";
			}	
			
			# currency
			if ( defined( $PRETEXTO::Lists::currency_list{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "SAPO_LIST_CURENCY" . "\t";
			}	
									
		}
		
#		# Now lets handle with *multi-word* lists
#		
#		my $sentence_content = $sencentes{$sentence_pos};
#		$sentence_content = $this->{tools}->Tokenize($sentence_content); ## GUSTAVO
#		#$sentence_content = $this->{tools}->TokenizeString($sentence_content); ## LSP::Utils
#		
#		
#		# events list
#		for (sort { length($b) <=> length($a) } keys %PRETEXTO::Lists::events_list) {
#			if ( $sentence_content =~ /(^|«|“|"|'|\s)$_(\s|\.|,|"|'|»|”|$)/i ) {
#				my %token_pos = %{$this->GetTokenPositions($sentence_content, $_)};
#				my @positions = split('\t', $token_pos{$_});
#				for (@positions) {
#					my $pos = $_;
#					my @tag_position = split(',', $pos);
#					for (@tag_position) {
#						$this->{features}{$sentence_pos}{$_} .= "SAPO_LIST_EVENT" . "\t";
#					}
#				}				
#			}
#		}
#
#
#		# countries list
#		for (sort { length($b) <=> length($a) } keys %PRETEXTO::Lists::countries_list) {
#			if ( $sentence_content =~ /(^|«|“|"|'|\s)$_(\s|\.|,|"|'|»|”|$)/i ) {
#				my %token_pos = %{$this->GetTokenPositions($sentence_content, $_)};
#				my @positions = split('\t', $token_pos{$_});
#				for (@positions) {
#					my $pos = $_;
#					my @tag_position = split(',', $pos);
#					for (@tag_position) {
#						$this->{features}{$sentence_pos}{$_} .= "SAPO_LIST_COUNTRY" . "\t";
#					}
#				}				
#			}			
#		}
#
#		# journals list
#		for (sort { length($b) <=> length($a) } keys %PRETEXTO::Lists::journals_list) {
#			if ( $sentence_content =~ /(^|«|“|"|'|\s)$_(\s|\.|,|"|'|»|”|$)/i ) {
#				my %token_pos = %{$this->GetTokenPositions($sentence_content, $_)};
#				my @positions = split('\t', $token_pos{$_});
#				for (@positions) {
#					my $pos = $_;
#					my @tag_position = split(',', $pos);
#					for (@tag_position) {
#						$this->{features}{$sentence_pos}{$_} .= "SAPO_LIST_JOURNALS" . "\t";
#					}
#				}				
#			}			
#		}

	}	
}


############################# VERBETES #########################################
# nomes pessoas, organizações, job descriptions
sub BuildVerbetesFeatures {
	my $this = shift;
	my $sentences_ref = shift || ""; # $sentences{pos} = sentence
	my $tokens_ref = shift || ""; # $token{sentence_pos}{token_pos} = token
		
	my %tokens = %{$tokens_ref};
	my %sencentes = %{$sentences_ref};
	for (keys %tokens) {
		my $sentence_pos = $_;
		for (keys %{$tokens{$sentence_pos}}) {
			my $token_pos = $_;
			my $token = $tokens{$sentence_pos}{$token_pos};
		 
			if ( defined( $PRETEXTO::Lists::verbetes_names{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "VERBETES_NAME" . "\t";
			}
			
			if ( defined( $PRETEXTO::Lists::verbetes_ergos{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "VERBETES_ERGO" . "\t";
			}			
									
		}
		
#		
#		# Now lets handle with *multi-word* lists
#		
#		my $sentence_content = $sencentes{$sentence_pos};
#		$sentence_content = $this->{tools}->Tokenize($sentence_content); ## GUSTAVO
#		#$sentence_content = $this->{tools}->TokenizeString($sentence_content); ## LSP::Utils
#		
#		# Verbetes names
#		for (sort { length($b) <=> length($a) } keys %PRETEXTO::Lists::verbetes_names) {
#			if ( $sentence_content =~ /(^|«|“|"|'|\s)$_(\s|\.|,|"|'|»|”|$)/i ) {
#				my %token_pos = %{$this->GetTokenPositions($sentence_content, $_)};
#				my @positions = split('\t', $token_pos{$_});
#				for (@positions) {
#					my $pos = $_;
#					my @tag_position = split(',', $pos);
#					for (@tag_position) {
#						$this->{features}{$sentence_pos}{$_} .= "VERBETES_NAMES" . "\t";
#					}
#				}				
#			}
#		}
#		
#		
#		# Verbetes ergos
#		for (sort { length($b) <=> length($a) } keys %PRETEXTO::Lists::verbetes_ergos) {
#			if ( $sentence_content =~ /(^|«|“|"|'|\s)$_(\s|\.|,|"|'|»|”|$)/i ) {
#				my %token_pos = %{$this->GetTokenPositions($sentence_content, $_)};
#				my @positions = split('\t', $token_pos{$_});
#				for (@positions) {
#					my $pos = $_;
#					my @tag_position = split(',', $pos);
#					for (@tag_position) {
#						$this->{features}{$sentence_pos}{$_} .= "VERBETES_ERGOS" . "\t";
#					}
#				}				
#			}
#		}				
		
	}		
}


############################# TOPÍCOS ##########################################
# usar índices gerados
sub BuildNewsTopicsFeatures {
	my $this = shift;
	my $sentences_ref = shift || ""; # $sentences{pos} = sentence
	my $tokens_ref = shift || ""; # $token{sentence_pos}{token_pos} = token
		
	my %tokens = %{$tokens_ref};
	my %sencentes = %{$sentences_ref};
	for (keys %tokens) {
		my $sentence_pos = $_;
		for (keys %{$tokens{$sentence_pos}}) {
			my $token_pos = $_;
			my $token = $tokens{$sentence_pos}{$token_pos};
		 
			if ( defined( $PRETEXTO::Lists::news_topics{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "TOPIC" . "\t";
			}
									
		}
		
		
#		# Now lets handle with *multi-word* lists
#		
#		my $sentence_content = $sencentes{$sentence_pos};
#		$sentence_content = $this->{tools}->Tokenize($sentence_content); ## GUSTAVO
#		#$sentence_content = $this->{tools}->TokenizeString($sentence_content); ## LSP::Utils
#		
#		for (sort { length($b) <=> length($a) } keys %PRETEXTO::Lists::news_topics) {
#			if ( $sentence_content =~ /(^|«|“|"|'|\s)$_(\s|\.|,|"|'|»|”|$)/i ) {
#				my %token_pos = %{$this->GetTokenPositions($sentence_content, $_)};
#				my @positions = split('\t', $token_pos{$_});
#				for (@positions) {
#					my $pos = $_;
#					my @tag_position = split(',', $pos);
#					for (@tag_position) {
#						$this->{features}{$sentence_pos}{$_} .= "TOPIC" . "\t";
#					}
#				}				
#			}
#		}		
		
	}	
}


############################# REPENTINO ########################################
# nomes pessoas
sub BuildRepentinoFeatures {
	my $this = shift;
	my $sentences_ref = shift || ""; # $sentences{pos} = sentence
	my $tokens_ref = shift || ""; # $token{sentence_pos}{token_pos} = token
		
	my %tokens = %{$tokens_ref};
	my %sencentes = %{$sentences_ref};
	for (keys %tokens) {
		my $sentence_pos = $_;
		for (keys %{$tokens{$sentence_pos}}) {
			my $token_pos = $_;
			my $token = $tokens{$sentence_pos}{$token_pos};
		 
			if ( defined( $PRETEXTO::Lists::repentino_names{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "REPENTINO_NAME" . "\t";
			}
									
		}
	}	
}


############################# LOCAIS ###########################################
# places from 'news topics'
sub BuildPlacesFeatures {
	my $this = shift;
	my $sentences_ref = shift || ""; # $sentences{pos} = sentence
	my $tokens_ref = shift || ""; # $token{sentence_pos}{token_pos} = token
		
	my %tokens = %{$tokens_ref};
	my %sencentes = %{$sentences_ref};
	for (keys %tokens) {
		my $sentence_pos = $_;
		for (keys %{$tokens{$sentence_pos}}) {
			my $token_pos = $_;
			my $token = $tokens{$sentence_pos}{$token_pos};		 
			if ( defined( $PRETEXTO::Lists::places{$token} ) ) {
				$this->{features}{$sentence_pos}{$token_pos} .= "PLACE" . "\t";
			}
		}
		
#		# Now lets handle with *multi-word* lists
#		
#		my $sentence_content = $sencentes{$sentence_pos};
#		$sentence_content = $this->{tools}->Tokenize($sentence_content); ## GUSTAVO
#		#$sentence_content = $this->{tools}->TokenizeString($sentence_content); ## LSP::Utils
#		
#		for (sort { length($b) <=> length($a) } keys %PRETEXTO::Lists::news_topics) {
#			if ( $sentence_content =~ /(^|«|“|"|'|\s)$_(\s|\.|,|"|'|»|”|$)/i ) {
#				my %token_pos = %{$this->GetTokenPositions($sentence_content, $_)};
#				my @positions = split('\t', $token_pos{$_});
#				for (@positions) {
#					my $pos = $_;
#					my @tag_position = split(',', $pos);
#					for (@tag_position) {
#						$this->{features}{$sentence_pos}{$_} .= "PLACE" . "\t";
#					}
#				}				
#			}
#		}		
		
	}	
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

	FeaturesGenerator

=head1 SYNOPSIS

	use PRETEXTO::FeaturesGenerator;

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