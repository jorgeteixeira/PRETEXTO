package PRETEXTO::Tokenizer;

use warnings;
use strict;
use utf8;
use open ":std","utf8";
use FileHandle;

# Path to the tokenizer tool.
my $K_TOKENIZER_TOOL = "bin/tokenizer_gustavo/fifo_tokenize.py";

# FIFO filenames.
my $K_WRITE_FIFO = "original.fifo";
my $K_READ_FIFO = "tokenized.fifo";

# Object creation.
sub new {
	my $this = {};
	bless $this;
  $this->create_subprocess();
	return $this;
}

# Forking code (as a method for code organization).
sub create_subprocess() {
  my $this = shift(@_);
  my $pid = fork();
  if ($pid == 0) {
    exec "$K_TOKENIZER_TOOL";
    exit(0);
  }
  else {
    until (-e "$K_WRITE_FIFO") {
      sleep(1);
    }
    $this->{write_fd} = FileHandle->new(">$K_WRITE_FIFO");
    binmode($this->{write_fd},":unix"); # To disable buffering.
    binmode($this->{write_fd},":utf8");
    $this->{read_fd} = FileHandle->new("<$K_READ_FIFO");
    binmode($this->{read_fd},":utf8");
    $this->{pid} = $pid;
  }
}

# Object destroyer. Close FIFOS and the tokenizer will exit.
sub DESTROY {
  my $this = shift(@_);
  $this->{write_fd}->close() if defined($this->{write_fd});
  $this->{read_fd}->close() if defined($this->{read_fd});
}

# The only externalizable method.
sub Tokenize($) {
  my $this = shift(@_);
  my $message = shift(@_);
  $message .= "\n" unless $message =~ m/\n$/; # isto foi ideia do Gustavo, é mt foleiro! :D
  $this->{write_fd}->write($message);
  my $tokenized_message = $this->{read_fd}->getline();
  return $tokenized_message;
}

# Example code:
# my $t_obj = new Tokenizer();
# while (my $msg = <>) {
#   my $tokenized_message = $t_obj->Tokenize($msg);
#   print $tokenized_message;
# }
