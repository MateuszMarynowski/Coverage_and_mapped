import pysam
from collections import defaultdict
import numpy as np
import sys
import json

# Indexing bam file
index = pysam.index(sys.argv[1])

# Loading bam file
bamfile = pysam.AlignmentFile(sys.argv[1])

# Number of mapped DNA sequence
mapped = bamfile.mapped

# Total number of reads
total = bamfile.count()

# % of mapped DNA 
percentage = (float(mapped)/total)*100

# Coverage_sum
coverage_sum = 0
for pileupcolumn in bamfile.pileup():
    coverage_sum += pileupcolumn.n
# Average coverage
coverage = float(coverage_sum)/total

# Statistics
statistics = defaultdict(float)
statistics = {'The percentage of mapped DNA sequence readings': np.round(percentage, 3), 'Average coverage': np.round(coverage, 3)}

# Save to .json file
with open(sys.argv[2], 'w') as json_file:
    json.dump(statistics, json_file)

