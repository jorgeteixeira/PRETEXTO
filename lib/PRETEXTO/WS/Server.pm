package PRETEXTO::WS::Server;

use strict;
use warnings;
use PRETEXTO::WS::JSON;
use PRETEXTO::WS::XML;
use PRETEXTO::CRF;
use PRETEXTO::Tools;
use utf8;
binmode(STDOUT, ':utf8');


sub new () {
	shift;
  my $this = {};	
    
  $this->{verbose} = 1;
  
  $this->{tools} = PRETEXTO::Tools->new();
  $this->{json} = PRETEXTO::WS::JSON->new();
  $this->{xml} = PRETEXTO::WS::XML->new();
  $this->{crf} = PRETEXTO::CRF->new();
  
 	bless $this;
  return $this;
}




sub AnnotateText {
	my $this = shift;
	my $input_text = shift || "";
	my $format = shift || "json";
	
	# tokenize
	#my $tokenized_text = $this->{tools}->Tokenize($input_text);
	my $tokenized_text = $input_text;	
	
	# 1) Convert $input_test into CRF format	
	my $crf_input_text = $this->ConvertTextToCRFFormat($tokenized_text);
	
	# 2) Test on the CRF model previously created
	$this->TestOnCRFModel();
	
	# 3) Find NE identified by the model
	my $annotations_ref = $this->IdentifyNE();
	
	# 4) Prepare output annotation
	my $anntated_output_file = $this->AnnotateOutputFile($tokenized_text, $annotations_ref);
	
	# 5) Remove 'temporary files'
	$this->RemoveTempFiles();
	
	my %annotation = ( 'input_text' => $input_text,
										 'annotated_text' => $anntated_output_file,
										 'annotations' => $annotations_ref );
	
	if ($format eq "json") {	
		# Prepare json output
		my $output = $this->{json}->PrepareAnnotationedText(\%annotation);
		return $output;	
	} else {
		# Prepare xml output
		my $output = $this->{xml}->PrepareAnnotationedText(\%annotation);
		return $output;
	}		
	
}


sub ConvertTextToCRFFormat {
	my $this = shift;
	my $tokenized_text = shift;
	
	open (TESTSET, ">:utf8", "NER/data/testset.crf") or die $!;

	for (@{$this->{crf}->GenerateFeatures($tokenized_text)}) {
		my $line = $_;
		print TESTSET $line;
	}		
	
	close TESTSET;

	return 1;
}


sub TestOnCRFModel {
	my $this = shift;
	
	system("/usr/local/bin/crf_test -v1 -n 1 -m NER/data/ner_old.model /Library/WebServer/CGI-Executables/NER/data/testset.crf > /Library/WebServer/CGI-Executables/NER/data/testset_output.txt");
	
	return 1;	
}


sub LoadResultTestSet {
	my $this = shift;

	# open testset annotated file
	open (TESTSET, "NER/data/testset_output.txt") or die $!;
	binmode(TESTSET, ':utf8');
	
	my %results = ();
	my %tokens = ();
	my $ii = 0;
	while (<TESTSET>) {
		my $line = $_;
		$ii++;
		$results{$ii} = $line;
		my @tokens = split('\t', $line);
		$tokens{$ii} = $tokens[0];
	}
	close TESTSET;

	return \%results, \%tokens;
}


sub ProcessLine {
	my $this = shift;
	my $line = shift || "";
	
	my @elements = split('\t', $line);	
	if (!defined($elements[8])) {	return 0;	}
	
	my $token = $elements[0] || "";
	my $prediction = $elements[8]; # output_2 -> [token, cat, sem_cat, lemma, cap, len, acron, pn] features
	
	$prediction =~ /^(.+?)\/(.+?)$/;
	my $predicted_label = $1 || "";
	my $precision_label = $2 || "";	
	
	return ($token, $predicted_label, $precision_label);		
}


sub IdentifyNE {
	my $this = shift;
	my $threshold = 0.6;
	my %output = ();
	
	## Load result testset
	my ($results, $tokens) = $this->LoadResultTestSet();
	my %results = %{$results};

	for (sort {$a<=>$b} keys %results) {
		my $line_nr = $_;
		my $line = $results{$line_nr};		
		$output{$line_nr} = "";
		
		if ($line =~ /^#/ || $line =~ /^\n$/ || $line eq "") { next; } # avoid empty or annotated lines
		my ($token, $predict_label, $precision) = $this->ProcessLine($line);
		
		if ($predict_label eq "pn_end" && $precision > $threshold) {
			
			# Lets get PREVIOUS line
			my $prev_line_nr = $line_nr - 1;
			my ($prev_token, $prev_predict_label, $prev_precision) = $this->ProcessLine($results{$prev_line_nr}) if ( defined($results{$prev_line_nr}) );			
	
			# Lets get NEXT line
			my $next_line_nr = $line_nr + 1;
			my ($next_token, $next_predict_label, $next_precision) = $this->ProcessLine($results{$next_line_nr}) if ( defined($results{$next_line_nr}) );			
			
			# CASE 0) [0] is name
			# this is a dangerous case...
			if ( $prev_predict_label !~ /pn/ &&  $next_predict_label !~ /pn/) {
				warn "found (0) '$token' - ($precision)'";
				$output{$line_nr} = "name";
				next;
			}
			
			# CASE 1) [-1] [0] [1] are names		
			if ($prev_predict_label eq "pn_end" && $prev_precision > $threshold &&
				$next_predict_label eq "pn_end" && $next_precision > $threshold) {
				warn "found (-1,0, 1) '$prev_token $token $next_token' - ($prev_precision, $precision, $next_precision)'";
				my $name = $prev_token . " " . $token . " " . $next_token;
				$output{$line_nr} = "name";
				next;
			}
			
			# CASE 2) [0] [1] are names		
			elsif ($next_predict_label eq "pn_end" && $next_precision > $threshold) {
				warn "found (0, 1) '[$prev_token] $token $next_token' - ($prev_precision, $precision, $next_precision)'";
				my $name = $token . " " . $next_token;
				$output{$line_nr} = "name";
				next;
			}		
			
			# CASE 3) [-1] [0] are names
			elsif ($prev_predict_label eq "pn_end" && $prev_precision > $threshold) {
				warn "found (-1, 0) '$prev_token $token [$next_token]' - ($prev_precision, $precision, $next_precision)'";
				my $name = $prev_token . " " . $token;
				$output{$line_nr} = "name";
				next;				
			}		
			
		}		
		
	}
	
	return \%output;
	
}


sub AnnotateOutputFile {
	my $this = shift;
	my $tokenized_text = shift || "";
	my $annotations_ref = shift || "";
	my %annotations = %{$annotations_ref};
	my @output = ();
	
	my ($results, $tokens) = $this->LoadResultTestSet();
	my %tokens = %{$tokens};
	my $ii = 0;
	for (sort {$a <=> $b} keys %tokens) {
		my $token = $tokens{$_};
		$ii++;
		if ( $token =~ /^#/ || $token =~ /^\n/ ) { next; }
		
		if ( $annotations{$ii} ne "" ) {
			push(@output, "<name>$token</name>");
		}	else {
			push(@output, $token);
		}
		
	}
	 
	return join(' ', @output);
}


sub RemoveTempFiles {
	my $this = shift;
	
	system("rm NER/data/testset.crf");
	system("rm NER/data/testset_output.txt");

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

