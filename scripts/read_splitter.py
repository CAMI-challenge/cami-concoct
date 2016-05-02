import sys
import argparse


parser = argparse.ArgumentParser()
parser.add_argument("file1",help="Outputfile for R1 reads")
parser.add_argument("file2",help="Outputfile for R2 reads")

op = parser.parse_args()

finput = sys.stdin
r1_out = open(op.file1,"w+")
r2_out = open(op.file2,"w+")


chunks = 0
counter = 0

for line in finput:
	if counter%4 == 0: chunks += 1

	if chunks%2 != 0:
		r1_out.write(line)
	else:
		r2_out.write(line)
	
	counter += 1

r1_out.close()
r2_out.close()
