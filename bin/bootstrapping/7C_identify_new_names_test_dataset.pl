#!/usr/bin/perl
#
## Authors: Jorge Teixeira
##
## Creation data: 26/04/2011
##
##	This script extracts new names identified by CRF model  
##
##
use strict;
use warnings;
use utf8;
use PRETEXTO::Tools;
use LSP::LSP;

my $tools = PRETEXTO::Tools->new();
my $lsp = new LSP::LSP();



## Just some avoidable words
my %black_list = (
'Diário' => '1', 
'El' => '1'
,'Justiça' => '1', 
'Lusa' => '1', 
'Nacional' => '1',
'República' => '1',
'Senhor' => '1',
'Senhora' => '1',
'União' => '1',
);


## CYCLE
my $cycle = shift || 0;

## CRF threshold
my $threshold = shift || 0.6;

## Nr occurrences new name
my $nr_ocu_new_name = shift || 4;


## Load previous dictionary of names
warn("Loading dictionary of names...\n");
my %initial_dictionary = ();
open PREV_DIC, "dataset/dictionary_names_0.txt";
print "Loading dataset/dictionary_names_0.txt\n";
while (<PREV_DIC>) {
	my $line = $_;
	$line = /^(.+?)\t(.+?)$/;
	my $name = $1;
	my $num_oco = $2;
	$name = $tools->SetStringToUtf8($name);
	$initial_dictionary{$name} = $num_oco;
}
close PREV_DIC;



## Load new dictionaries of names
if ($cycle > 0) {
	for (my $ii = 1; $ii <= $cycle; $ii++) {
		my $path_new_dictionary = "dataset/dictionary_new_names_" . $ii . ".txt";
		print "Loading dataset/dictionary_names_$ii.txt\n";
		
		## Add new names to %dictionary
		open NEW_DIC, $path_new_dictionary or die $!;
		while (<NEW_DIC>) {
			my $line = $_;
			$line =~ /^(.+?)\t(.+?)$/;
			my $name = $1;
			my $num_oco = $2;
			$name = $tools->SetStringToUtf8($name);
			$initial_dictionary{$name} = $num_oco;
		}
		close NEW_DIC;
	
	}
}


## Load results from CRF test
my %results = ();
my $counter = 0;
my $path_test = "tests/test_" . $cycle . ".txt";
print "Loading dataset results ($path_test)...\n";
open TESTSET_RESULTS, $path_test;
while (<TESTSET_RESULTS>) {
	my $line = $_;
	$counter++;
	$line = $tools->SetStringToUtf8($line);
	$results{$counter} = $line;
	#if ($counter > 50000) {
		#last;
	#}
}
warn("Dataset results loaded...\n");






## Method to process CRF structure line
sub ProcessLine($) {
	my $line = shift;
	
	my @elements = split('\t', $line);	
	my $token = $elements[0] || "";
	#my $prediction = $elements[5]; # output_1 -> [token, cat, sem_cat, lemma, pn] features
	my $prediction = $elements[8]; # output_2 -> [token, cat, sem_cat, lemma, cap, len, acron, pn] features
	if (!defined($prediction)) {
		return 0;
	}
	$prediction =~ /^(.+?)\/(.+?)$/;
	my $predicted_label = $1 || "";
	my $precision_label = $2 || "";	
	
	return ($token, $predicted_label, $precision_label);	
}






## Process results from CRF test
my %new_names = ();
warn("Processing dataset results...\n");
for (sort {$a<=>$b} keys %results) {
	my $line_nr = $_;
	my $line = $results{$line_nr}; 
	
	if ($line =~ /^#/ || $line =~ /^\n$/) {
		next;
	}
	
	my ($token, $predict_label, $precision) = ProcessLine($line);
	
	if ($predict_label eq "pn_end" && $precision > $threshold) {
		
		# Lets get previous line and check if is a np
		my $prev_line_nr = $line_nr - 1;
		my ($prev_token, $prev_predict_label, $prev_precision) = "";
		if (defined($results{$prev_line_nr})) {
			($prev_token, $prev_predict_label, $prev_precision) = ProcessLine($results{$prev_line_nr});			
		} 

		# Lets get next line and check if is a np
		my $next_line_nr = $line_nr + 1;
		my ($next_token, $next_predict_label, $next_precision) = "";
		if (defined($results{$next_line_nr})) {
			($next_token, $next_predict_label, $next_precision) = ProcessLine($results{$next_line_nr});			
		}
		
		# Three names ('prev' and 'after' and token)		
		if ($prev_predict_label eq "pn_end" && $prev_precision > $threshold &&
				$next_predict_label eq "pn_end" && $next_precision > $threshold) {
#			print "found (-1,0, 1) '$prev_token $token $next_token' - ($prev_precision, $precision, $next_precision)'\n\n";
			my $name = $prev_token . " " . $token . " " . $next_token;
			if (!defined($initial_dictionary{$name})) {
#				print "\t$name => NEW!\n";
#				print "found (-1,0, 1) '$prev_token $token $next_token' - ($prev_precision, $precision, $next_precision)'\n\n";
				$new_names{$name}++;
			}
		}
		
		# Two names ('after' and token)		
		elsif ($next_predict_label eq "pn_end" && $next_precision > $threshold) {
#			print "found (0, 1) '[$prev_token] $token $next_token' - ($prev_precision, $precision, $next_precision)'\n\n";
			my $name = $token . " " . $next_token;
			if (!defined($initial_dictionary{$name})) {

#				print "\t$name => NEW!\n";
#				print "found (0, 1) '[$prev_token] $token $next_token' - ($prev_precision, $precision, $next_precision)'\n\n";
				
				$new_names{$name}++;
			}			
		}		
		
		# Two names ('prev' and token)
		elsif ($prev_predict_label eq "pn_end" && $prev_precision > $threshold) {
#			print "found (-1, 0) '$prev_token $token [$next_token]' - ($prev_precision, $precision, $next_precision)'\n\n";
			my $name = $prev_token . " " . $token;
			if (!defined($initial_dictionary{$name})) {
#				print "\t$name => NEW!\n";
#				print "found (-1, 0) '$prev_token $token [$next_token]' - ($prev_precision, $precision, $next_precision)'\n\n";
				$new_names{$name}++;
			}
			
		}		
		
		# Just one name ('prev' and 'after' tokens are not names)
		else {
#			print "found (0) '$token' - ($precision)'\n\n";
			if (!defined($initial_dictionary{$token}) && $precision > 0.9) {
#				print "\t$token => NEW!\n";
#				print "found (0) '$token' - ($precision)'\n\n";
				$new_names{$token}++;
			}	
			
		}
	}
}
close TESTSET_RESULTS;




## Process new names
print "\n\nNEW NAMES:\n\n";
my $counter_1_word = 0;
my $counter_2_word = 0;
my $counter_3_word = 0;


################### FILTER 1 ########################
## Check if is new candidate (with two words) is not part of the begining of the three words name
## e.g.: 'Manuela Ferreira' and 'Manuela Ferreira Leite'
my %filtered_names = ();
my $f1 = 0;
for (keys %initial_dictionary) {
	my $dic_name = $_;
	my @dic_name_words = split(' ', $dic_name);
	for (keys %new_names) {
		my $new_name = $_;
		my @new_words = split(' ', $new_name);
		if (scalar(@new_words) eq 2 && scalar(@dic_name_words) eq 3 && $dic_name =~ /^$new_name/) {
			print "\t [F1] discarding '" . $tools->SetStringToUtf8($new_name) . "' [$new_names{$new_name}] ($dic_name [$initial_dictionary{$dic_name}])\n";
			$f1++;
			next;
		}
		$filtered_names{$new_name} = $new_names{$new_name};
	}
}



################### FILTER 2 ########################
## Check if candidate name starts or ends with connection names like (de, da,..) 
my %filtered_names_2 = ();
my $f2 = 0;
for (keys %filtered_names) {
	my $name = $_;
	if ($name =~ /^(de|do|da|dos|das|e) / || $name =~ / (de|do|da|dos|das|e)$/ 
			|| $name =~ /^(de|do|da|dos|das|e)$/ || $name =~ /\.|\*|\/|\\|\,|\-/) {
		print "\t [F2] discarding '" . $tools->SetStringToUtf8($name) . "' ($filtered_names{$name})\n";
		$f2++;
	} else {
		$filtered_names_2{$name} = $filtered_names{$name};
	}
}




################### FILTER 3 ########################
## Check if candidate name has more than $nr_ocu_new_name occurences 
my %filtered_names_3 = ();
my $f3 = 0;
for (keys %filtered_names_2) {
	my $name = $_;
	if ($filtered_names_2{$name} < $nr_ocu_new_name) {
		print "\t [F3] discarding '" . $tools->SetStringToUtf8($name) . "' ($filtered_names_2{$name})\n";
		$f3++;
	} else {
		$filtered_names_3{$name} = $filtered_names_2{$name};
	}
}



################### FILTER 4 ########################
## Check if candidate name is not an acronym 
my %filtered_names_4 = ();
my $f4 = 0;
for (keys %filtered_names_3) {
	my $name = $_;
	if ($name =~ /[A-Z]{2,}/) {
		print "\t [F4] discarding '" . $tools->SetStringToUtf8($name) . "' ($filtered_names_3{$name})\n";
		$f4++;
	} else {
		$filtered_names_4{$name} = $filtered_names_3{$name};
	}
}



################### FILTER 5 ########################
## Names cannot start with ergos 
my %filtered_names_5 = ();
my $f5 = 0;
for (keys %filtered_names_4) {
	my $name = $_;
	my @words = split(' ', $name);
	if ( defined($words[0]) && $lsp->IsErgo($words[0]) eq 1) {
		print "\t [F5] discarding '" . $tools->SetStringToUtf8($name) . "' ($filtered_names_4{$name})\n";
		$f5++;		
	} else {
		$filtered_names_5{$name} = $filtered_names_4{$name};
	}
}



################### FILTER 6 ########################
## Some wrong names from the black list like 'Lusa' 
my %filtered_names_6 = ();
my $f6 = 0;
for (keys %filtered_names_5) {
	my $name = $_;
	my @words = split(' ', $name);
	for (@words) {
		
	}
	if ( defined($black_list{$words[0]}) ||
			( defined($words[1]) && defined($black_list{$words[1]}) ) ||
			( defined($words[2]) && defined($black_list{$words[2]}) ) ) {
		print "\t [F6] discarding '" . $tools->SetStringToUtf8($name) . "' ($filtered_names_5{$name})\n";
		$f6++;		
	} else {
		$filtered_names_6{$name} = $filtered_names_5{$name};
	}
}




my %final_candidates = %filtered_names_6;






## Create dictionary with the new names
my $path_new_dictionary = "dataset/dictionary_new_names_" . ($cycle + 1) . ".txt";
open NEW_DIC, ">:utf8",  $path_new_dictionary or die $!;
for (keys %final_candidates) {
	my $string = $_ . "\t" . $final_candidates{$_} . "\n";
	$string = $tools->SetStringToUtf8($string);
	print NEW_DIC $string;
	my @words = split(' ', $_);
	if (scalar(@words) eq 1) { $counter_1_word++; }
	if (scalar(@words) eq 2) { $counter_2_word++; }
	if (scalar(@words) eq 3) { $counter_3_word++; }	
}
close NEW_DIC;



print "\n\nFound $counter_1_word new names with 1 word\n";
print "Found $counter_2_word new names with 2 words\n";
print "Found $counter_3_word new names with 3 words\n";
print $counter_3_word + $counter_2_word + $counter_1_word . " new names\n";
print "Discarded names:\n
\tF1: $f1
\tF2: $f2
\tF3: $f3
\tF4: $f4
";