#!/usr/local/bin/python3
from sylvester.tokenizer import Tokenizer
import sys
import os

infile = "original.fifo"
outfile = "tokenized.fifo"

os.mkfifo(infile)
os.mkfifo(outfile)
#print("Reading text from \"{0}\", writting to file \"{1}\".".format(infile,outfile))

try:
# Set the number of parallel jobs.
  number_of_workers = 2

  if len(sys.argv) > 1 and sys.argv[1] == "-m":
    model_file = sys.argv[2]
    tokenizer = Tokenizer(model_file, workers=number_of_workers)
  else:
    # Use default value.
    tokenizer = Tokenizer(workers=number_of_workers)

  with open(infile, "r", buffering=1) as input_fifo, open(outfile, "w", buffering=1) as output_fifo:
    while 1:
      line = input_fifo.readline()
      if not line:
        break
      tokenized_text = tokenizer.tokenize_list([line.rstrip()])
      print(*tokenized_text, sep="\n", end="\n", file=output_fifo)

except IOError:
  pass

finally:
  os.unlink(infile)
  os.unlink(outfile)
